<template>
  <div class="task-card card" :class="{ 'elderly-card': elderly }" @click="$emit('click')">
    <div class="task-header">
      <h3 :class="elderly ? 'elderly-title' : ''">{{ task.title }}</h3>
      <van-tag :type="statusTagType" :class="{ 'elderly-tag': elderly }">
        {{ statusMap[task.status] || task.status }}
      </van-tag>
    </div>

    <div class="task-info">
      <div v-if="task.category" class="info-item">
        <van-icon name="label-o" />
        <span>{{ categoryMap[task.category] || task.category }}</span>
      </div>
      <div v-if="task.planDate" class="info-item">
        <van-icon name="calendar-o" />
        <span>{{ formatDate(task.planDate) }}</span>
        <span v-if="task.planTime">{{ task.planTime }}</span>
      </div>
      <div v-if="task.location" class="info-item">
        <van-icon name="location-o" />
        <span>{{ task.location }}</span>
      </div>
      <div v-if="task.elderlyName" class="info-item">
        <van-icon name="user-o" />
        <span>{{ task.elderlyName }}</span>
      </div>
    </div>

    <div v-if="elderly && task.steps && task.steps.length > 0" class="task-progress">
      <span class="progress-text">
        已完成 {{ completedSteps }} / {{ task.steps.length }} 步
      </span>
      <van-progress :percentage="completedPercent" :color="'#43A047'" />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { TASK_STATUS, CATEGORIES } from '../utils/constants'

const props = defineProps({
  task: { type: Object, required: true },
  elderly: { type: Boolean, default: false }
})

defineEmits(['click'])

const statusMap = TASK_STATUS
const categoryMap = CATEGORIES

const statusTagType = computed(() => {
  const map = {
    PENDING: 'warning',
    IN_PROGRESS: 'primary',
    COMPLETED: 'success',
    CANCELLED: 'danger'
  }
  return map[props.task.status] || 'default'
})

const completedSteps = computed(() =>
  props.task.steps ? props.task.steps.filter(s => s.isCompleted).length : 0
)

const completedPercent = computed(() => {
  if (!props.task.steps || props.task.steps.length === 0) return 0
  return Math.round((completedSteps.value / props.task.steps.length) * 100)
})

function formatDate(val) {
  if (!val) return ''
  const d = new Date(val)
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}
</script>

<style scoped>
.task-card {
  cursor: pointer;
  transition: transform 0.1s;
}

.task-card:active {
  transform: scale(0.98);
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.task-header h3 {
  font-size: var(--font-lg);
  font-weight: 600;
  flex: 1;
  margin-right: 12px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.task-info {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 16px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: var(--font-sm);
  color: var(--text-secondary);
}

.task-progress {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--border-color);
}

.progress-text {
  font-size: var(--font-sm);
  color: var(--color-success);
  margin-bottom: 6px;
  display: block;
}

/* 适老化 */
.elderly-card .task-header h3 {
  font-size: var(--elderly-font-lg);
}

.elderly-card .info-item {
  font-size: var(--elderly-font-md);
}

.elderly-tag {
  font-size: var(--elderly-font-md) !important;
  padding: 6px 12px;
}
</style>
