-- ═══════════════════════════════════════════════════════════════
-- 05_TRIGGERS.SQL — Avtomatik davranışlar
-- ═══════════════════════════════════════════════════════════════

-- ═══ updated_at funksiyası ═══
CREATE OR REPLACE FUNCTION core.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Bu trigger-i tətbiq edək:
CREATE TRIGGER trg_users_updated
    BEFORE UPDATE ON core.users
    FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();

CREATE TRIGGER trg_projects_updated
    BEFORE UPDATE ON construction.projects
    FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();

CREATE TRIGGER trg_objects_updated
    BEFORE UPDATE ON construction.objects
    FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();

CREATE TRIGGER trg_tasks_updated
    BEFORE UPDATE ON construction.tasks
    FOR EACH ROW EXECUTE FUNCTION core.set_updated_at();

-- ═══ Layihə progres% hesablama funksiyası ═══
CREATE OR REPLACE FUNCTION construction.recalc_project_progress()
RETURNS TRIGGER AS $$
DECLARE
    v_project_id INT;
    v_avg INT;
BEGIN
    v_project_id := COALESCE(NEW.project_id, OLD.project_id);
    SELECT COALESCE(AVG(progress_percent), 0)::INT INTO v_avg
    FROM construction.tasks
    WHERE project_id = v_project_id;

    UPDATE construction.projects
    SET progress_percent = v_avg,
        updated_at = NOW()
    WHERE id = v_project_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recalc_on_task
    AFTER INSERT OR UPDATE OR DELETE ON construction.tasks
    FOR EACH ROW EXECUTE FUNCTION construction.recalc_project_progress();

SELECT 'Trigger-lər hazırdır' AS status;
