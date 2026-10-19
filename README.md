# Les Sacrées 24H · espace organisateurs

Tâches, planning semaine par semaine, budget et documents de l'organisation des Sacrées 24H (backyard 24 h, 22–23 mai 2027, Champagne Charles Heston). Tout est synchronisé en temps réel entre les organisateurs.

- **Un seul lien pour toute l'équipe**, sans compte ni mot de passe.
- **Site** : page statique (`public/index.html`) servie par Vercel.
- **Base de données, temps réel et fichiers** : Supabase (projet `sacrees-24h`, région Paris), déjà créé et rempli.

> Toute personne qui a l'adresse du site peut lire et modifier. Garde le lien au sein de l'équipe et passe ce dépôt en privé une fois le site en ligne sur Vercel.

## Mettre le site en ligne sur Vercel

1. Sur [vercel.com/new](https://vercel.com/new), importe le dépôt `EcoPlaceMKT/sacr-e24h`.
2. Lance le déploiement sans rien changer : les réglages sont dans `vercel.json` et la configuration Supabase dans `public/config.js`.
3. L'adresse du site (`https://….vercel.app`) s'affiche à la fin : c'est le lien à partager à l'équipe.

Chaque modification poussée sur la branche `main` redéploie le site automatiquement.

## Bon à savoir

- **Qui a fait quoi** : chacun choisit « Je suis » en haut de la page ; ses cases cochées et ses commentaires sont signés à son nom.
- **Fichiers** : PDF ou images (JPG, PNG), 20 Mo maximum. L'offre gratuite de Supabase inclut 1 Go de stockage.
- **Mise en veille** : un projet Supabase gratuit sans activité pendant une semaine est mis en pause ; il se relance depuis le tableau de bord Supabase.
- **Changer de base** : remplace l'URL et la clé dans `public/config.js`, ou définis `SUPABASE_URL` et `SUPABASE_ANON_KEY` dans Vercel (elles sont prioritaires).

## Organisation des fichiers

```
public/index.html      la page (interface, logique, liste des 184 tâches)
public/config.js       adresse de la base Supabase et clé publique (faite pour être visible)
scripts/build.mjs      copie public/ vers dist/
supabase/schema.sql    tables, règles d'accès, temps réel, espace de stockage des fichiers
supabase/seed.sql      données reprises de la première version
vercel.json            réglages de build et en-têtes de sécurité
```
