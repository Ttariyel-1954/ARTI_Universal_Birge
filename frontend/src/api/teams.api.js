import client from './client';

export const teamsApi = {
  list: () => client.get('/construction/teams'),
  get: (id) => client.get(`/construction/teams/${id}`),
};
