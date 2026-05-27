import request from './request'

export const addMaterial = (taskId, name) =>
  request.post('/task-material', null, { params: { taskId, name } })

export const checkMaterial = (id, checked) =>
  request.put(`/task-material/${id}/check`, null, { params: { checked } })

export const deleteMaterial = (id) => request.delete(`/task-material/${id}`)
