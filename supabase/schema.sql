-- ════════════════════════════════════════════════════════════════
--  Les Sacrées 24H · espace organisateurs
--  À coller dans l'éditeur SQL de Supabase, puis « Run ».
--  Relançable sans risque.
-- ════════════════════════════════════════════════════════════════

-- 1. L'équipe autorisée ─────────────────────────────────────────
--    Remplace les 4 adresses ci-dessous par les vraies.
--    Seules ces adresses peuvent lire et modifier les données.
create table if not exists public.team_members (
  email text primary key
);
alter table public.team_members enable row level security;
-- (aucune règle d'accès : la table n'est lisible que par la fonction ci-dessous)

insert into public.team_members (email) values
  ('paul@exemple.fr'),
  ('tom@exemple.fr'),
  ('matheo@exemple.fr'),
  ('theo@exemple.fr')
on conflict do nothing;

create or replace function public.is_team()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.team_members
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke all on function public.is_team() from public;
grant execute on function public.is_team() to authenticated;

-- 2. Les données de l'application ───────────────────────────────
--    Une ligne par élément : case cochée, tâche ajoutée, date limite,
--    responsable, commentaire, ligne de budget, document.
create table if not exists public.items (
  collection text        not null,
  id         text        not null,
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  updated_by uuid,
  primary key (collection, id)
);
alter table public.items enable row level security;

drop policy if exists "equipe lit"      on public.items;
drop policy if exists "equipe ajoute"   on public.items;
drop policy if exists "equipe modifie"  on public.items;
drop policy if exists "equipe supprime" on public.items;
create policy "equipe lit"      on public.items for select to authenticated using (public.is_team());
create policy "equipe ajoute"   on public.items for insert to authenticated with check (public.is_team());
create policy "equipe modifie"  on public.items for update to authenticated using (public.is_team()) with check (public.is_team());
create policy "equipe supprime" on public.items for delete to authenticated using (public.is_team());

-- 3. Le temps réel ──────────────────────────────────────────────
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'items'
  ) then
    alter publication supabase_realtime add table public.items;
  end if;
end $$;

-- 4. Les fichiers (devis, factures, sécurité…) ──────────────────
--    Espace privé : PDF et images, 20 Mo maximum par fichier.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('documents', 'documents', false, 20971520,
        array['application/pdf', 'image/png', 'image/jpeg', 'image/webp', 'image/gif'])
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "equipe lit les fichiers"       on storage.objects;
drop policy if exists "equipe ajoute des fichiers"    on storage.objects;
drop policy if exists "equipe modifie les fichiers"   on storage.objects;
drop policy if exists "equipe supprime les fichiers"  on storage.objects;
create policy "equipe lit les fichiers"      on storage.objects for select to authenticated using (bucket_id = 'documents' and public.is_team());
create policy "equipe ajoute des fichiers"   on storage.objects for insert to authenticated with check (bucket_id = 'documents' and public.is_team());
create policy "equipe modifie les fichiers"  on storage.objects for update to authenticated using (bucket_id = 'documents' and public.is_team());
create policy "equipe supprime les fichiers" on storage.objects for delete to authenticated using (bucket_id = 'documents' and public.is_team());

-- Pour ajouter quelqu'un plus tard :
--   insert into public.team_members (email) values ('nouvelle.personne@exemple.fr');
-- puis l'inviter depuis la page Authentication > Users de Supabase.
