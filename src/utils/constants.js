// 角色枚举
export const ROLES = {
  ELDERLY: '老人',
  FAMILY: '家属',
  VOLUNTEER: '志愿者',
  ADMIN: '管理员'
}

export const ROLE_LIST = [
  { value: 'ELDERLY', label: '老人', desc: '查看任务、办事流程、求助' },
  { value: 'FAMILY', label: '家属', desc: '绑定老人、代建任务、查看进度' },
  { value: 'VOLUNTEER', label: '志愿者', desc: '接单求助、提供服务' },
  { value: 'ADMIN', label: '管理员', desc: '后台管理' }
]

export const REGISTERABLE_ROLES = ['ELDERLY', 'FAMILY', 'VOLUNTEER']

// 任务状态
export const TASK_STATUS = {
  PENDING: '待办',
  IN_PROGRESS: '进行中',
  COMPLETED: '已完成',
  CANCELLED: '已取消'
}

// 求助状态
export const HELP_STATUS = {
  WAITING: '待接单',
  ACCEPTED: '已接单',
  IN_SERVICE: '服务中',
  COMPLETED: '已完成',
  CANCELLED: '已取消'
}

// 业务分类
export const CATEGORIES = {
  GOVERNMENT: '政务帮办',
  LIFE: '生活协助',
  HEALTH: '健康支持',
  COMMUNITY: '社区连接'
}

export const CATEGORY_LIST = [
  { value: 'GOVERNMENT', label: '政务帮办' },
  { value: 'LIFE', label: '生活协助' },
  { value: 'HEALTH', label: '健康支持' },
  { value: 'COMMUNITY', label: '社区连接' }
]

// 服务方式
export const SERVICE_TYPES = {
  ONLINE: '线上指导',
  OFFLINE: '线下协助'
}

export const SERVICE_TYPE_OPTIONS = [
  { value: 'ONLINE', label: '线上指导' },
  { value: 'OFFLINE', label: '线下协助' }
]

// 家属与老人关系
export const RELATION_OPTIONS = [
  { value: '子女', label: '子女' },
  { value: '配偶', label: '配偶' },
  { value: '亲属', label: '亲属' },
  { value: '其他', label: '其他' }
]
