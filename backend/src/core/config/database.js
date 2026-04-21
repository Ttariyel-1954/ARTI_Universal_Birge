// ═══════════════════════════════════════════════════════════════
// src/core/config/database.js — PostgreSQL Pool
// ═══════════════════════════════════════════════════════════════

const { Pool } = require('pg');
const config = require('./index');

const pool = new Pool({
  host: config.db.host,
  port: config.db.port,
  database: config.db.name,
  user: config.db.user,
  password: config.db.password,
  min: config.db.poolMin,
  max: config.db.poolMax,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
});

// Pool-dan sorğu icra edən köməkçi funksiya
const query = async (text, params = []) => {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    if (config.env === 'development') {
      console.log(`📊 Query (${duration}ms): ${text.substring(0, 80)}...`);
    }
    return result;
  } catch (err) {
    console.error(`❌ DB Error: ${err.message}`);
    throw err;
  }
};

// Tranzaksiya üçün köməkçi
const transaction = async (callback) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

module.exports = { pool, query, transaction };
