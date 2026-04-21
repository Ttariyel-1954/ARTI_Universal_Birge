const service = require('../services/objects.service');
const { ApiError } = require('../../../core/middleware/errorHandler');

const list = async (req, res, next) => {
  try {
    const data = await service.findAll();
    res.json({ data, count: data.length });
  } catch (err) { next(err); }
};

const get = async (req, res, next) => {
  try {
    const obj = await service.findById(req.params.id);
    if (!obj) throw new ApiError(404, 'Obyekt tapılmadı');
    res.json({ data: obj });
  } catch (err) { next(err); }
};

module.exports = { list, get };
