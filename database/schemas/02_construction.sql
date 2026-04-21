-- ═══════════════════════════════════════════════════════════════
-- 02_CONSTRUCTION.SQL — TTİS domen cədvəlləri (18 cədvəl)
-- ═══════════════════════════════════════════════════════════════

SET search_path TO construction, core, public;

-- ═══ REGIONS (77 rayon) ═══
CREATE TABLE IF NOT EXISTS construction.regions (
    id           SERIAL PRIMARY KEY,
    code         VARCHAR(10) UNIQUE NOT NULL,
    name_az      VARCHAR(100) NOT NULL,
    name_en      VARCHAR(100),
    region_type  VARCHAR(30) CHECK (region_type IN ('city', 'district', 'republic')),
    parent_id    INTEGER REFERENCES construction.regions(id) ON DELETE SET NULL,
    population   INTEGER,
    area_sqkm    NUMERIC(10,2),
    created_at   TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE construction.regions IS 'Azərbaycanın 77 rayonu/şəhəri (ierarxik)';

-- ═══ OBJECT_TYPES (obyekt növləri) ═══
CREATE TABLE IF NOT EXISTS construction.object_types (
    id           SERIAL PRIMARY KEY,
    code         VARCHAR(30) UNIQUE NOT NULL,
    name_az      VARCHAR(100) NOT NULL,
    icon         VARCHAR(50),
    is_active    BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE construction.object_types IS 'Obyekt növləri: məktəb, lisey, gimnaziya, bağça, ...';

-- ═══ BUDGET_CATEGORIES (smeta kateqoriyaları — ierarxik) ═══
CREATE TABLE IF NOT EXISTS construction.budget_categories (
    id           SERIAL PRIMARY KEY,
    code         VARCHAR(30) UNIQUE NOT NULL,
    name         VARCHAR(200) NOT NULL,
    parent_id    INTEGER REFERENCES construction.budget_categories(id) ON DELETE SET NULL,
    level        INTEGER DEFAULT 1,
    is_active    BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE construction.budget_categories IS 'Smeta iş növləri: dam, suvaq, elektrik, ...';

-- ═══ OBJECTS (obyektlər) ═══
CREATE TABLE IF NOT EXISTS construction.objects (
    id              SERIAL PRIMARY KEY,
    region_id       INTEGER NOT NULL REFERENCES construction.regions(id),
    type_id         INTEGER NOT NULL REFERENCES construction.object_types(id),
    code            VARCHAR(30) UNIQUE,
    name            VARCHAR(300) NOT NULL,
    address         TEXT,
    latitude        NUMERIC(10,7),
    longitude       NUMERIC(10,7),
    area_sqm        NUMERIC(10,2),
    total_floors    INTEGER,
    total_rooms     INTEGER,
    student_count   INTEGER,
    year_built      INTEGER,
    year_last_repair INTEGER,
    technical_condition VARCHAR(20) CHECK (technical_condition IN ('excellent','good','satisfactory','poor','emergency')),
    metadata        JSONB DEFAULT '{}'::jsonb,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE construction.objects IS 'Təmir-tikinti obyektləri (məktəblər, lisey, bağçalar, ...)';

-- ═══ CONTRACTORS (podratçılar) ═══
CREATE TABLE IF NOT EXISTS construction.contractors (
    id               SERIAL PRIMARY KEY,
    name             VARCHAR(300) NOT NULL,
    legal_name       VARCHAR(300),
    tax_id           VARCHAR(20) UNIQUE,
    legal_address    TEXT,
    contact_person   VARCHAR(200),
    contact_phone    VARCHAR(20),
    contact_email    VARCHAR(150),
    website          VARCHAR(200),
    rating           NUMERIC(3,2) CHECK (rating BETWEEN 0 AND 5),
    is_blacklisted   BOOLEAN DEFAULT FALSE,
    notes            TEXT,
    is_active        BOOLEAN DEFAULT TRUE,
    created_at       TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE construction.contractors IS 'Podratçı şirkətlərin reyestri';

-- ═══ PROJECTS (layihələr) — əsas cədvəl ═══
CREATE TABLE IF NOT EXISTS construction.projects (
    id                    SERIAL PRIMARY KEY,
    project_code          VARCHAR(50) UNIQUE NOT NULL,
    object_id             INTEGER NOT NULL REFERENCES construction.objects(id),
    manager_id            INTEGER REFERENCES core.users(id) ON DELETE SET NULL,
    name                  VARCHAR(500) NOT NULL,
    description           TEXT,
    project_type          VARCHAR(30) NOT NULL CHECK (project_type IN ('new_build', 'major_repair', 'current_repair', 'reconstruction')),
    status                VARCHAR(30) NOT NULL DEFAULT 'planned'
                            CHECK (status IN ('planned', 'approved', 'in_progress', 'suspended', 'completed', 'cancelled')),
    priority              VARCHAR(10) DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
    start_date_planned    DATE,
    end_date_planned      DATE,
    start_date_actual     DATE,
    end_date_actual       DATE,
    total_budget_planned  NUMERIC(14,2),
    total_budget_actual   NUMERIC(14,2) DEFAULT 0,
    currency              CHAR(3) DEFAULT 'AZN',
    progress_percent      INTEGER DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
    metadata              JSONB DEFAULT '{}'::jsonb,
    created_by            INTEGER REFERENCES core.users(id),
    created_at            TIMESTAMPTZ DEFAULT NOW(),
    updated_at            TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT date_order CHECK (end_date_planned IS NULL OR start_date_planned IS NULL OR end_date_planned >= start_date_planned)
);

COMMENT ON TABLE construction.projects IS 'Əsas layihə cədvəli — TTİS-in mərkəzi';

-- ═══ CONTRACTS (müqavilələr) ═══
CREATE TABLE IF NOT EXISTS construction.contracts (
    id              SERIAL PRIMARY KEY,
    project_id      INTEGER NOT NULL REFERENCES construction.projects(id) ON DELETE CASCADE,
    contractor_id   INTEGER NOT NULL REFERENCES construction.contractors(id),
    contract_number VARCHAR(100) UNIQUE NOT NULL,
    contract_type   VARCHAR(30) CHECK (contract_type IN ('main','subcontract','supply','service')),
    signed_date     DATE NOT NULL,
    start_date      DATE,
    end_date        DATE,
    total_amount    NUMERIC(14,2) NOT NULL,
    paid_amount     NUMERIC(14,2) DEFAULT 0,
    currency        CHAR(3) DEFAULT 'AZN',
    status          VARCHAR(20) DEFAULT 'active' CHECK (status IN ('draft','active','completed','terminated')),
    file_url        TEXT,
    notes           TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ═══ BUDGET_ITEMS (smeta maddələri) ═══
CREATE TABLE IF NOT EXISTS construction.budget_items (
    id                    SERIAL PRIMARY KEY,
    project_id            INTEGER NOT NULL REFERENCES construction.projects(id) ON DELETE CASCADE,
    category_id           INTEGER REFERENCES construction.budget_categories(id),
    item_code             VARCHAR(50),
    name                  VARCHAR(500) NOT NULL,
    unit                  VARCHAR(30),                  -- m², m³, ton, ədəd
    quantity_planned      NUMERIC(12,3),
    price_per_unit_planned NUMERIC(12,2),
    total_planned         NUMERIC(14,2) GENERATED ALWAYS AS (quantity_planned * price_per_unit_planned) STORED,
    quantity_actual       NUMERIC(12,3) DEFAULT 0,
    price_per_unit_actual NUMERIC(12,2),
    total_actual          NUMERIC(14,2) DEFAULT 0,
    notes                 TEXT,
    created_at            TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE construction.budget_items IS 'Layihə smetasının sətir-sətir maddələri';

-- ═══ MATERIALS (material reyestri) ═══
CREATE TABLE IF NOT EXISTS construction.materials (
    id           SERIAL PRIMARY KEY,
    code         VARCHAR(50) UNIQUE,
    name         VARCHAR(300) NOT NULL,
    category     VARCHAR(100),
    unit         VARCHAR(30),
    description  TEXT,
    is_active    BOOLEAN DEFAULT TRUE
);

-- ═══ MATERIAL_USAGE (material sərfi) ═══
CREATE TABLE IF NOT EXISTS construction.material_usage (
    id            SERIAL PRIMARY KEY,
    project_id    INTEGER NOT NULL REFERENCES construction.projects(id) ON DELETE CASCADE,
    material_id   INTEGER NOT NULL REFERENCES construction.materials(id),
    quantity      NUMERIC(12,3) NOT NULL,
    unit_price    NUMERIC(12,2),
    total_cost    NUMERIC(14,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    used_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    recorded_by   INTEGER REFERENCES core.users(id),
    notes         TEXT,
    created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ═══ TEAMS (briqadalar) ═══
CREATE TABLE IF NOT EXISTS construction.teams (
    id           SERIAL PRIMARY KEY,
    project_id   INTEGER NOT NULL REFERENCES construction.projects(id) ON DELETE CASCADE,
    name         VARCHAR(200) NOT NULL,
    team_type    VARCHAR(50),   -- masonry, plumbing, electrical, painting, ...
    leader_name  VARCHAR(200),
    leader_phone VARCHAR(20),
    member_count INTEGER DEFAULT 0,
    is_active    BOOLEAN DEFAULT TRUE,
    created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ═══ EMPLOYEES (briqada üzvləri) ═══
CREATE TABLE IF NOT EXISTS construction.employees (
    id           SERIAL PRIMARY KEY,
    team_id      INTEGER REFERENCES construction.teams(id) ON DELETE SET NULL,
    full_name    VARCHAR(200) NOT NULL,
    position     VARCHAR(100),
    phone        VARCHAR(20),
    daily_rate   NUMERIC(10,2),
    start_date   DATE,
    end_date     DATE,
    is_active    BOOLEAN DEFAULT TRUE
);

-- ═══ TASKS (tapşırıqlar) ═══
CREATE TABLE IF NOT EXISTS construction.tasks (
    id                SERIAL PRIMARY KEY,
    project_id        INTEGER NOT NULL REFERENCES construction.projects(id) ON DELETE CASCADE,
    team_id           INTEGER REFERENCES construction.teams(id),
    title             VARCHAR(500) NOT NULL,
    description       TEXT,
    status            VARCHAR(20) DEFAULT 'pending'
                        CHECK (status IN ('pending','in_progress','review','done','blocked','cancelled')),
    priority          VARCHAR(10) DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
    planned_start     DATE,
    planned_end       DATE,
    actual_start      DATE,
    actual_end        DATE,
    progress_percent  INTEGER DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
    assigned_to       INTEGER REFERENCES core.users(id),
    created_by        INTEGER REFERENCES core.users(id),
    created_at        TIMESTAMPTZ DEFAULT NOW(),
    updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ═══ EQUIPMENT (avadanlıq) ═══
CREATE TABLE IF NOT EXISTS construction.equipment (
    id                SERIAL PRIMARY KEY,
    code              VARCHAR(50) UNIQUE,
    name              VARCHAR(200) NOT NULL,
    type              VARCHAR(50),
    status            VARCHAR(20) DEFAULT 'available'
                        CHECK (status IN ('available','in_use','maintenance','broken')),
    location_object_id INTEGER REFERENCES construction.objects(id),
    last_maintenance  DATE,
    next_maintenance  DATE,
    notes             TEXT,
    is_active         BOOLEAN DEFAULT TRUE
);

-- ═══ MONITORING_VISITS (nəzarət səfərləri) ═══
CREATE TABLE IF NOT EXISTS construction.monitoring_visits (
    id                    SERIAL PRIMARY KEY,
    project_id            INTEGER NOT NULL REFERENCES construction.projects(id) ON DELETE CASCADE,
    inspector_id          INTEGER REFERENCES core.users(id),
    visit_date            DATE NOT NULL,
    findings              JSONB DEFAULT '[]'::jsonb,
    photos                JSONB DEFAULT '[]'::jsonb,  -- URL massivi
    recommendations       TEXT,
    overall_rating        VARCHAR(20) CHECK (overall_rating IN ('excellent','good','satisfactory','poor','critical')),
    follow_up_required    BOOLEAN DEFAULT FALSE,
    follow_up_date        DATE,
    created_at            TIMESTAMPTZ DEFAULT NOW()
);

-- ═══ PROGRESS_REPORTS (aylıq hesabatlar) ═══
CREATE TABLE IF NOT EXISTS construction.progress_reports (
    id                SERIAL PRIMARY KEY,
    project_id        INTEGER NOT NULL REFERENCES construction.projects(id) ON DELETE CASCADE,
    report_date       DATE NOT NULL,
    progress_percent  INTEGER CHECK (progress_percent BETWEEN 0 AND 100),
    narrative         TEXT,
    budget_spent      NUMERIC(14,2),
    issues            JSONB DEFAULT '[]'::jsonb,
    ai_analysis       JSONB,          -- Claude-un generasiya etdiyi təhlil
    created_by        INTEGER REFERENCES core.users(id),
    approved_by       INTEGER REFERENCES core.users(id),
    approved_at       TIMESTAMPTZ,
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ═══ DOCUMENTS (sənədlər) ═══
CREATE TABLE IF NOT EXISTS construction.documents (
    id                   BIGSERIAL PRIMARY KEY,
    related_entity_type  VARCHAR(50) NOT NULL,   -- 'project', 'contract', 'visit'
    related_entity_id    INTEGER NOT NULL,
    filename             VARCHAR(300) NOT NULL,
    original_name        VARCHAR(300),
    mime_type            VARCHAR(100),
    size_bytes           BIGINT,
    storage_path         TEXT NOT NULL,
    uploaded_by          INTEGER REFERENCES core.users(id),
    tags                 JSONB DEFAULT '[]'::jsonb,
    created_at           TIMESTAMPTZ DEFAULT NOW()
);

SELECT 'Construction cədvəlləri hazırdır (18 cədvəl)' AS status;
