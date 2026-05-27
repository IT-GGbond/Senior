import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as loginApi, register as registerApi, getUserInfo } from '../api/user'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || 'null'))
  const activeRole = ref(localStorage.getItem('activeRole') || '')

  const isLoggedIn = computed(() => !!token.value)

  const roles = computed(() => userInfo.value?.roles || [])

  const isElderly = computed(() => roles.value.includes('ELDERLY'))
  const isFamily = computed(() => roles.value.includes('FAMILY'))
  const isVolunteer = computed(() => roles.value.includes('VOLUNTEER'))
  const isAdmin = computed(() => roles.value.includes('ADMIN'))

  // 根据当前活跃角色获取首页路由
  const homeRoute = computed(() => {
    const role = activeRole.value || roles.value[0]
    const routeMap = {
      ELDERLY: '/elderly/home',
      FAMILY: '/family/home',
      VOLUNTEER: '/volunteer/home',
      ADMIN: '/admin/home'
    }
    return routeMap[role] || '/login'
  })

  function setToken(val) {
    token.value = val
    localStorage.setItem('token', val)
  }

  function setUserInfo(info) {
    userInfo.value = info
    localStorage.setItem('userInfo', JSON.stringify(info))
  }

  function setActiveRole(role) {
    activeRole.value = role
    localStorage.setItem('activeRole', role)
  }

  async function doLogin(code) {
    const res = await loginApi(code)
    if (res.data.registered) {
      setToken(res.data.token)
      setUserInfo(res.data.userInfo)
      const firstRole = res.data.userInfo.roles[0]
      setActiveRole(firstRole)
    }
    return res.data
  }

  async function doRegister(data) {
    const res = await registerApi(data)
    if (res.data.token) {
      setToken(res.data.token)
      setUserInfo(res.data.userInfo)
      setActiveRole(data.roles[0])
    }
    return res.data
  }

  async function fetchUserInfo() {
    const res = await getUserInfo()
    setUserInfo(res.data)
    return res.data
  }

  function switchRole(role) {
    setActiveRole(role)
  }

  function logout() {
    token.value = ''
    userInfo.value = null
    activeRole.value = ''
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    localStorage.removeItem('activeRole')
  }

  return {
    token,
    userInfo,
    activeRole,
    isLoggedIn,
    roles,
    isElderly,
    isFamily,
    isVolunteer,
    isAdmin,
    homeRoute,
    setToken,
    setUserInfo,
    setActiveRole,
    doLogin,
    doRegister,
    fetchUserInfo,
    switchRole,
    logout
  }
})
