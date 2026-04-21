// ═══════════════════════════════════════════════════════════════
// server.js — entry point
// ═══════════════════════════════════════════════════════════════

const app = require('./src/app');
const config = require('./src/core/config');
const logger = require('./src/core/utils/logger');

const server = app.listen(config.server.port, config.server.host, () => {
  logger.info(`🚀 ${config.app.name} v${config.app.version}`);
  logger.info(`🌐 http://${config.server.host}:${config.server.port}`);
  logger.info(`🔧 Environment: ${config.env}`);
  logger.info(`📦 Domain: ${config.domain}`);
});

// Graceful shutdown
const shutdown = (signal) => {
  logger.info(`${signal} alındı, server dayandırılır...`);
  server.close(() => {
    logger.info('✅ Server dayandırıldı');
    process.exit(0);
  });
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
