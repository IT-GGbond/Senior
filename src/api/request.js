import axios from 'axios'
import { showToast } from 'vant'

const request = axios.create({
  baseURL: '/api',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器 - 注入 Token
request.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// 响应拦截器 - 统一错误处理
request.interceptors.response.use(
  (response) => {
    const { data } = response
    if (data.code !== 0) {
      const errorMessages = {
        40000: '请求参数错误',
        40100: '未登录，请先登录',
        40101: '无权限访问',
        40300: '禁止访问',
        40400: '数据不存在',
        50000: '服务异常，请稍后重试',
        50001: '操作失败'
      }
      const msg = errorMessages[data.code] || data.message || '请求失败'
      showToast(msg)
      if (data.code === 40100) {
        localStorage.removeItem('token')
        localStorage.removeItem('userInfo')
        window.location.href = '/login'
      }
      return Promise.reject(new Error(msg))
    }
    return data
  },
  (error) => {
    showToast('网络异常，请检查网络连接')
    return Promise.reject(error)
  }
)

export default request
