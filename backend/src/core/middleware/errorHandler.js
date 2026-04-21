// ═══════════════════════════════════════════════════════════════
// Global error handler middleware
// ═══════════════════════════════════════════════════════════════

const logger = require('../utils/logger');
const config = require('../config');

// 404 Not Found
const notFound = (req, res, next) => {
  res.status(404).json({
    error: 'Not Found',
    message: `${req.method} ${req.originalUrl} tapılmadı`
  });
};

// Global xəta tutucu
const errorHandler = (err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  logger.error(`${req.method} ${req.path} — ${err.message}`, {
    stack: err.stack,
    body: req.body,
    userId: req.user?.id
  });

  res.status(statusCode).json({
    error: err.name || 'Error',
    message: err.message,
    ...(config.isProduction ? {} : { stack: err.stack })
  });
};

// Custom xəta sinfi
class ApiError extends Error {
  constructor(statusCode, message) {
    super(message);
    this.statusCode = statusCode;
    this.name = 'ApiError';
  }
}

module.exports = { notFound, errorHandler, ApiError };
