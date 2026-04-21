const service = require('../services/teams.service');
const { ApiError } = require('../../../core/middleware/errorHandler');

const list = async (req, res, next) => {
  try {
    const data = await service.findAll();
    res.json({ data, count: data.length });
  } catch (err) { next(err); }
};

const get = async (req, res, next) => {
  try {
    const team = await service.findById(req.params.id);
    if (!team) throw new ApiError(404, 'Briqada tapılmadı');
    res.json({ data: team });
  } catch (err) { next(err); }
};

module.exports = { list, get };
