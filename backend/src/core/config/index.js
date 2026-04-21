// ═══════════════════════════════════════════════════════════════
// src/core/config/index.js — .env-i yükləyir və valid edir
// ═══════════════════════════════════════════════════════════════

require('dotenv').config();

const required = ['JWT_SECRET', 'DB_NAME', 'DB_USER'];
const missing = required.filter(key => !process.env[key]);

if (missing.length > 0) {
  console.error(`❌ Bu env dəyişənləri çatışmır: ${missing.join(', ')}`);
  process.exit(1);
}

const config = {
  env: process.env.NODE_ENV || 'development',
  isProduction: process.env.NODE_ENV === 'production',

  app: {
    name: process.env.APP_NAME || 'TTİS API',
    version: process.env.APP_VERSION || '0.1.0'
  },

  server: {
    port: parseInt(process.env.PORT, 10) || 3001,
    host: process.env.HOST || 'localhost',
    apiPrefix: process.env.API_PREFIX || '/api/v1'
  },

  domain: process.env.DOMAIN || 'construction',

  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 5432,
    name: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD || '',
    poolMin: parseInt(process.env.DB_POOL_MIN, 10) || 2,
    poolMax: parseInt(process.env.DB_POOL_MAX, 10) || 10
  },

  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d'
  },

  bcrypt: {
    rounds: parseInt(process.env.BCRYPT_ROUNDS, 10) || 10
  },

  anthropic: {
    apiKey: process.env.ANTHROPIC_API_KEY,
    model: process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-6',
    maxTokens: parseInt(process.env.ANTHROPIC_MAX_TOKENS, 10) || 4096
  },

  cors: {
    origin: (process.env.CORS_ORIGIN || '*').split(',')
  },

  log: {
    level: process.env.LOG_LEVEL || 'info'
  }
};

module.exports = config;
