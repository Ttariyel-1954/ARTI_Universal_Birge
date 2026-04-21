import client from './client';

export const authApi = {
  login: (credentials) => client.post('/auth/login', credentials),
  register: (data) => client.post('/auth/register', data),
  me: () => client.get('/auth/me'),
};
