import request from './request'

export const createServiceRecord = (data) => request.post('/service/record', data)

export const getMyRecords = () => request.get('/service/my-records')

export const getMyStats = () => request.get('/service/my-stats')

export const submitReview = (data) => request.post('/service/review', data)

export const getVolunteerReviews = (volunteerId) => request.get(`/service/reviews/${volunteerId}`)
