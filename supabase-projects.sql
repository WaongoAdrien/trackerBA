-- ==========================================================================
-- Projects (projects.html) - run once in the Supabase SQL Editor.
-- Safe to re-run.
-- ==========================================================================

create table if not exists public.projects (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  name       text not null,
  category   text not null default 'Project',
  summary    text not null default '',
  due_date   date,
  status     text not null default 'active' check (status in ('active','on_hold','done')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.project_steps (
  id         uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  title      text not null,
  due_date   date,
  done       boolean not null default false,
  position   integer not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists projects_user_idx     on public.projects (user_id, updated_at desc);
create index if not exists steps_project_idx     on public.project_steps (project_id, position);

alter table public.projects      enable row level security;
alter table public.project_steps enable row level security;

drop policy if exists "own projects" on public.projects;
create policy "own projects" on public.projects
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own steps" on public.project_steps;
create policy "own steps" on public.project_steps
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create or replace function public.touch_project()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists projects_touch on public.projects;
create trigger projects_touch
  before update on public.projects
  for each row execute function public.touch_project();

select 'projects ready' as status;
