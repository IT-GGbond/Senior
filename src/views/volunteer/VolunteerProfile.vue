<template>
  <StandardLayout title="个人中心" :tabs="tabs">
    <div class="volunteer-profile">
      <!-- 统计卡片 -->
      <div class="stats-cards">
        <div class="stat-card card">
          <span class="stat-value">{{ stats.totalCount || 0 }}</span>
          <span class="stat-label">服务次数</span>
        </div>
        <div class="stat-card card">
          <span class="stat-value">{{ formatDuration(stats.totalDuration) }}</span>
          <span class="stat-label">服务时长(时)</span>
        </div>
        <div class="stat-card card">
          <span class="stat-value">{{ stats.totalPoints || 0 }}</span>
          <span class="stat-label">积分</span>
        </div>
      </div>

      <!-- 个人信息 -->
      <div class="user-card card">
        <van-image round width="56" height="56" :src="userInfo.avatarUrl || ''">
          <template #loading>
            <van-icon name="user-o" size="36" color="#CCC" />
          </template>
        </van-image>
        <div class="user-info">
          <span class="user-name">{{ userInfo.name || userInfo.nickname || '未设置' }}</span>
          <span class="user-phone">{{ userInfo.phone || '未绑定手机号' }}</span>
        </div>
      </div>

      <div class="menu-section card">
        <van-cell title="编辑资料" icon="edit" is-link @click="showEditPopup = true" />
        <van-cell title="我的接单记录" icon="orders-o" is-link @click="$router.push('/volunteer/orders')" />
        <van-cell title="求助大厅" icon="search" is-link @click="$router.push('/volunteer/home')" />
        <van-cell title="服务证明" icon="certificate" is-link @click="generateCertificate" />
      </div>

      <!-- 收到的评价 -->
      <div class="reviews-section card" v-if="reviews.length > 0">
        <h3 class="section-title">收到的评价</h3>
        <div
          v-for="review in reviews"
          :key="review.id"
          class="review-item"
        >
          <div class="review-header">
            <van-rate :model-value="review.rating" :size="16" readonly color="#FF8C00" />
            <span class="review-date">{{ formatDate(review.createTime) }}</span>
          </div>
          <p class="review-comment" v-if="review.comment">{{ review.comment }}</p>
          <p class="review-comment review-empty" v-else>用户未留下评语</p>
        </div>
      </div>

      <!-- 角色切换 -->
      <div class="menu-section card" v-if="userStore.roles.length > 1">
        <div class="section-label">切换角色</div>
        <van-cell
          v-for="role in userStore.roles"
          :key="role"
          :title="roleMap[role]"
          :value="role === userStore.activeRole ? '当前' : ''"
          @click="switchRole(role)"
        />
      </div>

      <van-button round block class="logout-btn" @click="handleLogout">退出登录</van-button>

      <!-- 编辑弹窗 -->
      <van-popup v-model:show="showEditPopup" position="bottom" round :style="{ padding: '24px' }">
        <h3 class="popup-title">编辑资料</h3>
        <van-field v-model="editForm.name" label="姓名" placeholder="请输入姓名" />
        <van-field v-model="editForm.phone" label="手机号" placeholder="请输入手机号" />
        <van-field v-model="editForm.community" label="所在社区" placeholder="请输入社区" />
        <van-button type="primary" round block :loading="saving" class="save-btn" @click="saveProfile">保存</van-button>
      </van-popup>
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import StandardLayout from '../../components/StandardLayout.vue'
import { useUserStore } from '../../stores/user'
import { updateUserInfo } from '../../api/user'
import { getMyStats, getVolunteerReviews } from '../../api/service'

const router = useRouter()
const userStore = useUserStore()

const tabs = [
  { name: 'home', label: '求助大厅', icon: 'search', route: '/volunteer/home' },
  { name: 'orders', label: '我的接单', icon: 'orders-o', route: '/volunteer/orders' },
  { name: 'profile', label: '我的', icon: 'user-o', route: '/volunteer/profile' }
]
const userInfo = computed(() => userStore.userInfo || {})

