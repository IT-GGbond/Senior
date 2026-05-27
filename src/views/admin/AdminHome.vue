<template>
  <StandardLayout
    title="管理后台"
    show-back="false"
    :tabs="tabs"
  >
    <div class="admin-home">
      <h2 class="page-title">数据概览</h2>

      <!-- 统计卡片 -->
      <div class="overview-grid" v-if="overview">
        <div class="overview-card card">
          <van-icon name="friends-o" size="24" color="#FF8C00" />
          <span class="ov-value">{{ overview.elderlyCount || 0 }}</span>
          <span class="ov-label">老人</span>
        </div>
        <div class="overview-card card">
          <van-icon name="home-o" size="24" color="#2C5F8A" />
          <span class="ov-value">{{ overview.familyCount || 0 }}</span>
          <span class="ov-label">家属</span>
        </div>
        <div class="overview-card card">
          <van-icon name="like-o" size="24" color="#43A047" />
          <span class="ov-value">{{ overview.volunteerCount || 0 }}</span>
          <span class="ov-label">志愿者</span>
        </div>
        <div class="overview-card card">
          <van-icon name="orders-o" size="24" color="#E53935" />
          <span class="ov-value">{{ overview.taskCount || 0 }}</span>
          <span class="ov-label">任务总数</span>
        </div>
        <div class="overview-card card">
          <van-icon name="phone-o" size="24" color="#FFA000" />
          <span class="ov-value">{{ overview.helpCount || 0 }}</span>
          <span class="ov-label">求助总数</span>
        </div>
        <div class="overview-card card">
          <van-icon name="clock-o" size="24" color="#1976D2" />
          <span class="ov-value">{{ formatDuration(overview.totalServiceDuration) }}</span>
          <span class="ov-label">服务时长(时)</span>
        </div>
      </div>

      <div v-else class="loading-wrap">
        <van-loading />
      </div>

      <!-- 快捷入口 -->
      <div class="menu-section card">
        <van-cell title="流程模板管理" icon="notes-o" is-link @click="$router.push('/admin/templates')" />
        <van-cell title="求助管理" icon="phone-o" is-link @click="$router.push('/admin/help')" />
        <van-cell title="用户管理" icon="friends-o" is-link @click="$router.push('/admin/users')" />
        <van-cell title="志愿者统计" icon="bar-chart-o" is-link @click="$router.push('/admin/volunteers')" />
      </div>
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import StandardLayout from '../../components/StandardLayout.vue'
import { getOverview } from '../../api/admin'

const overview = ref(null)

const tabs = [
  { name: 'home', label: '概览', icon: 'home-o', route: '/admin/home' },
  { name: 'templates', label: '模板', icon: 'notes-o', route: '/admin/templates' },
  { name: 'users', label: '用户', icon: 'friends-o', route: '/admin/users' }
]

function formatDuration(minutes) {
  if (!minutes) return '0'
  return (minutes / 60).toFixed(1)
}

async function loadOverview() {
  try {
    const res = await getOverview()
    overview.value = res.data
  } catch (e) { /* */ }
}

onMounted(loadOverview)
</script>

<style scoped>
.admin-home {
  padding: var(--spacing-md);
}

.page-title {
  font-size: var(--font-xl);
  font-weight: 600;
  margin-bottom: var(--spacing-md);
}

.overview-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-bottom: 24px;
}

.overview-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 20px 8px;
  text-align: center;
}

.ov-value {
  font-size: 28px;
  font-weight: 700;
  color: var(--text-primary);
}

.ov-label {
  font-size: var(--font-sm);
  color: var(--text-hint);
}

.loading-wrap {
  display: flex;
  justify-content: center;
  padding: 40px 0;
}

.menu-section {
  margin-top: var(--spacing-md);
}
</style>
