// ═══════════════════════════════════════════════════════════════
// src/core/utils/dbTest.js — bağlantını və cədvəlləri test edir
// ═══════════════════════════════════════════════════════════════

const { query, pool } = require('../config/database');

async function runTest() {
  console.log('🔍 PostgreSQL bağlantısını test edirik...\n');

  try {
    // 1. Versiyanı yoxla
    const versionResult = await query('SELECT version()');
    console.log(`✅ PostgreSQL: ${versionResult.rows[0].version.substring(0, 40)}...`);

    // 2. Schema sayını yoxla
    const schemaResult = await query(`
      SELECT schema_name FROM information_schema.schemata
      WHERE schema_name IN ('core', 'construction', 'reporting')
      ORDER BY schema_name
    `);
    console.log(`✅ Schema-lar: ${schemaResult.rows.map(r => r.schema_name).join(', ')}`);

    // 3. Cədvəl sayını yoxla
    const tableResult = await query(`
      SELECT table_schema, COUNT(*) AS total
      FROM information_schema.tables
      WHERE table_schema IN ('core', 'construction', 'reporting')
      GROUP BY table_schema
    `);
    tableResult.rows.forEach(r => {
      console.log(`   ${r.table_schema}: ${r.total} cədvəl`);
    });

    // 4. Nümunə layihə sorğusu
    const projectResult = await query(`
      SELECT COUNT(*) AS total FROM construction.projects
    `);
    console.log(`✅ Layihə sayı: ${projectResult.rows[0].total}`);

    console.log('\n🎉 Bağlantı uğurludur!');
  } catch (err) {
    console.error(`\n❌ Xəta: ${err.message}`);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

runTest();
