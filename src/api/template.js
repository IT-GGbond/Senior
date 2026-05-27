import request from './request'

export const createTemplate = (data) => request.post('/template/create', data)

export const getTemplateDetail = (id) => request.get(`/template/detail/${id}`)

export const getTemplateList = (category) => request.get('/template/list', { params: { category } })

export const deleteTemplate = (id) => request.delete(`/template/delete/${id}`)
