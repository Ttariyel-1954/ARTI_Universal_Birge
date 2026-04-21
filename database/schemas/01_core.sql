-- ═══════════════════════════════════════════════════════════════
-- 01_CORE.SQL — Core qatın cədvəlləri
-- ═══════════════════════════════════════════════════════════════

SET search_path TO core, public;

-- ═══ 1. ROLES ═══
CREATE TABLE IF NOT EXISTS core.roles (
    id           SERIAL PRIMARY KEY,
    code         VARCHAR(50) UNIQUE NOT NULL,
    name         VARCHAR(100) NOT NULL,
    description  TEXT,
    permissions  JSONB DEFAULT '[]'::jsonb,
    is_system    BOOLEAN DEFAULT FALSE,
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    updated_at   TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE core.roles IS 'Sistem rolları (admin, manager, inspector, ...)';

-- ═══ 2. DEPARTMENTS (şöbələr) ═══
CREATE TABLE IF NOT EXISTS core.departments (
    id           SERIAL PRIMARY KEY,
    code         VARCHAR(50) UNIQUE,
    name         VARCHAR(200) NOT NULL,
    parent_id    INTEGER REFERENCES core.departments(id) ON DELETE SET NULL,
    description  TEXT,
    is_active    BOOLEAN DEFAULT TRUE,
    created_at   TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE core.departments IS 'Təşkilati şöbələr (ierarxik)';

-- ═══ 3. USERS ═══
CREATE TABLE IF NOT EXISTS core.users (
    id              SERIAL PRIMARY KEY,
    full_name       VARCHAR(200) NOT NULL,
    email           VARCHAR(150) UNIQUE NOT NULL,
    phone           VARCHAR(20),
    password_hash   VARCHAR(255) NOT NULL,
    role_id         INTEGER REFERENCES core.roles(id) ON DELETE RESTRICT,
    department_id   INTEGER REFERENCES core.departments(id) ON DELETE SET NULL,
    avatar_url      TEXT,
    is_active       BOOLEAN DEFAULT TRUE,
    email_verified  BOOLEAN DEFAULT FALSE,
    last_login_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

COMMENT ON TABLE core.users IS 'Sistem istifadəçiləri';

-- ═══ 4. SESSIONS ═══
CREATE TABLE IF NOT EXISTS core.sessions (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id      INTEGER NOT NULL REFERENCES core.users(id) ON DELETE CASCADE,
    token_hash   VARCHAR(255) NOT NULL,
    ip_address   INET,
    user_agent   TEXT,
    expires_at   TIMESTAMPTZ NOT NULL,
    revoked_at   TIMESTAMPTZ,
    created_at   TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE core.sessions IS 'JWT session tarixçəsi';

-- ═══ 5. AUDIT_LOG ═══
CREATE TABLE IF NOT EXISTS core.audit_log (
    id            BIGSERIAL PRIMARY KEY,
    user_id       INTEGER REFERENCES core.users(id) ON DELETE SET NULL,
    action        VARCHAR(50) NOT NULL,      -- INSERT, UPDATE, DELETE, LOGIN, ...
    entity_type   VARCHAR(100),              -- projects, users, ...
    entity_id     INTEGER,
    old_values    JSONB,
    new_values    JSONB,
    ip_address    INET,
    user_agent    TEXT,
    created_at    TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE core.audit_log IS 'Bütün dəyişikliklərin tarixçəsi';

-- ═══ İNDEKSLƏR ═══
CREATE INDEX idx_users_email     ON core.users(email);
CREATE INDEX idx_users_role      ON core.users(role_id);
CREATE INDEX idx_users_dept      ON core.users(department_id);
CREATE INDEX idx_sessions_user   ON core.sessions(user_id);
CREATE INDEX idx_sessions_exp    ON core.sessions(expires_at);
CREATE INDEX idx_audit_user      ON core.audit_log(user_id);
CREATE INDEX idx_audit_entity    ON core.audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_created   ON core.audit_log(created_at);

SELECT 'Core cədvəlləri hazırdır' AS status;
