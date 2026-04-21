// ═══════════════════════════════════════════════════════════════
// src/core/utils/logger.js — Winston əsaslı logger
// ═══════════════════════════════════════════════════════════════

const winston = require('winston');
const config = require('../config');

const { combine, timestamp, printf, colorize, errors } = winston.format;

// Konsola yazılacaq format
const consoleFormat = combine(
  colorize({ all: true }),
  timestamp({ format: 'HH:mm:ss' }),
  errors({ stack: true }),
  printf(({ timestamp, level, message, ...meta }) => {
    const metaStr = Object.keys(meta).length ? ` ${JSON.stringify(meta)}` : '';
    return `${timestamp} ${level}: ${message}${metaStr}`;
  })
);

const logger = winston.createLogger({
  level: config.log.level,
  transports: [
    new winston.transports.Console({ format: consoleFormat })
  ]
});

// Production-da fayla yazırıq
if (config.isProduction) {
  logger.add(new winston.transports.File({
    filename: 'logs/error.log',
    level: 'error'
  }));
  logger.add(new winston.transports.File({
    filename: 'logs/combined.log'
  }));
}

module.exports = logger;
