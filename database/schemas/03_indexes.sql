-- ═══════════════════════════════════════════════════════════════
-- 03_INDEXES.SQL — Performans indeksləri
-- ═══════════════════════════════════════════════════════════════

-- Obyektlər üzrə tez axtarış
CREATE INDEX IF NOT EXISTS idx_objects_region ON construction.objects(region_id);
CREATE INDEX IF NOT EXISTS idx_objects_type ON construction.objects(type_id);
CREATE INDEX IF NOT EXISTS idx_objects_name_trgm ON construction.objects USING GIN (name gin_trgm_ops);

-- Layihələr — ən çox sorğulanan
CREATE INDEX IF NOT EXISTS idx_projects_object ON construction.projects(object_id);
CREATE INDEX IF NOT EXISTS idx_projects_status ON construction.projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_manager ON construction.projects(manager_id);
CREATE INDEX IF NOT EXISTS idx_projects_dates ON construction.projects(start_date_planned, end_date_planned);

-- Smeta
CREATE INDEX IF NOT EXISTS idx_budget_items_project ON construction.budget_items(project_id);
CREATE INDEX IF NOT EXISTS idx_budget_items_category ON construction.budget_items(category_id);

-- Müqavilələr
CREATE INDEX IF NOT EXISTS idx_contracts_project ON construction.contracts(project_id);
CREATE INDEX IF NOT EXISTS idx_contracts_contractor ON construction.contracts(contractor_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON construction.contracts(status);

-- Tapşırıqlar
CREATE INDEX IF NOT EXISTS idx_tasks_project ON construction.tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_team ON construction.tasks(team_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON construction.tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_assignee ON construction.tasks(assigned_to);

-- Monitorinq
CREATE INDEX IF NOT EXISTS idx_monitoring_project ON construction.monitoring_visits(project_id);
CREATE INDEX IF NOT EXISTS idx_monitoring_date ON construction.monitoring_visits(visit_date);

-- Sənədlər
CREATE INDEX IF NOT EXISTS idx_docs_entity ON construction.documents(related_entity_type, related_entity_id);

-- Material sərfi
CREATE INDEX IF NOT EXISTS idx_material_usage_project ON construction.material_usage(project_id);
CREATE INDEX IF NOT EXISTS idx_material_usage_date ON construction.material_usage(used_date);

SELECT 'İndekslər hazırdır' AS status;
