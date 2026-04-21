import client from './client';

export const projectsApi = {
  list: (params = {}) => client.get('/construction/projects', { params }),
  get: (id) => client.get(`/construction/projects/${id}`),
  create: (data) => client.post('/construction/projects', data),
  update: (id, data) => client.put(`/construction/projects/${id}`, data),
  remove: (id) => client.delete(`/construction/projects/${id}`),
  analyze: (id) => client.post(`/construction/projects/${id}/analyze`),
};
