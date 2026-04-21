// ═══════════════════════════════════════════════════════════════
// src/app.js — Express tətbiqi
// ═══════════════════════════════════════════════════════════════

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const config = require('./core/config');
const logger = require('./core/utils/logger');
const { notFound, errorHandler } = require('./core/middleware/errorHandler');

const authRoutes = require('./core/routes/auth.routes');

const app = express();

// ═══ Təhlükəsizlik middleware-ləri ═══
app.use(helmet());
app.use(cors({
  origin: config.cors.origin,
  credentials: true
}));

// ═══ Body parser ═══
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ═══ HTTP log ═══
app.use(morgan(config.isProduction ? 'combined' : 'dev', {
  stream: { write: (msg) => logger.info(msg.trim()) }
}));

// ═══ Health check ═══
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    app: config.app.name,
    version: config.app.version,
    env: config.env,
    domain: config.domain,
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// ═══ Core route-ları ═══
app.use(`${config.server.apiPrefix}/auth`, authRoutes);

// ═══ Domain route-ları dinamik yüklənir ═══
try {
  const domainRoutes = require(`./domain/${config.domain}`);
  app.use(`${config.server.apiPrefix}/${config.domain}`, domainRoutes);
  logger.info(`🔌 Domain yükləndi: ${config.domain}`);
} catch (err) {
  logger.warn(`⚠️  Domain yüklənə bilmədi: ${config.domain} — ${err.message}`);
}

// ═══ 404 və error handler (ən sonda olmalıdır!) ═══
app.use(notFound);
app.use(errorHandler);

module.exports = app;
