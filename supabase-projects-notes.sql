-- ==========================================================================
-- Adds notes to projects and their steps.
-- Run this in the Supabase SQL Editor after supabase-projects.sql.
-- Safe to re-run.
-- ==========================================================================

alter table public.projects
  add column if not exists notes text not null default '';

alter table public.project_steps
  add column if not exists notes text not null default '';

select 'notes columns ready' as status;
