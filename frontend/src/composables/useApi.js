import axios from 'axios';
import { getUser } from '../services/authService';

const api = axios.create({
  baseURL: 'http://localhost:3000/api',
});

export async function useApi() {
  const user = await getUser();

  api.interceptors.request.use(async (config) => {
    if (user && user.access_token) {
      config.headers.Authorization = `Bearer ${user.access_token}`;
    }
    return config;
  });

  return api;
}
