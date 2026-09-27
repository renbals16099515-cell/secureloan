-- Secureloan database setup
-- Run this in Supabase SQL Editor for project Secureloan.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text, email text, phone text,
 role text not null default 'borrower' check (role in ('lender','borrower')),
 status text not null default 'active' check (status in ('active','inactive')),
 created_at timestamptz not null default now()
);
create table if not exists public.loans (
 id uuid primary key default gen_random_uuid(),
 borrower_id uuid not null references public.profiles(id) on delete cascade,
 principal numeric(14,2) not null check (principal > 0),
 interest_rate numeric(8,3) not null default 0,
 interest_amount numeric(14,2) not null default 0,
 total_payable numeric(14,2) not null,
 payment_frequency text not null check (payment_frequency in ('daily','weekly','twice_monthly','monthly')),
 installment_count integer not null check (installment_count > 0),
 installment_amount numeric(14,2) not null,
 start_date date not null default current_date,
 first_due_date date not null,
 status text not null default 'active' check (status in ('pending','active','completed','cancelled')),
 notes text, created_at timestamptz not null default now()
);
create table if not exists public.payment_schedules (
 id uuid primary key default gen_random_uuid(),
 loan_id uuid not null references public.loans(id) on delete cascade,
 installment_number integer not null,
 due_date date not null,
 amount_due numeric(14,2) not null,
 amount_paid numeric(14,2) not null default 0,
 status text not null default 'pending' check (status in ('pending','partial','paid','overdue')),
 unique (loan_id, installment_number)
);
create table if not exists public.payments (
 id uuid primary key default gen_random_uuid(),
 loan_id uuid not null references public.loans(id) on delete cascade,
 borrower_id uuid not null references public.profiles(id) on delete cascade,
 amount numeric(14,2) not null check (amount > 0),
 payment_date date not null default current_date,
 installment_number integer,
 notes text,
 recorded_by uuid not null references public.profiles(id),
 created_at timestamptz not null default now()
);
create table if not exists public.loan_requests (
 id uuid primary key default gen_random_uuid(),
 borrower_id uuid not null references public.profiles(id) on delete cascade,
 type text not null check (type in ('NEW','RENEWAL')),
 requested_amount numeric(14,2) not null check (requested_amount > 0),
 requested_installments integer,
 frequency text check (frequency is null or frequency in ('daily','weekly','twice_monthly','monthly')),
 reason text,
 status text not null default 'pending',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
alter table public.loans enable row level security;
alter table public.payment_schedules enable row level security;
alter table public.payments enable row level security;
alter table public.loan_requests enable row level security;
