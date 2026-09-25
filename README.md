# trackerBA

A personal work tracker for business-analyst work: tasks, projects with ordered
steps, a book of how-tos, a process catalogue and a document store.

Plain HTML, CSS and JavaScript — no build step. Open `index.html` and it runs.
Data lives in Supabase (Postgres, Auth and Storage) behind row-level security,
so every row and every uploaded file is scoped to the signed-in user.

## Pages

| Page | File | What it holds |
| --- | --- | --- |
| Tasks | `index.html` | Day-to-day tasks through Backlog, In progress, In testing and Completed |
| Book | `guides.html` | How-tos worth remembering, with screenshots |
| Projects | `projects.html` | Larger pieces of work broken into ordered steps, with notes and attached documents |
| Processes | `processes.html` | The scheduled-job catalogue, searchable by name, navigation path or attribute |
| Docs & Notes | `documents.html` | Files and standalone notes, grouped as Issue Resolution, Procedure or Notes |

All five share `styles.css` and `theme.js`. The theme toggle in the top bar
switches between dark and light and remembers the choice.

## Setup

`SETUP.md` has the steps. In short: create a Supabase project, run the
`supabase-*.sql` files in the SQL editor, create the `attachments` storage
bucket, then put your project URL and publishable key at the top of each page.

The publishable key is meant to sit in the browser — it grants nothing on its
own, because row-level security decides what each request may read or write.
