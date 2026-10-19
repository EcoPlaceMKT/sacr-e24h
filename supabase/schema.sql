-- ════════════════════════════════════════════════════════════════
--  Les Sacrées 24H · espace organisateurs
--  Accès par un lien unique : toute personne qui ouvre l'adresse du site
--  peut lire et modifier. Garde le lien au sein de l'équipe.
--  Relançable sans risque.
-- ════════════════════════════════════════════════════════════════

-- 1. Les données de l'application ───────────────────────────────
--    Une ligne par élément : case cochée, tâche ajoutée, date limite,
--    responsable, commentaire, ligne de budget, document.
create table if not exists public.items (
  collection text        not null,
  id         text        not null,
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  updated_by text,
  primary key (collection, id)
);
alter table public.items enable row level security;
grant select, insert, update, delete on public.items to anon, authenticated;

drop policy if exists "lien lit"      on public.items;
drop policy if exists "lien ajoute"   on public.items;
drop policy if exists "lien modifie"  on public.items;
drop policy if exists "lien supprime" on public.items;
create policy "lien lit"      on public.items for select to anon, authenticated using (true);
create policy "lien ajoute"   on public.items for insert to anon, authenticated with check (collection in ('checks','extra','assign','due','label','comments','budget','docs','people','notes'));
create policy "lien modifie"  on public.items for update to anon, authenticated using (true) with check (collection in ('checks','extra','assign','due','label','comments','budget','docs','people','notes'));
create policy "lien supprime" on public.items for delete to anon, authenticated using (true);

-- 2. Le temps réel ──────────────────────────────────────────────
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'items'
  ) then
    alter publication supabase_realtime add table public.items;
  end if;
end $$;

-- 3. Les fichiers (devis, factures, sécurité…) ──────────────────
--    PDF et images, 20 Mo maximum par fichier.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('documents', 'documents', false, 20971520,
        array['application/pdf', 'image/png', 'image/jpeg', 'image/webp', 'image/gif'])
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "lien lit les fichiers"      on storage.objects;
drop policy if exists "lien ajoute des fichiers"   on storage.objects;
drop policy if exists "lien modifie les fichiers"  on storage.objects;
drop policy if exists "lien supprime les fichiers" on storage.objects;
create policy "lien lit les fichiers"      on storage.objects for select to anon, authenticated using (bucket_id = 'documents');
create policy "lien ajoute des fichiers"   on storage.objects for insert to anon, authenticated with check (bucket_id = 'documents');
create policy "lien modifie les fichiers"  on storage.objects for update to anon, authenticated using (bucket_id = 'documents');
create policy "lien supprime les fichiers" on storage.objects for delete to anon, authenticated using (bucket_id = 'documents');
