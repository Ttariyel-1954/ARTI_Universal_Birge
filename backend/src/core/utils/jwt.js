// ═══════════════════════════════════════════════════════════════
// JWT token generasiyası və yoxlaması
// ═══════════════════════════════════════════════════════════════

const jwt = require('jsonwebtoken');
const config = require('../config');

const sign = (payload) => {
  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.expiresIn
  });
};

const verify = (token) => {
  return jwt.verify(token, config.jwt.secret);
};

module.exports = { sign, verify };
