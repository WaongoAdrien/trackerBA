# Task Tracker — cloud setup

Until you complete this, the tracker keeps running exactly as it does now,
storing tasks in this browser. A banner at the top will say so.

Once configured you get: sign-in, tasks stored in a real database, completed
tasks kept forever, and file attachments.

---

## 1. Create the project

1. Go to **https://supabase.com** and sign up (free).
2. **New project**. Give it a name and a database password — save that password
   somewhere safe, you will not be shown it again.
3. Pick the region closest to you. Wait ~2 minutes while it provisions.

## 2. Create the tables

1. In the left sidebar open **SQL Editor** → **New query**.
2. Open `supabase-setup.sql` from this folder, copy all of it, paste it in.
3. Press **Run**. You should see `Success. No rows returned`.

This creates both tables, the security policies, and the private `task-files`
storage bucket.

## 3. Turn on email sign-in

1. Sidebar → **Authentication** → **Providers**.
2. Make sure **Email** is enabled.
3. While testing, Authentication → **Sign In / Up** → consider turning
   *Confirm email* **off** so you can log in immediately. Turn it back on later.

## 4. Allow large uploads

1. Sidebar → **Storage** → **Settings** (or Project Settings → Storage).
2. Raise the **upload file size limit** to what you need.
   The free plan caps this lower than paid plans — if you need files above
   50MB you will need the Pro plan.
3. Whatever you set here, set the same number as `MAX_UPLOAD_MB` in
   `index.html` so the app can warn you *before* a long upload fails.

## 5. Connect the app

1. Sidebar → **Project Settings** → **API**.
2. Copy the **Project URL** and the **anon / public** key.
3. Open `index.html`, find this block near the top of the `<script>`:

```js
const SUPABASE_URL      = "";
const SUPABASE_ANON_KEY = "";
```

4. Paste the two values in, save, reload the page.

You should now see a sign-in screen.

> **Never put the `service_role` key in this file.** It ignores every security
> policy. Only the **anon** key belongs in a web page. The anon key is safe to
> expose — Row-Level Security is what protects your data, which is why step 2
> matters.

## 6. Create your account

On the sign-in screen choose **Create one**, enter your email and a password.
If you left *Confirm email* on, click the link in the email first.

## 7. Bring your existing tasks across

1. Before switching, open the old local version and press **Download backup**.
2. Sign in to the cloud version.
3. Press **Restore** and pick that backup file.

Your tasks upload to the database. Do this once.

---

## Costs

| | Free | Pro ($25/mo) |
|---|---|---|
| Database | 500 MB | 8 GB |
| File storage | 1 GB | 100 GB |
| Pauses when idle | after ~1 week | no |

Tasks are tiny; attachments are what consume space. A few hundred office
documents fit in the free tier. You said some files will be large — if you are
regularly attaching files over 25MB, plan on Pro.

## If something goes wrong

**Stuck on the sign-in screen after entering correct details**
Email confirmation is probably on. Check your inbox, or turn it off in
Authentication → Sign In / Up while testing.

**"Failed to load tasks"**
The SQL in step 2 did not run. Open the SQL Editor and run it again.

**Uploads fail on big files**
The project's storage limit is below the file size. See step 4.

**You want to go back to local-only**
Blank out the two config values. Your local tasks are still there.
