import request from './request'

export const getOverview = () => request.get('/admin/overview')

export const getUsers = (role) => request.get('/admin/users', { params: { role } })

export const getHelpRequests = (status) => request.get('/admin/help-requests', { params: { status } })

export const getVolunteerStats = () => request.get('/admin/volunteer-stats')
