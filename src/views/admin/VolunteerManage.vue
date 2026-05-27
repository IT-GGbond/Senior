<template>
  <StandardLayout title="志愿者统计" :show-back="true" :show-tabbar="false">
    <div class="volunteer-manage">
      <div v-if="volunteers.length > 0">
        <div
          v-for="v in volunteers"
          :key="v.volunteerId"
          class="volunteer-card card"
        >
          <div class="v-header">
            <h4>{{ v.volunteerName || '志愿者' }}</h4>
          </div>
          <div class="v-stats">
            <div class="v-stat">
              <span class="v-value">{{ v.totalCount || 0 }}</span>
              <span class="v-label">服务次数</span>
            </div>
            <div class="v-stat">
              <span class="v-value">{{ formatDuration(v.totalDuration) }}</span>
              <span class="v-label">时长(时)</span>
            </div>
            <div class="v-stat">
              <span class="v-value">{{ v.totalPoints || 0 }}</span>
              <span class="v-label">积分</span>
            </div>
          </div>
        </div>
      </div>
      <EmptyState v-else description="暂无志愿者数据" />
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import StandardLayout from '../../components/StandardLayout.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getVolunteerStats } from '../../api/admin'

const volunteers = ref([])

function formatDuration(minutes) {
  if (!minutes) return '0'
  return (minutes / 60).toFixed(1)
}

async function loadStats() {
  try {
    const res = await getVolunteerStats()
    volunteers.value = res.data || []
  } catch (e) { /* */ }
}

onMounted(loadStats)
</script>

<style scoped>
.volunteer-manage {
  padding: var(--spacing-md);
}

.volunteer-card {
  margin-bottom: var(--spacing-sm);
}

.v-header {
  margin-bottom: 12px;
}

.v-header h4 {
  font-size: var(--font-lg);
  font-weight: 600;
}

.v-stats {
  display: flex;
  gap: 16px;
}

.v-stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
}

.v-value {
  font-size: 20px;
  font-weight: 700;
  color: var(--color-primary);
}

.v-label {
  font-size: var(--font-sm);
  color: var(--text-hint);
}
</style>
