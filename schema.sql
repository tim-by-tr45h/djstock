-- DJ Stock : schéma Supabase (à coller dans SQL Editor, puis Run)
create table orgs (id uuid primary key default gen_random_uuid(), name text not null);
create table members (user_id uuid primary key references auth.users on delete cascade,
  org_id uuid not null references orgs on delete cascade, role text not null default 'tech');

create function my_org() returns uuid language sql stable security definer set search_path=public
as $$ select org_id from members where user_id = auth.uid() $$;

create table products (id uuid primary key default gen_random_uuid(), org_id uuid not null default my_org() references orgs,
  name text not null, category text, brand text, power text, notes text, created_at timestamptz default now());
create table units (id uuid primary key default gen_random_uuid(), org_id uuid not null default my_org() references orgs,
  product_id uuid not null references products on delete cascade, label text,
  tag_code text unique, state text not null default 'range' check (state in ('range','presta','nettoyer','reparer')),
  serial text, dmx text, role_note text, note text, location text, updated_at timestamptz default now());
create table history (id bigint generated always as identity primary key, org_id uuid not null default my_org() references orgs,
  unit_id uuid not null references units on delete cascade, event text, by_user uuid default auth.uid(), at timestamptz default now());

alter table orgs enable row level security; alter table members enable row level security;
alter table products enable row level security; alter table units enable row level security; alter table history enable row level security;
create policy own_org on orgs for select using (id = my_org());
create policy own_row on members for select using (user_id = auth.uid() or org_id = my_org());
create policy org_all on products for all using (org_id = my_org()) with check (org_id = my_org());
create policy org_all on units for all using (org_id = my_org()) with check (org_id = my_org());
create policy org_all on history for all using (org_id = my_org()) with check (org_id = my_org());

-- Premier utilisateur : crée l'organisation et devient admin
create function create_org(n text) returns uuid language plpgsql security definer set search_path=public as $$
declare o uuid; begin
  if exists (select 1 from members where user_id = auth.uid()) then raise exception 'déjà membre'; end if;
  insert into orgs(name) values (n) returning id into o;
  insert into members(user_id, org_id, role) values (auth.uid(), o, 'admin'); return o; end $$;

-- Historique automatique des changements d'état / de tag
create function log_unit() returns trigger language plpgsql security definer set search_path=public as $$
begin
  if tg_op='INSERT' then insert into history(org_id,unit_id,event) values (new.org_id,new.id,'Créé');
  else
    if new.state is distinct from old.state then insert into history(org_id,unit_id,event) values (new.org_id,new.id,'État : '||new.state); end if;
    if new.tag_code is distinct from old.tag_code then insert into history(org_id,unit_id,event) values (new.org_id,new.id,'Tag associé : '||coalesce(new.tag_code,'aucun')); end if;
    new.updated_at = now();
  end if; return new; end $$;
create trigger trg_log_ins after insert on units for each row execute function log_unit();
create trigger trg_log_upd before update on units for each row execute function log_unit();