const roleMap = { ELDERLY: '老人', FAMILY: '家属', VOLUNTEER: '志愿者', ADMIN: '管理员' }

const stats = ref({ totalCount: 0, totalDuration: 0, totalPoints: 0 })
const reviews = ref([])
const showEditPopup = ref(false)
const saving = ref(false)
const editForm = ref({ name: '', phone: '', community: '' })

function formatDuration(minutes) {
  if (!minutes) return '0'
  return (minutes / 60).toFixed(1)
}

function switchRole(role) {
  userStore.switchRole(role)
  const routeMap = {
    ELDERLY: '/elderly/home',
    FAMILY: '/family/home',
    VOLUNTEER: '/volunteer/home',
    ADMIN: '/admin/home'
  }
  router.replace(routeMap[role] || '/')
}

async function saveProfile() {
  saving.value = true
  try {
    await updateUserInfo({
      name: editForm.value.name,
      phone: editForm.value.phone,
      community: editForm.value.community
    })
    await userStore.fetchUserInfo()
    showToast('保存成功')
    showEditPopup.value = false
  } catch (e) { /* */ }
  finally { saving.value = false }
}

function generateCertificate() {
  const cert = `志愿服务证明\n\n姓名：${userInfo.value.name || '未填写'}\n累计服务：${stats.value.totalCount} 次\n总时长：${formatDuration(stats.value.totalDuration)} 小时\n总积分：${stats.value.totalPoints} 分\n\n感谢您的无私奉献！`
  showToast('服务证明功能需要后端配合导出，当前版本已展示证明内容')
}

function handleLogout() {
  userStore.logout()
  router.replace('/login')
}

async function loadStats() {
  try {
    const res = await getMyStats()
    if (res.data) stats.value = res.data
  } catch (e) { /* */ }
}

async function loadReviews() {
  try {
    const userId = userStore.userInfo?.id
    if (!userId) return
    const res = await getVolunteerReviews(userId)
    reviews.value = res.data || []
  } catch (e) { /* */ }
}

function formatDate(val) {
  if (!val) return ''
  const d = new Date(val)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

onMounted(() => {
  loadStats()
  loadReviews()
  editForm.value = {
    name: userInfo.value.name || '',
    phone: userInfo.value.phone || '',
    community: userInfo.value.community || ''
  }
})
</script>

<style scoped>
.volunteer-profile {
  padding: var(--spacing-md);
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-bottom: var(--spacing-md);
}

.stat-card {
  text-align: center;
  padding: 16px 8px;
}

.stat-value {
  display: block;
  font-size: 24px;
  font-weight: 700;
  color: var(--color-primary);
  margin-bottom: 4px;
}

.stat-label {
  font-size: var(--font-sm);
  color: var(--text-hint);
}

.user-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px;
  margin-bottom: var(--spacing-md);
}

.user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.user-name {
  font-size: var(--font-xl);
  font-weight: 600;
}

.user-phone {
  font-size: var(--font-md);
  color: var(--text-hint);
}

.menu-section {
  margin-bottom: var(--spacing-md);
}

.section-label {
  padding: 12px 16px 4px;
  font-size: var(--font-sm);
  color: var(--text-hint);
}

.logout-btn {
  margin-top: 32px;
  height: 48px;
  color: var(--text-hint);
  border-color: var(--border-color);
}

.popup-title {
  font-size: var(--font-xl);
  font-weight: 600;
  margin-bottom: 16px;
  text-align: center;
}

.save-btn {
  margin-top: 24px;
  height: 48px;
}

.reviews-section {
  margin-bottom: var(--spacing-md);
}

.section-title {
  font-size: var(--font-lg);
  font-weight: 600;
  margin-bottom: var(--spacing-sm);
}

.review-item {
  padding: 14px 0;
  border-bottom: 1px solid var(--border-color);
}

.review-item:last-child {
  border-bottom: none;
}

.review-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}

.review-date {
  font-size: var(--font-sm);
  color: var(--text-hint);
}

.review-comment {
  font-size: var(--font-md);
  color: var(--text-secondary);
  line-height: 1.5;
}

.review-empty {
  font-style: italic;
  color: var(--text-hint);
}
</style>
