import { ref } from 'vue';
import api from '../services/api';

export function useSessions() {
  const getSessions = async () => {
    try {
      const response = await api.getSessions();
      return response.data;
    } catch (error) {
      console.error('Error fetching sessions:', error);
      throw error;
    }
  };

  const getSession = async (sessionId) => {
    try {
      const response = await api.getSession(sessionId);
      return response.data;
    } catch (error) {
      console.error('Error fetching session:', error);
      throw error;
    }
  };

  const createSession = async (sessionData) => {
    try {
      const response = await api.createSession(sessionData);
      return response.data;
    } catch (error) {
      console.error('Error creating session:', error);
      throw error;
    }
  };

  const updateSession = async (sessionId, sessionData) => {
    try {
      const response = await api.updateSession(sessionId, sessionData);
      return response.data;
    } catch (error) {
      console.error('Error updating session:', error);
      throw error;
    }
  };

  const deleteSession = async (sessionId) => {
    try {
      await api.deleteSession(sessionId);
    } catch (error) {
      console.error('Error deleting session:', error);
      throw error;
    }
  };

  return {
    getSessions,
    getSession,
    createSession,
    updateSession,
    deleteSession,
  };
}