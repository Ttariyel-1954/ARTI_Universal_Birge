const express = require('express');
const router = express.Router();
const controller = require('../controllers/teams.controller');
const { authenticate } = require('../../../core/middleware/auth');

router.use(authenticate);
router.get('/', controller.list);
router.get('/:id', controller.get);

module.exports = router;
