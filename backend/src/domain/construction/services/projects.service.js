// ═══════════════════════════════════════════════════════════════
// projects.service.js — layihələr üçün SQL əməliyyatları
// ═══════════════════════════════════════════════════════════════

const { query } = require('../../../core/config/database');

const findAll = async (filters = {}) => {
  const { status, limit = 50, offset = 0 } = filters;
  let sql = 'SELECT * FROM reporting.v_project_summary WHERE 1=1';
  const params = [];

  if (status) {
    params.push(status);
    sql += ` AND status = $${params.length}`;
  }

  params.push(limit);
  params.push(offset);
  sql += ` ORDER BY id DESC LIMIT $${params.length - 1} OFFSET $${params.length}`;

  const result = await query(sql, params);
  return result.rows;
};

const findById = async (id) => {
  const result = await query(
    'SELECT * FROM reporting.v_project_summary WHERE id = $1',
    [id]
  );
  return result.rows[0] || null;
};

const create = async (data, userId) => {
  const {
    project_code, object_id, manager_id, name, description,
    project_type, start_date_planned, end_date_planned, total_budget_planned
  } = data;

  const result = await query(`
    INSERT INTO construction.projects
      (project_code, object_id, manager_id, name, description,
       project_type, start_date_planned, end_date_planned,
       total_budget_planned, created_by)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    RETURNING *
  `, [project_code, object_id, manager_id, name, description,
      project_type, start_date_planned, end_date_planned,
      total_budget_planned, userId]);

  return result.rows[0];
};

const update = async (id, data) => {
  const fields = [];
  const values = [];
  let idx = 1;

  for (const [key, value] of Object.entries(data)) {
    fields.push(`${key} = $${idx++}`);
    values.push(value);
  }
  values.push(id);

  const result = await query(`
    UPDATE construction.projects
    SET ${fields.join(', ')}
    WHERE id = $${idx}
    RETURNING *
  `, values);

  return result.rows[0];
};

const remove = async (id) => {
  const result = await query(
    'DELETE FROM construction.projects WHERE id = $1 RETURNING id',
    [id]
  );
  return result.rows[0];
};

module.exports = { findAll, findById, create, update, remove };
