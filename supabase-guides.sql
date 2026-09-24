-- ==========================================================================
-- Playbook (guides.html) - run this once in the Supabase SQL Editor.
-- Safe to re-run.
-- ==========================================================================

create table if not exists public.guides (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  title      text not null,
  body       text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.guide_files (
  id          uuid primary key default gen_random_uuid(),
  guide_id    uuid not null references public.guides(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  file_name   text not null,
  file_path   text not null unique,
  file_size   bigint not null default 0,
  mime_type   text,
  uploaded_at timestamptz not null default now()
);

create index if not exists guides_user_idx       on public.guides (user_id, updated_at desc);
create index if not exists guide_files_guide_idx on public.guide_files (guide_id);

-- Full-text-ish search over title and body
create index if not exists guides_search_idx
  on public.guides using gin (to_tsvector('english', title || ' ' || body));

-- --------------------------------------------------------------------------
-- Row-Level Security
-- --------------------------------------------------------------------------
alter table public.guides      enable row level security;
alter table public.guide_files enable row level security;

drop policy if exists "own guides" on public.guides;
create policy "own guides" on public.guides
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own guide files" on public.guide_files;
create policy "own guide files" on public.guide_files
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- --------------------------------------------------------------------------
-- Keep updated_at honest
-- --------------------------------------------------------------------------
create or replace function public.touch_guide()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists guides_touch on public.guides;
create trigger guides_touch
  before update on public.guides
  for each row execute function public.touch_guide();

-- Attachments reuse the existing task-files bucket. Files are stored under
-- <user-id>/guides/<guide-id>/... so the existing storage policies, which key
-- off the first folder being the owner's id, already cover them.

select 'guides ready' as status;
