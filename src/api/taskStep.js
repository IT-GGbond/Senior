import request from './request'

export const addStep = (taskId, data) =>
  request.post('/task-step', data, { params: { taskId } })

export const editStep = (id, data) => request.put(`/task-step/${id}`, data)

export const completeStep = (id) => request.put(`/task-step/${id}/complete`)

export const deleteStep = (id) => request.delete(`/task-step/${id}`)
