# Les Sacrées 24H · espace organisateurs

Tâches, planning semaine par semaine, budget et documents de l'organisation des Sacrées 24H (backyard 24 h, 22–23 mai 2027, Champagne Charles Heston). Tout est partagé en temps réel entre les organisateurs.

- **Site** : page statique (`public/index.html`) servie par Vercel.
- **Base de données, temps réel et fichiers** : Supabase.
- **Connexion** : lien envoyé par e-mail, réservé aux adresses de l'équipe.

## Mise en ligne (une dizaine de minutes)

### 1. Supabase

1. Crée un projet sur [supabase.com](https://supabase.com) (région Europe, de préférence Paris).
2. Ouvre l'éditeur SQL du projet.
3. Ouvre `supabase/schema.sql`, **remplace les 4 adresses e-mail** par celles de l'équipe, colle le tout et lance-le.
4. Colle ensuite `supabase/seed.sql` et lance-le : il reprend le budget prévisionnel et l'avancement déjà saisis.
5. Dans les réglages d'authentification :
   - désactive l'inscription libre (« Allow new users to sign up ») ;
   - invite les 4 adresses depuis la liste des utilisateurs (« Invite user »).
6. Dans les réglages de l'API du projet, note deux valeurs :
   - l'**URL du projet** (`https://xxxx.supabase.co`) ;
   - la **clé publique** (`anon` / `public`).
   N'utilise jamais la clé `service_role` dans le site.

### 2. Vercel

1. Sur [vercel.com](https://vercel.com), importe ce dépôt GitHub comme nouveau projet.
2. Avant de déployer, ajoute deux variables d'environnement :
   - `SUPABASE_URL` = l'URL du projet Supabase ;
   - `SUPABASE_ANON_KEY` = la clé publique.
3. Lance le déploiement. Vercel exécute `npm run build`, qui prépare le dossier `dist/`.

### 3. Relier les deux

Dans les réglages d'URL de l'authentification Supabase, mets l'adresse du site Vercel (par exemple `https://sacrees-24h.vercel.app`) comme **Site URL** et ajoute-la aux **Redirect URLs**. Sans ça, le lien de connexion renvoie au mauvais endroit.

C'est prêt : chacun ouvre le site, entre son adresse et clique sur le lien reçu.

## Bon à savoir

- **Ajouter quelqu'un** : ajoute son adresse dans la table `team_members` (voir la fin de `schema.sql`), puis invite-le depuis Supabase.
- **E-mails de connexion** : le service d'envoi fourni par Supabase est limité à quelques e-mails par heure. Pour 4 personnes ça suffit ; au-delà, branche un SMTP dans les réglages d'authentification.
- **Fichiers** : PDF ou images (JPG, PNG), 20 Mo maximum. L'offre gratuite de Supabase inclut 1 Go de stockage.
- **Mise en veille** : un projet Supabase gratuit sans activité pendant une semaine est mis en pause ; il se relance depuis le tableau de bord.

## Travailler en local

```bash
SUPABASE_URL=https://xxxx.supabase.co SUPABASE_ANON_KEY=xxxx npm run dev
```

## Organisation des fichiers

```
public/index.html      la page (interface, logique, liste des 184 tâches)
scripts/build.mjs      copie public/ vers dist/ et écrit config.js depuis les variables d'environnement
supabase/schema.sql    tables, règles d'accès, temps réel, espace de stockage des fichiers
supabase/seed.sql      données reprises de la première version
vercel.json            réglages de build et en-têtes de sécurité
```
