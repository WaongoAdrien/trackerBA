-- ==========================================================================
-- Task Tracker - add the "In testing" stage
-- Run this once, in your project's SQL Editor (left sidebar > SQL Editor).
-- Safe to re-run.
--
-- The status column has a CHECK constraint listing the stages it accepts.
-- Until this runs, moving a task to testing is rejected by the database.
-- ==========================================================================

alter table public.tasks
  drop constraint if exists tasks_status_check;

alter table public.tasks
  add constraint tasks_status_check
  check (status in ('active', 'initiated', 'testing', 'completed'));
