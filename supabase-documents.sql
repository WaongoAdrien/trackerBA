-- ==========================================================================
-- Documents (documents.html) - run once in the Supabase SQL Editor.
-- Holds two kinds of entry:
--   kind = 'file'  a stored document or screenshot, with an optional note
--   kind = 'note'  a written note with no file attached
-- Safe to re-run, and safe if you already ran the earlier version.
-- ==========================================================================

create table if not exists public.documents (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  title      text not null,
  note       text not null default '',
  category   text not null default 'Notes',
  kind       text not null default 'file',
  file_name  text,
  file_path  text unique,
  file_size  bigint not null default 0,
  mime_type  text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Bring an earlier version of the table up to date
alter table public.documents add column if not exists kind text not null default 'file';
alter table public.documents alter column file_name drop not null;
alter table public.documents alter column file_path drop not null;

do $$
begin
  if not exists (
    select 1 from information_schema.constraint_column_usage
    where table_name = 'documents' and constraint_name = 'documents_kind_check'
  ) then
    alter table public.documents
      add constraint documents_kind_check check (kind in ('file', 'note'));
  end if;
end $$;

create index if not exists documents_user_idx on public.documents (user_id, created_at desc);
create index if not exists documents_kind_idx on public.documents (user_id, kind);

alter table public.documents enable row level security;

drop policy if exists "own documents" on public.documents;
create policy "own documents" on public.documents
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create or replace function public.touch_document()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists documents_touch on public.documents;
create trigger documents_touch
  before update on public.documents
  for each row execute function public.touch_document();

select 'documents ready' as status;
