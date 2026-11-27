-- Run this SQL in Supabase Dashboard > SQL Editor.
create table if not exists public.workouts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  client_key text not null,
  date timestamptz not null,
  exercise text not null,
  reps integer not null check (reps > 0),
  weight double precision not null check (weight >= 0),
  media_title text,
  media_minutes integer not null default 0,
  duration_minutes integer not null default 0,
  created_at timestamptz not null default now(),
  unique (user_id, client_key)
);

alter table public.workouts enable row level security;

drop policy if exists "Users can read their own workouts" on public.workouts;
create policy "Users can read their own workouts"
on public.workouts for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert their own workouts" on public.workouts;
create policy "Users can insert their own workouts"
on public.workouts for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update their own workouts" on public.workouts;
create policy "Users can update their own workouts"
on public.workouts for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own workouts" on public.workouts;
create policy "Users can delete their own workouts"
on public.workouts for delete
to authenticated
using (auth.uid() = user_id);
