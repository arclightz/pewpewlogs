import axios from 'axios'
import { useKindeAuth } from '@kinde-oss/kinde-auth-vue'

const api = axios.create({
  baseURL: 'http://localhost:3000/api',
})

export function useApi() {
  const { getToken } = useKindeAuth()

  api.interceptors.request.use(async (config) => {
    const token = await getToken()
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  })

  return api
}