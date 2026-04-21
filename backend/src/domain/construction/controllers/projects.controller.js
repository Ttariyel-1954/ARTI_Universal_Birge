const service = require('../services/projects.service');
const { ApiError } = require('../../../core/middleware/errorHandler');

const list = async (req, res, next) => {
  try {
    const projects = await service.findAll(req.query);
    res.json({ data: projects, count: projects.length });
  } catch (err) { next(err); }
};

const get = async (req, res, next) => {
  try {
    const project = await service.findById(req.params.id);
    if (!project) throw new ApiError(404, 'Layihə tapılmadı');
    res.json({ data: project });
  } catch (err) { next(err); }
};

const create = async (req, res, next) => {
  try {
    const project = await service.create(req.body, req.user.id);
    res.status(201).json({ data: project });
  } catch (err) { next(err); }
};

const update = async (req, res, next) => {
  try {
    const project = await service.update(req.params.id, req.body);
    if (!project) throw new ApiError(404, 'Layihə tapılmadı');
    res.json({ data: project });
  } catch (err) { next(err); }
};

const remove = async (req, res, next) => {
  try {
    const deleted = await service.remove(req.params.id);
    if (!deleted) throw new ApiError(404, 'Layihə tapılmadı');
    res.json({ message: 'Layihə silindi', id: deleted.id });
  } catch (err) { next(err); }
};

module.exports = { list, get, create, update, remove };

// ═══ Claude AI ilə layihə təhlili ═══
const claude = require('../../../shared/ai/claude');

const analyze = async (req, res, next) => {
  try {
    const project = await service.findById(req.params.id);
    if (!project) throw new ApiError(404, 'Layihə tapılmadı');

    const analysis = await claude.analyzeProject(project);

    res.json({
      project_id: project.id,
      analysis: analysis,
      generated_at: new Date().toISOString()
    });
  } catch (err) { next(err); }
};

module.exports.analyze = analyze;
