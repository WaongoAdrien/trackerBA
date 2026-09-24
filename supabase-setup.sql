-- ==========================================================================
-- Task Tracker - Supabase setup
-- Run this once, in your project's SQL Editor (left sidebar > SQL Editor).
-- Safe to re-run: every statement is guarded.
-- ==========================================================================

-- --------------------------------------------------------------------------
-- 1. Tables
-- --------------------------------------------------------------------------

create table if not exists public.tasks (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  text         text not null,
  status       text not null default 'active'
                 check (status in ('active', 'initiated', 'testing', 'completed')),
  category     text not null default 'CRM',
  priority     text not null default 'medium'
                 check (priority in ('high', 'medium', 'low')),
  due_date     date,
  notes        text not null default '',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.attachments (
  id          uuid primary key default gen_random_uuid(),
  task_id     uuid not null references public.tasks(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  file_name   text not null,
  file_path   text not null unique,   -- path inside the storage bucket
  file_size   bigint not null default 0,
  mime_type   text,
  uploaded_at timestamptz not null default now()
);

-- Indexes for the queries the app actually runs
create index if not exists tasks_user_status_idx   on public.tasks (user_id, status);
create index if not exists tasks_completed_at_idx  on public.tasks (user_id, completed_at desc);
create index if not exists attachments_task_idx    on public.attachments (task_id);

-- --------------------------------------------------------------------------
-- 2. Row-Level Security
--    This is what stops one signed-in user reading another's data.
--    Without it your tables are readable by anyone holding the public key.
-- --------------------------------------------------------------------------

alter table public.tasks       enable row level security;
alter table public.attachments enable row level security;

drop policy if exists "own tasks" on public.tasks;
create policy "own tasks" on public.tasks
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "own attachments" on public.attachments;
create policy "own attachments" on public.attachments
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- --------------------------------------------------------------------------
-- 3. Keep updated_at / completed_at honest
-- --------------------------------------------------------------------------

create or replace function public.touch_task()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();

  -- Stamp the moment a task first becomes completed, clear it if reopened
  if new.status = 'completed' and coalesce(old.status, '') <> 'completed' then
    new.completed_at := now();
  elsif new.status <> 'completed' then
    new.completed_at := null;
  end if;

  return new;
end;
$$;

drop trigger if exists tasks_touch on public.tasks;
create trigger tasks_touch
  before update on public.tasks
  for each row execute function public.touch_task();

-- --------------------------------------------------------------------------
-- 4. Storage bucket for attachments
--    Private bucket: files are reached only through short-lived signed URLs.
-- --------------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('task-files', 'task-files', false)
on conflict (id) do nothing;

-- Files live at  <user-id>/<task-id>/<uuid>-<filename>, so the first path
-- segment is the owner. These policies compare it against the caller.

drop policy if exists "read own files"   on storage.objects;
drop policy if exists "upload own files" on storage.objects;
drop policy if exists "delete own files" on storage.objects;

create policy "read own files" on storage.objects
  for select
  using (bucket_id = 'task-files' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "upload own files" on storage.objects
  for insert
  with check (bucket_id = 'task-files' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "delete own files" on storage.objects
  for delete
  using (bucket_id = 'task-files' and (storage.foldername(name))[1] = auth.uid()::text);

-- --------------------------------------------------------------------------
-- Done. Check Authentication > Providers > Email is enabled,
-- then paste your project URL and anon key into index.html.
-- --------------------------------------------------------------------------
