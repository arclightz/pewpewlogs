// Placeholder for the API calls to the backend
import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'http://localhost:3000', // Replace with your backend API base URL
  withCredentials: true, // Change this if you need to handle credentials
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
});

// User Authentication
export function register(user) {
  return apiClient.post('/register', user);
}

export function login(user) {
  return apiClient.post('/login', user);
}

export function getUserDetails() {
  return apiClient.get('/user-detail');
}

export function updateUserDetails(user) {
  return apiClient.put('/user-detail', user);
}

// Session Logging
export function createSession(session) {
  return apiClient.post('/sessions', session);
}

export function getSessions() {
  return apiClient.get('/sessions');
}

export function getSession(id) {
  return apiClient.get(`/sessions/${id}`);
}

export function updateSession(id, session) {
  return apiClient.put(`/sessions/${id}`, session);
}

export function deleteSession(id) {
  return apiClient.delete(`/sessions/${id}`);
}

// Shot Tracking
export function addShots(sessionId, shots) {
  return apiClient.post(`/sessions/${sessionId}/shots`, shots);
}

export function getShots(sessionId) {
  return apiClient.get(`/sessions/${sessionId}/shots`);
}

// Statistics and Analytics
export function getSessionStats() {
  return apiClient.get('/stats/sessions');
}

export function getShootingStats() {
  return apiClient.get('/stats/shots');
}

// Additional Features
export function addNoteToSession(sessionId, note) {
  return apiClient.post(`/sessions/${sessionId}/notes`, note);
}

export function uploadSignature(sessionId, signature) {
  return apiClient.post(`/sessions/${sessionId}/signature`, signature);
}

export function uploadPhotos(sessionId, photos) {
  return apiClient.post(`/sessions/${sessionId}/photos`, photos);
}

// Export Data
export function exportSessionsToCSV() {
  return apiClient.get('/export/sessions/csv');
}

export function exportSessionsToPDF() {
  return apiClient.get('/export/sessions/pdf');
}

// Weapons Management
export function getWeapons() {
  return apiClient.get('/weapons');
}

export function addWeapon(weapon) {
  return apiClient.post('/weapons', weapon);
}