import request from './request'

export const createTask = (data) => request.post('/task', data)

export const getMyTasks = (status) => request.get('/task/my', { params: { status } })

export const getElderlyTasks = (elderlyId, status) =>
  request.get(`/task/elderly/${elderlyId}`, { params: { status } })

export const getTaskDetail = (id) => request.get(`/task/${id}`)

export const updateTaskStatus = (id, status) =>
  request.put(`/task/${id}/status`, null, { params: { status } })

export const deleteTask = (id) => request.delete(`/task/${id}`)
