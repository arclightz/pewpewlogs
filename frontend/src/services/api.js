import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'http://localhost:5173', // Replace with your backend API base URL
  withCredentials: true,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
});

export const register = (user) => apiClient.post('/register', user);
export const login = (user) => apiClient.post('/login', user);
export const getUserDetails = () => apiClient.get('/user-detail');
export const updateUserDetails = (user) => apiClient.put('/user-detail', user);
export const createSession = (session) => apiClient.post('/sessions', session);
export const getSessions = () => apiClient.get('/sessions');
export const getSession = (id) => apiClient.get(`/sessions/${id}`);
export const updateSession = (id, session) => apiClient.put(`/sessions/${id}`, session);
export const deleteSession = (id) => apiClient.delete(`/sessions/${id}`);
export const addShots = (sessionId, shots) => apiClient.post(`/sessions/${sessionId}/shots`, shots);
export const getShots = (sessionId) => apiClient.get(`/sessions/${sessionId}/shots`);
export const getSessionStats = () => apiClient.get('/stats/sessions');
export const getShootingStats = () => apiClient.get('/stats/shots');
export const addNoteToSession = (sessionId, note) => apiClient.post(`/sessions/${sessionId}/notes`, note);
export const uploadSignature = (sessionId, signature) => apiClient.post(`/sessions/${sessionId}/signature`, signature);
export const uploadPhotos = (sessionId, photos) => apiClient.post(`/sessions/${sessionId}/photos`, photos);
export const exportSessionsToCSV = () => apiClient.get('/export/sessions/csv');
export const exportSessionsToPDF = () => apiClient.get('/export/sessions/pdf');
export const getWeapons = () => apiClient.get('/weapons');
export const addWeapon = (weapon) => apiClient.post('/weapons', weapon);

const api = {
  register,
  login,
  getUserDetails,
  updateUserDetails,
  createSession,
  getSessions,
  getSession,
  updateSession,
  deleteSession,
  addShots,
  getShots,
  getSessionStats,
  getShootingStats,
  addNoteToSession,
  uploadSignature,
  uploadPhotos,
  exportSessionsToCSV,
  exportSessionsToPDF,
  getWeapons,
  addWeapon,
};

export default api;