-- ==========================================================================
-- Processes (processes.html) - run once in the Supabase SQL Editor.
-- A process is a named thing you do, with a description and its own files.
-- Safe to re-run.
-- ==========================================================================

create table if not exists public.processes (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  description text not null default '',
  owner       text not null default '',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table if not exists public.process_files (
  id          uuid primary key default gen_random_uuid(),
  process_id  uuid not null references public.processes(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  file_name   text not null,
  file_path   text not null unique,
  file_size   bigint not null default 0,
  mime_type   text,
  uploaded_at timestamptz not null default now()
);

create index if not exists processes_user_idx      on public.processes (user_id, updated_at desc);
create index if not exists process_files_proc_idx  on public.process_files (process_id);

alter table public.processes      enable row level security;
alter table public.process_files  enable row level security;

drop policy if exists "own processes" on public.processes;
create policy "own processes" on public.processes
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own process files" on public.process_files;
create policy "own process files" on public.process_files
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create or replace function public.touch_process()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists processes_touch on public.processes;
create trigger processes_touch
  before update on public.processes
  for each row execute function public.touch_process();

-- Files reuse the existing task-files bucket, stored under
-- <user-id>/processes/... so the existing storage policies already cover them.

select 'processes ready' as status;
