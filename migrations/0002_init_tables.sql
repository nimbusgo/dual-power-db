CREATE SCHEMA app_public;
CREATE SCHEMA app_private;
CREATE SCHEMA app_hidden;

CREATE ROLE IF NOT EXISTS dual_power_anonymous;
CREATE ROLE IF NOT EXISTS dual_power_user;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE app_public.users (
    id                                    uuid DEFAULT uuid_generate_v4(),
    email   varchar(256),
    PRIMARY KEY(id)
);

CREATE TABLE app_public.users_private (
    user_id uuid primary key references app_public.users(id) on delete cascade,
    email   varchar(128),
    unique(user_id)
);

CREATE TABLE app_private.user_auth (
  user_id         uuid primary key references app_public.users(id) on delete cascade,
  auth_user_id    text not null,
  unique(auth_user_id)
);

CREATE TABLE app_public.user_profiles (
    id              uuid DEFAULT uuid_generate_v4(),
    user_id         uuid,
    display_name    varchar(128),
    pronoun         varchar(64),
    created_at      timestamptz DEFAULT current_timestamp,

    PRIMARY KEY (id),
    CONSTRAINT fk_user
      FOREIGN KEY(user_id) 
	  REFERENCES app_public.users(id),
    UNIQUE (display_name)
);

CREATE TABLE app_public.locations (
    id          uuid DEFAULT uuid_generate_v4(),
    name        varchar(256) not null,
    address     TEXT,
    lat         numeric,
    lon         numeric,
    PRIMARY KEY (id)
);

CREATE TYPE circle_type AS ENUM (
  'CIRCLE',
  'AREA'
);

CREATE TABLE app_public.circles (
    id                    uuid DEFAULT uuid_generate_v4(),
    name                  varchar(256),
    parent                uuid references app_public.circles(id),
    location_id           uuid references app_public.locations(id) on delete set null,
    circle_type           circle_type,
    PRIMARY KEY (id)
);

CREATE TABLE app_public.circle_members (
    circle_id            uuid references app_public.circles(id) on delete cascade,
    profile_id           uuid references app_public.user_profiles(id) on delete cascade,
    UNIQUE (circle_id, profile_id)
);


CREATE TYPE voting_model AS ENUM (
  'CONSENSUS',
  'CONSENT'
);

CREATE TYPE proposal_outcome AS ENUM (
  'APPROVED',
  'REJECTED',
  'UNDECIDED'
);


CREATE TABLE app_public.proposals (
    id                    uuid DEFAULT uuid_generate_v4(),
    circle_id             uuid references app_public.circles(id) on delete cascade,
    voting_model voting_model,
    created_at timestamptz DEFAULT current_timestamp,
    resolved_at timestamptz,
    active boolean,
    outcome proposal_outcome,
    PRIMARY KEY (id)
);

CREATE TABLE app_public.events (
    id                    uuid DEFAULT uuid_generate_v4(),
    name                  varchar(256),
    location_id           uuid references app_public.locations(id) on delete set null,
    propsal_id            uuid references app_public.proposals(id) on delete set null,
    starts_at timestamptz not null,
    ends_at timestamptz not null,
    circle_type           circle_type,
    PRIMARY KEY (id)
);


CREATE TABLE app_public.votes (
    id                    uuid DEFAULT uuid_generate_v4(),
    profile_id            uuid references app_public.user_profiles(id) on delete cascade,
    proxy_to              uuid references app_public.user_profiles(id) on delete set null,
    proposal_id           uuid references app_public.proposals(id) on delete cascade,
    approve               boolean,
    PRIMARY KEY (id),
    UNIQUE(profile_id, proposal_id)
);

CREATE TABLE app_public.documents (
    id                    uuid DEFAULT uuid_generate_v4(),
    circle_id             uuid references app_public.circles(id) on delete cascade,
    proposal_id           uuid references app_public.proposals(id) on delete cascade,
    title                 TEXT not null,
    PRIMARY KEY (id)
);

CREATE TABLE app_public.revisions (
    id                    uuid DEFAULT uuid_generate_v4(),
    proposal_id           uuid references app_public.proposals(id) on delete cascade,
    document_id           uuid references app_public.documents(id) on delete cascade,
    revision_title        TEXT not null,
    content               TEXT not null,
    PRIMARY KEY (id)
);

CREATE TABLE app_public.posts (
    id                    uuid DEFAULT uuid_generate_v4(),
    author                uuid references app_public.user_profiles(id) on delete cascade,
    circle_id             uuid references app_public.circles(id) on delete cascade,
    document_id           uuid references app_public.documents(id) on delete cascade,
    subject               TEXT not null,
    content               TEXT not null,
    PRIMARY KEY (id)
);

CREATE TABLE app_public.comments (
    id                    uuid DEFAULT uuid_generate_v4(),
    author                uuid references app_public.user_profiles(id) on delete cascade,
    post_id               uuid references app_public.posts(id) on delete cascade,
    content               TEXT not null,
    PRIMARY KEY (id)
);

-- Grants / Roles
GRANT dual_power_anonymous to dual_power_postgraphile;
GRANT dual_power_user to dual_power_postgraphile;

GRANT USAGE ON SCHEMA app_public TO dual_power_anonymous, dual_power_user;
GRANT USAGE ON SCHEMA app_hidden TO dual_power_anonymous, dual_power_user;

GRANT ALL ON SCHEMA app_public TO dual_power_anonymous, dual_power_user; 

-- GRANT ALL ON app_public.circles TO dual_power_anonymous;
-- GRANT ALL ON app_public.circles TO dual_power_user;