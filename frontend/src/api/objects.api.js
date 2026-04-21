import client from './client';

export const objectsApi = {
  list: () => client.get('/construction/objects'),
  get: (id) => client.get(`/construction/objects/${id}`),
};
