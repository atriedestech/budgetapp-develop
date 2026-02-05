-- Drop existing tables to start fresh (Reverse Order of Dependencies)
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS recurrings CASCADE;
DROP TABLE IF EXISTS budgets CASCADE;
DROP TABLE IF EXISTS budget_types CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS auth_tokens CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. Users Table
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    currency VARCHAR(10) DEFAULT 'USD',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Auth Tokens (Keep since it's used by the app logic)
CREATE TABLE auth_tokens (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(255) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Categories Table
CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('INCOME', 'EXPENDITURE')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, name)
);

-- 4. Budget Types (Renaming old Concept for partial compatibility/migration)
-- This table is critical for the current Java code's recurring logic
CREATE TABLE budget_types (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Budgets Table (Modified to fit New Schema principles but keep app working)
-- We will keep 'actual' for now to avoid breaking the Java app immediately,
-- but the structure is cleaner.
CREATE TABLE budgets (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id BIGINT NOT NULL REFERENCES categories(id),
    type_id BIGINT REFERENCES budget_types(id), -- Nullable for new design, but kept for legacy
    name VARCHAR(100) NOT NULL,
    projected NUMERIC(19, 4) DEFAULT 0,
    actual NUMERIC(19, 4) DEFAULT 0,
    period_on TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, category_id, name, period_on)
);

-- 6. Recurrings
CREATE TABLE recurrings (
    id BIGSERIAL PRIMARY KEY,
    budget_type_id BIGINT NOT NULL REFERENCES budget_types(id),
    amount NUMERIC(19, 4) NOT NULL,
    type VARCHAR(20) NOT NULL, -- DAILY, MONTHLY, etc
    remark VARCHAR(255),
    last_run_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Transactions
CREATE TABLE transactions (
    id BIGSERIAL PRIMARY KEY,
    budget_id BIGINT NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
    recurring_id BIGINT REFERENCES recurrings(id),
    name VARCHAR(100),
    amount NUMERIC(19, 4) NOT NULL CHECK (amount <> 0),
    remark TEXT,
    auto BOOLEAN DEFAULT FALSE,
    transaction_on TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Performance
CREATE INDEX idx_budgets_user_period ON budgets(user_id, period_on);
CREATE INDEX idx_transactions_budget ON transactions(budget_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_on);
