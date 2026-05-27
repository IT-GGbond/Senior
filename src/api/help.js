import request from './request'

export const createHelp = (data) => request.post('/help', data)

export const getWaitingHelp = (community) =>
  request.get('/help/waiting', { params: { community } })

export const getMyHelp = () => request.get('/help/my')

export const getElderlyHelp = (elderlyId) => request.get(`/help/elderly/${elderlyId}`)

export const acceptHelp = (id) => request.put(`/help/${id}/accept`)

export const completeHelp = (id) => request.put(`/help/${id}/complete`)

export const cancelHelp = (id) => request.put(`/help/${id}/cancel`)
