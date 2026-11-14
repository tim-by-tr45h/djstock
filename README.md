# DJ Stock

Webapp mobile de gestion du matériel DJ/lumière avec tags NFC.

## Installation (une seule fois)
1. Crée un projet sur supabase.com (région Europe). Note le mot de passe de la base.
2. Dans **SQL Editor**, colle `supabase/schema.sql` puis **Run**.
3. Dans **Project Settings > API**, copie l'URL et la clé **anon**. Colle-les en haut du script de `index.html` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`). Jamais la clé `service_role`.
4. (Pour tester vite) Authentication > Providers > Email : désactive « Confirm email ».
5. Crée un dépôt GitHub, envoie ces fichiers, puis **Settings > Pages > Deploy from branch > main / root**.
6. Ouvre l'URL sur l'iPhone dans Safari > Partager > **Sur l'écran d'accueil**.
7. Crée ton compte : le premier compte crée l'entreprise et devient admin.

## Tags NFC
Encode chaque tag avec une URL unique : `https://TON-SITE/#/t/CODE` (CODE différent par tag, ex. K7F3Q2) avec l'app NFC Tools. Scanner = approcher l'iPhone. Tag inconnu = l'appli propose de l'associer à l'exemplaire suivant (mode Patch).

## Ajouter un collègue
Il crée son compte, puis dans Supabase SQL Editor :
`insert into members(user_id, org_id, role) select u.id, (select org_id from members limit 1), 'tech' from auth.users u where u.email='collegue@mail.fr';`
(Un écran d'invitation viendra en v2.)

## Feuille de route
v2 : prestations, check-out / check-in, invitations. v3 : hors-ligne, export, plan DMX.
