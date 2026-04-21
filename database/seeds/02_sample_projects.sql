-- ═══════════════════════════════════════════════════════════════
-- SEED 02 — Nümunə layihələr
-- ═══════════════════════════════════════════════════════════════

-- Nümunə admin istifadəçi (password: admin123 -> bcrypt hash)
INSERT INTO core.users (full_name, email, phone, password_hash, role_id, department_id)
SELECT
  'Tariyel Talıbov', 'tariyel@arti.edu.az', '+994501234567',
  '$2b$10$abcdefghijklmnopqrstuvwxyz0123456789ABCD',  -- placeholder hash
  r.id, d.id
FROM core.roles r, core.departments d
WHERE r.code = 'super_admin' AND d.code = 'HQ'
ON CONFLICT (email) DO NOTHING;

-- Nümunə obyektlər
INSERT INTO construction.objects (region_id, type_id, code, name, address, area_sqm, year_built, technical_condition)
SELECT r.id, ot.id, 'BA-SCH-045', 'Bakı şəhəri 45 saylı tam orta məktəb',
       'Bakı şəh., Nərimanov ray., Atatürk pr. 45', 4250, 1978, 'poor'
FROM construction.regions r, construction.object_types ot
WHERE r.code = 'BA' AND ot.code = 'school'
ON CONFLICT DO NOTHING;

INSERT INTO construction.objects (region_id, type_id, code, name, address, area_sqm, year_built, technical_condition)
SELECT r.id, ot.id, 'GA-LYC-012', 'Gəncə şəhəri Texniki Lisey',
       'Gəncə şəh., 5-ci mikrorayon', 3800, 1985, 'satisfactory'
FROM construction.regions r, construction.object_types ot
WHERE r.code = 'GA' AND ot.code = 'lyceum'
ON CONFLICT DO NOTHING;

-- Nümunə layihə
INSERT INTO construction.projects (
  project_code, object_id, manager_id, name, description,
  project_type, status, start_date_planned, end_date_planned,
  total_budget_planned, progress_percent
)
SELECT
  'PRJ-2026-001',
  o.id,
  u.id,
  'Bakı şəhəri 45 saylı məktəbin əsaslı təmiri',
  'Tam dam, fasad, daxili təmir, elektrik və santexnika yeniləməsi',
  'major_repair',
  'in_progress',
  '2026-03-01'::DATE,
  '2026-09-30'::DATE,
  485000,
  35
FROM construction.objects o, core.users u
WHERE o.code = 'BA-SCH-045' AND u.email = 'tariyel@arti.edu.az'
ON CONFLICT (project_code) DO NOTHING;

SELECT 'Nümunə layihələr daxil edildi' AS status;
