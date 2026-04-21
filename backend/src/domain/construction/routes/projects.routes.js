const express = require('express');
const Joi = require('joi');
const router = express.Router();

const controller = require('../controllers/projects.controller');
const { authenticate, authorize } = require('../../../core/middleware/auth');
const validate = require('../../../core/middleware/validate');

const createSchema = Joi.object({
  project_code: Joi.string().max(50).required(),
  object_id: Joi.number().integer().required(),
  manager_id: Joi.number().integer().optional(),
  name: Joi.string().min(5).max(500).required(),
  description: Joi.string().optional(),
  project_type: Joi.string().valid('new_build', 'major_repair', 'current_repair', 'reconstruction').required(),
  start_date_planned: Joi.date().optional(),
  end_date_planned: Joi.date().optional(),
  total_budget_planned: Joi.number().positive().optional()
});

// Bütün route-lar auth tələb edir
router.use(authenticate);

router.get('/', controller.list);
router.get('/:id', controller.get);
router.post('/', authorize('super_admin', 'admin', 'manager'), validate(createSchema), controller.create);
router.put('/:id', authorize('super_admin', 'admin', 'manager'), controller.update);
router.delete('/:id', authorize('super_admin', 'admin'), controller.remove);

module.exports = router;

router.post('/:id/analyze', controller.analyze);
