const { query } = require('../../../core/config/database');

const findAll = async () => {
  const result = await query(`
    SELECT
      o.id, o.code, o.name, o.address, o.area_sqm,
      o.year_built, o.year_last_repair, o.technical_condition,
      o.is_active, o.student_count, o.total_floors,
      r.name_az AS region,
      ot.name_az AS object_type,
      ot.icon
    FROM construction.objects o
    LEFT JOIN construction.regions r ON o.region_id = r.id
    LEFT JOIN construction.object_types ot ON o.type_id = ot.id
    ORDER BY o.id DESC
  `);
  return result.rows;
};

const findById = async (id) => {
  const result = await query(`
    SELECT o.*, r.name_az AS region, ot.name_az AS object_type, ot.icon
    FROM construction.objects o
    LEFT JOIN construction.regions r ON o.region_id = r.id
    LEFT JOIN construction.object_types ot ON o.type_id = ot.id
    WHERE o.id = $1
  `, [id]);
  return result.rows[0] || null;
};

module.exports = { findAll, findById };
