-- ═══════════════════════════════════════════════════════════════
-- 04_VIEWS.SQL — Hesabat view-ları
-- ═══════════════════════════════════════════════════════════════

-- ═══ Layihələrin yekun xülasəsi ═══
CREATE OR REPLACE VIEW reporting.v_project_summary AS
SELECT
    p.id,
    p.project_code,
    p.name AS project_name,
    p.status,
    p.project_type,
    p.progress_percent,
    o.name AS object_name,
    o.address,
    r.name_az AS region,
    ot.name_az AS object_type,
    u.full_name AS manager,
    p.total_budget_planned,
    p.total_budget_actual,
    CASE
        WHEN p.total_budget_planned > 0 THEN
            ROUND((p.total_budget_actual / p.total_budget_planned * 100)::numeric, 2)
        ELSE 0
    END AS budget_usage_percent,
    p.start_date_planned,
    p.end_date_planned,
    p.end_date_actual,
    CASE
        WHEN p.end_date_planned < CURRENT_DATE AND p.status NOT IN ('completed','cancelled') THEN 'overdue'
        WHEN p.end_date_planned < CURRENT_DATE + INTERVAL '30 days' AND p.status = 'in_progress' THEN 'due_soon'
        ELSE 'on_track'
    END AS deadline_status
FROM construction.projects p
LEFT JOIN construction.objects o ON p.object_id = o.id
LEFT JOIN construction.regions r ON o.region_id = r.id
LEFT JOIN construction.object_types ot ON o.type_id = ot.id
LEFT JOIN core.users u ON p.manager_id = u.id;

-- ═══ Smeta sapması ═══
CREATE OR REPLACE VIEW reporting.v_budget_variance AS
SELECT
    p.id AS project_id,
    p.project_code,
    p.name AS project_name,
    bc.name AS category,
    bi.name AS item,
    bi.quantity_planned,
    bi.quantity_actual,
    bi.total_planned,
    bi.total_actual,
    (bi.total_actual - bi.total_planned) AS variance,
    CASE
        WHEN bi.total_planned > 0 THEN
            ROUND(((bi.total_actual - bi.total_planned) / bi.total_planned * 100)::numeric, 2)
        ELSE 0
    END AS variance_percent
FROM construction.budget_items bi
JOIN construction.projects p ON bi.project_id = p.id
LEFT JOIN construction.budget_categories bc ON bi.category_id = bc.id;

-- ═══ Region üzrə aktiv layihələr ═══
CREATE OR REPLACE VIEW reporting.v_regional_activity AS
SELECT
    r.id AS region_id,
    r.name_az AS region_name,
    COUNT(DISTINCT p.id) AS total_projects,
    COUNT(DISTINCT CASE WHEN p.status = 'in_progress' THEN p.id END) AS active_projects,
    COUNT(DISTINCT CASE WHEN p.status = 'completed' THEN p.id END) AS completed_projects,
    SUM(p.total_budget_planned) AS total_budget,
    AVG(p.progress_percent)::INTEGER AS avg_progress_percent
FROM construction.regions r
LEFT JOIN construction.objects o ON o.region_id = r.id
LEFT JOIN construction.projects p ON p.object_id = o.id
GROUP BY r.id, r.name_az
ORDER BY total_projects DESC;

-- ═══ Podratçı performansı ═══
CREATE OR REPLACE VIEW reporting.v_contractor_performance AS
SELECT
    c.id,
    c.name AS contractor_name,
    c.rating,
    COUNT(DISTINCT ct.id) AS contract_count,
    SUM(ct.total_amount) AS total_revenue,
    SUM(ct.paid_amount) AS total_paid,
    COUNT(DISTINCT CASE WHEN ct.status = 'completed' THEN ct.id END) AS completed_contracts,
    COUNT(DISTINCT CASE WHEN ct.status = 'terminated' THEN ct.id END) AS terminated_contracts
FROM construction.contractors c
LEFT JOIN construction.contracts ct ON ct.contractor_id = c.id
GROUP BY c.id, c.name, c.rating
ORDER BY total_revenue DESC NULLS LAST;

-- ═══ Aylıq progres ═══
CREATE OR REPLACE VIEW reporting.v_monthly_progress AS
SELECT
    DATE_TRUNC('month', pr.report_date) AS month,
    COUNT(DISTINCT pr.project_id) AS projects_reported,
    AVG(pr.progress_percent)::INTEGER AS avg_progress,
    SUM(pr.budget_spent) AS total_spent
FROM construction.progress_reports pr
GROUP BY DATE_TRUNC('month', pr.report_date)
ORDER BY month DESC;

SELECT 'Reporting view-ları hazırdır' AS status;
