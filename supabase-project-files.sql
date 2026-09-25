-- ==========================================================================
-- Projects - document attachments
-- Run this once, in your project's SQL Editor (left sidebar > SQL Editor).
-- Safe to re-run: every statement is guarded.
--
-- Files go in the existing private "task-files" bucket, under
--   <user-id>/projects/<project-id>/<uuid>-<filename>
-- so the storage policies from supabase-setup.sql already cover them.
-- ==========================================================================

create table if not exists public.project_files (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  file_name   text not null,
  file_path   text not null unique,   -- path inside the storage bucket
  file_size   bigint not null default 0,
  mime_type   text,
  uploaded_at timestamptz not null default now()
);

create index if not exists project_files_project_idx on public.project_files (project_id);

alter table public.project_files enable row level security;

drop policy if exists "own project files" on public.project_files;
create policy "own project files" on public.project_files
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
