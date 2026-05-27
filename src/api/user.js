import request from './request'

export const login = (code) => request.post('/user/login', { code })

export const register = (data) => request.post('/user/register', data)

export const getUserInfo = () => request.get('/user/info')

export const updateUserInfo = (data) => request.put('/user/info', data)

export const getInviteCode = () => request.get('/user/invite-code')
