// ═══════════════════════════════════════════════════════════════
// Authentication endpoints — register, login, me
// ═══════════════════════════════════════════════════════════════

const express = require('express');
const Joi = require('joi');
const router = express.Router();

const { query } = require('../config/database');
const { hash, verify } = require('../utils/password');
const { sign } = require('../utils/jwt');
const { authenticate } = require('../middleware/auth');
const validate = require('../middleware/validate');
const { ApiError } = require('../middleware/errorHandler');

// ═══ Validation sxemləri ═══
const registerSchema = Joi.object({
  full_name: Joi.string().min(3).max(200).required(),
  email: Joi.string().email().required(),
  phone: Joi.string().pattern(/^\+?[0-9]{8,15}$/).optional(),
  password: Joi.string().min(8).required(),
  role_code: Joi.string().valid('manager', 'inspector', 'viewer').default('viewer')
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});

// ═══ POST /auth/register ═══
router.post('/register', validate(registerSchema), async (req, res, next) => {
  try {
    const { full_name, email, phone, password, role_code } = req.body;

    // Email unikallığını yoxla
    const existing = await query('SELECT id FROM core.users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      throw new ApiError(409, 'Bu email artıq qeydiyyatdan keçib');
    }

    // Rolun id-sini tap
    const roleResult = await query('SELECT id FROM core.roles WHERE code = $1', [role_code]);
    if (roleResult.rows.length === 0) {
      throw new ApiError(400, 'Rol tapılmadı');
    }

    // Parolu hash et
    const passwordHash = await hash(password);

    // Yeni istifadəçi yarat
    const result = await query(`
      INSERT INTO core.users (full_name, email, phone, password_hash, role_id)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, full_name, email, role_id, created_at
    `, [full_name, email, phone, passwordHash, roleResult.rows[0].id]);

    const user = result.rows[0];
    const token = sign({ userId: user.id });

    res.status(201).json({ user, token });
  } catch (err) { next(err); }
});

// ═══ POST /auth/login ═══
router.post('/login', validate(loginSchema), async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const result = await query(`
      SELECT u.id, u.full_name, u.email, u.password_hash, u.is_active, r.code AS role_code
      FROM core.users u
      LEFT JOIN core.roles r ON u.role_id = r.id
      WHERE u.email = $1
    `, [email]);

    if (result.rows.length === 0) {
      throw new ApiError(401, 'Email və ya şifrə yanlışdır');
    }

    const user = result.rows[0];
    if (!user.is_active) {
      throw new ApiError(403, 'Hesab bloklanıb');
    }

    const isValid = await verify(password, user.password_hash);
    if (!isValid) {
      throw new ApiError(401, 'Email və ya şifrə yanlışdır');
    }

    // last_login_at yenilə
    await query('UPDATE core.users SET last_login_at = NOW() WHERE id = $1', [user.id]);

    const token = sign({ userId: user.id });

    res.json({
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role_code: user.role_code
      },
      token
    });
  } catch (err) { next(err); }
});

// ═══ GET /auth/me — cari istifadəçi ═══
router.get('/me', authenticate, (req, res) => {
  res.json({ user: req.user });
});

module.exports = router;
