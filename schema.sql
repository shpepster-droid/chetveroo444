-- ЧЕТВЕРО: базовая схема Supabase (стартовый вариант).
-- Запускайте в Supabase Dashboard -> SQL Editor только после ознакомления.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null check (char_length(nickname) between 2 and 24),
  avatar text not null default '◈',
  created_at timestamptz not null default now()
);

create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  owner_id uuid references auth.users(id),
  permanent boolean not null default true,
  theme text not null default 'mono',
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.room_members (
  room_id uuid references public.rooms(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','member')),
  joined_at timestamptz not null default now(),
  active boolean not null default true,
  primary key(room_id,user_id)
);

create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  room_id uuid references public.rooms(id) on delete cascade,
  rounds integer not null default 10,
  difficulty text not null default 'medium' check (difficulty in ('light','medium','hard')),
  vote_mode text not null default 'all',
  categories text[] not null default '{}',
  status text not null default 'setup',
  started_at timestamptz,
  finished_at timestamptz
);

create table if not exists public.game_rounds (
  id uuid primary key default gen_random_uuid(),
  game_id uuid references public.games(id) on delete cascade,
  round_number integer not null,
  question text not null,
  category text not null,
  player_id uuid references auth.users(id),
  answer_text text,
  answer_media_path text,
  revealed boolean not null default false,
  created_at timestamptz not null default now(),
  unique(game_id,round_number)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  room_id uuid references public.rooms(id) on delete cascade,
  game_id uuid references public.games(id) on delete cascade,
  sender_id uuid references auth.users(id),
  body text,
  media_path text,
  media_type text check (media_type in ('image','audio')),
  reply_to uuid references public.messages(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.votes (
  id uuid primary key default gen_random_uuid(),
  game_round_id uuid references public.game_rounds(id) on delete cascade,
  voter_id uuid references auth.users(id),
  vote text not null,
  created_at timestamptz not null default now(),
  unique(game_round_id,voter_id)
);

create table if not exists public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid references auth.users(id) on delete cascade,
  recipient_id uuid references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined')),
  created_at timestamptz not null default now(),
  unique(requester_id,recipient_id),
  check(requester_id <> recipient_id)
);

create table if not exists public.dm_messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid references auth.users(id) on delete cascade,
  recipient_id uuid references auth.users(id) on delete cascade,
  body text,
  media_path text,
  media_type text check (media_type in ('image','audio')),
  reply_to uuid references public.dm_messages(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.game_stats (
  id uuid primary key default gen_random_uuid(),
  game_id uuid references public.games(id) on delete cascade,
  player_id uuid references auth.users(id) on delete cascade,
  points integer not null default 0,
  wins integer not null default 0,
  achievements text[] not null default '{}',
  unique(game_id,player_id)
);

-- Включаем RLS. Политики доступа нужно настроить дополнительно перед production.
alter table public.profiles enable row level security;
alter table public.rooms enable row level security;
alter table public.room_members enable row level security;
alter table public.games enable row level security;
alter table public.game_rounds enable row level security;
alter table public.messages enable row level security;
alter table public.votes enable row level security;
alter table public.friendships enable row level security;
alter table public.dm_messages enable row level security;
alter table public.game_stats enable row level security;

-- Не добавляйте service_role key во frontend.
