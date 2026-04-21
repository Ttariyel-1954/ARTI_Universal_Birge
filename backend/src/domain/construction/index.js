const express = require('express');
const router = express.Router();

const projectsRoutes = require('./routes/projects.routes');
const objectsRoutes = require('./routes/objects.routes');
const teamsRoutes = require('./routes/teams.routes');

router.use('/projects', projectsRoutes);
router.use('/objects', objectsRoutes);
router.use('/teams', teamsRoutes);

module.exports = router;
