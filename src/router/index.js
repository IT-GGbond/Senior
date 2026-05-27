import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/common/LoginView.vue'),
    meta: { guest: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../views/common/RegisterView.vue'),
    meta: { guest: true }
  },
  // 老人端
  {
    path: '/elderly/home',
    name: 'ElderlyHome',
    component: () => import('../views/elderly/ElderlyHome.vue'),
    meta: { role: 'ELDERLY' }
  },
  {
    path: '/elderly/tasks',
    name: 'ElderlyTasks',
    component: () => import('../views/elderly/ElderlyTasks.vue'),
    meta: { role: 'ELDERLY' }
  },
  {
    path: '/elderly/task/:id',
    name: 'TaskDetail',
    component: () => import('../views/elderly/TaskDetail.vue'),
    meta: { role: 'ELDERLY' }
  },
  {
    path: '/elderly/help',
    name: 'MyHelp',
    component: () => import('../views/elderly/MyHelp.vue'),
    meta: { role: 'ELDERLY' }
  },
  {
    path: '/elderly/profile',
    name: 'ElderlyProfile',
    component: () => import('../views/elderly/ElderlyProfile.vue'),
    meta: { role: 'ELDERLY' }
  },
  // 家属端
  {
    path: '/family/home',
    name: 'FamilyHome',
    component: () => import('../views/family/FamilyHome.vue'),
    meta: { role: 'FAMILY' }
  },
  {
    path: '/family/elderly/:elderlyId/tasks',
    name: 'FamilyElderlyTasks',
    component: () => import('../views/family/ElderlyTasks.vue'),
    meta: { role: 'FAMILY' }
  },
  {
    path: '/family/task/create/:elderlyId?',
    name: 'TaskForm',
    component: () => import('../views/family/TaskForm.vue'),
    meta: { role: 'FAMILY' }
  },
  {
    path: '/family/task/:id',
    name: 'FamilyTaskDetail',
    component: () => import('../views/family/FamilyTaskDetail.vue'),
    meta: { role: 'FAMILY' }
  },
  {
    path: '/family/bind',
    name: 'BindElderly',
    component: () => import('../views/family/BindElderly.vue'),
    meta: { role: 'FAMILY' }
  },
  {
    path: '/family/profile',
    name: 'FamilyProfile',
    component: () => import('../views/family/FamilyProfile.vue'),
    meta: { role: 'FAMILY' }
  },
  // 志愿者端
  {
    path: '/volunteer/home',
    name: 'HelpHall',
    component: () => import('../views/volunteer/HelpHall.vue'),
    meta: { role: 'VOLUNTEER' }
  },
  {
    path: '/volunteer/orders',
    name: 'MyOrders',
    component: () => import('../views/volunteer/MyOrders.vue'),
    meta: { role: 'VOLUNTEER' }
  },
  {
    path: '/volunteer/record/:helpId',
    name: 'ServiceRecord',
    component: () => import('../views/volunteer/ServiceRecord.vue'),
    meta: { role: 'VOLUNTEER' }
  },
  {
    path: '/volunteer/profile',
    name: 'VolunteerProfile',
    component: () => import('../views/volunteer/VolunteerProfile.vue'),
    meta: { role: 'VOLUNTEER' }
  },
  // 管理员端
  {
    path: '/admin/home',
    name: 'AdminHome',
    component: () => import('../views/admin/AdminHome.vue'),
    meta: { role: 'ADMIN' }
  },
  {
    path: '/admin/templates',
    name: 'TemplateManage',
    component: () => import('../views/admin/TemplateManage.vue'),
    meta: { role: 'ADMIN' }
  },
  {
    path: '/admin/help',
    name: 'HelpManage',
    component: () => import('../views/admin/HelpManage.vue'),
    meta: { role: 'ADMIN' }
  },
  {
    path: '/admin/users',
    name: 'UserManage',
    component: () => import('../views/admin/UserManage.vue'),
    meta: { role: 'ADMIN' }
  },
  {
    path: '/admin/volunteers',
    name: 'VolunteerManage',
    component: () => import('../views/admin/VolunteerManage.vue'),
    meta: { role: 'ADMIN' }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/login'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const userStore = useUserStore()

  // 允许未登录访问的页面
  if (to.meta.guest) {
    if (userStore.isLoggedIn) {
      return next(userStore.homeRoute)
    }
    return next()
  }

  // 需要登录
  if (!userStore.isLoggedIn) {
    return next('/login')
  }

  // 角色校验
  if (to.meta.role) {
    const role = userStore.activeRole || userStore.roles[0]
    if (!role || role !== to.meta.role) {
      // 如果是多角色用户，尝试切换到匹配角色
      if (userStore.roles.includes(to.meta.role)) {
        userStore.switchRole(to.meta.role)
        return next()
      }
      return next(userStore.homeRoute)
    }
  }

  next()
})

export default router
