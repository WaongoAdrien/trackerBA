-- ==========================================================================
-- Storage only - run this if the task-files bucket is missing.
--
-- If you get "must be owner of table objects" on the policy statements,
-- create the policies through the dashboard instead:
--   Storage > Policies > task-files > New policy > "For full customization"
-- and use the expressions shown in the comments below.
-- ==========================================================================

-- 1. The private bucket. Files are reached only via short-lived signed URLs.
insert into storage.buckets (id, name, public)
values ('task-files', 'task-files', false)
on conflict (id) do nothing;

-- 2. Policies. Files are stored at  <user-id>/<task-id>/<uuid>-<filename>,
--    so the first folder in the path is the owner's id.

drop policy if exists "read own files"   on storage.objects;
drop policy if exists "upload own files" on storage.objects;
drop policy if exists "delete own files" on storage.objects;

-- SELECT   using:      bucket_id = 'task-files' AND (storage.foldername(name))[1] = auth.uid()::text
create policy "read own files" on storage.objects
  for select
  using (bucket_id = 'task-files' and (storage.foldername(name))[1] = auth.uid()::text);

-- INSERT   with check: bucket_id = 'task-files' AND (storage.foldername(name))[1] = auth.uid()::text
create policy "upload own files" on storage.objects
  for insert
  with check (bucket_id = 'task-files' and (storage.foldername(name))[1] = auth.uid()::text);

-- DELETE   using:      bucket_id = 'task-files' AND (storage.foldername(name))[1] = auth.uid()::text
create policy "delete own files" on storage.objects
  for delete
  using (bucket_id = 'task-files' and (storage.foldername(name))[1] = auth.uid()::text);

-- 3. Confirm it worked
select id, name, public from storage.buckets where id = 'task-files';
