// ═══════════════════════════════════════════════════════════════
// Password hash və verify funksiyaları
// ═══════════════════════════════════════════════════════════════

const bcrypt = require('bcrypt');
const config = require('../config');

const hash = async (plainPassword) => {
  return await bcrypt.hash(plainPassword, config.bcrypt.rounds);
};

const verify = async (plainPassword, hashedPassword) => {
  return await bcrypt.compare(plainPassword, hashedPassword);
};

module.exports = { hash, verify };
