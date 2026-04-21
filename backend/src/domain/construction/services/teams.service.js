const { query } = require('../../../core/config/database');

const findAll = async () => {
  const result = await query(`
    SELECT
      t.id, t.name, t.team_type, t.leader_name, t.leader_phone,
      t.member_count, t.is_active, t.created_at,
      p.project_code, p.name AS project_name,
      (SELECT COUNT(*) FROM construction.tasks WHERE team_id = t.id) AS task_count
    FROM construction.teams t
    LEFT JOIN construction.projects p ON t.project_id = p.id
    ORDER BY t.id DESC
  `);
  return result.rows;
};

const findById = async (id) => {
  const result = await query(`
    SELECT t.*, p.project_code, p.name AS project_name
    FROM construction.teams t
    LEFT JOIN construction.projects p ON t.project_id = p.id
    WHERE t.id = $1
  `, [id]);
  return result.rows[0] || null;
};

module.exports = { findAll, findById };
