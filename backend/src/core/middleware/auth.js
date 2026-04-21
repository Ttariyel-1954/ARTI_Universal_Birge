// ═══════════════════════════════════════════════════════════════
// Authentication middleware — JWT tokeni yoxlayır
// ═══════════════════════════════════════════════════════════════

const { verify } = require('../utils/jwt');
const { query } = require('../config/database');
const { ApiError } = require('./errorHandler');

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new ApiError(401, 'Token təqdim edilməyib');
    }

    const token = authHeader.split(' ')[1];
    const decoded = verify(token);

    // İstifadəçini DB-dən oxu
    const result = await query(`
      SELECT u.id, u.full_name, u.email, u.role_id, r.code AS role_code
      FROM core.users u
      LEFT JOIN core.roles r ON u.role_id = r.id
      WHERE u.id = $1 AND u.is_active = true
    `, [decoded.userId]);

    if (result.rows.length === 0) {
      throw new ApiError(401, 'İstifadəçi tapılmadı və ya aktiv deyil');
    }

    req.user = result.rows[0];
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return next(new ApiError(401, 'Tokenin vaxtı bitib'));
    }
    if (err.name === 'JsonWebTokenError') {
      return next(new ApiError(401, 'Yanlış token'));
    }
    next(err);
  }
};

// Rolə görə icazə yoxlayır
const authorize = (...allowedRoles) => (req, res, next) => {
  if (!req.user) return next(new ApiError(401, 'Login olmayıb'));
  if (!allowedRoles.includes(req.user.role_code)) {
    return next(new ApiError(403, 'İcazə yoxdur'));
  }
  next();
};

module.exports = { authenticate, authorize };
