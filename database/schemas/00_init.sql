-- ═══════════════════════════════════════════════════════════════
-- 00_INIT.SQL — Verilənlər bazasının ilkin hazırlığı
-- ═══════════════════════════════════════════════════════════════

-- Zaman zonası və kodlaşdırma təsdiqi
SET client_encoding = 'UTF8';
SET timezone = 'Asia/Baku';

-- ═══ Schema-ları yaradırıq ═══
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS construction;
CREATE SCHEMA IF NOT EXISTS reporting;

-- ═══ Şərhlər ═══
COMMENT ON SCHEMA core IS 'Özək qat: istifadəçi, rol, audit';
COMMENT ON SCHEMA construction IS 'Tikinti domeni: layihə, smeta, brigada';
COMMENT ON SCHEMA reporting IS 'Hesabat view-ları';

-- ═══ Lazımi extension-lar ═══
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";   -- UUID generasiyası
CREATE EXTENSION IF NOT EXISTS "pgcrypto";    -- Şifrələmə
CREATE EXTENSION IF NOT EXISTS "pg_trgm";     -- Trigram axtarış

-- ═══ Yoxlama ═══
SELECT 'Schema-lar hazırdır' AS status;
