import request from './request'

export const bindElderly = (data) => request.post('/binding', data)

export const getMyElderly = () => request.get('/binding/my-elderly')

export const getMyFamily = () => request.get('/binding/my-family')

export const unbind = (id) => request.delete(`/binding/${id}`)
