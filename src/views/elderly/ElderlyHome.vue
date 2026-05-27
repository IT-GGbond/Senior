<template>
  <ElderlyLayout title="银龄配办">
    <div class="elderly-home elderly-page">
      <!-- 今日事项 -->
      <div class="section">
        <h2 class="section-header">
          <van-icon name="calendar-o" size="24" />
          <span>今日事项</span>
          <span class="today-date">{{ todayStr }}</span>
        </h2>
        <div v-if="todayTasks.length > 0">
          <TaskCard
            v-for="task in todayTasks"
            :key="task.id"
            :task="task"
            :elderly="true"
            @click="goTaskDetail(task.id)"
          />
        </div>
        <EmptyState v-else description="今天没有待办事项，轻松一天！" />
        <div class="view-all" @click="router.push('/elderly/tasks')">
          查看全部事项 <van-icon name="arrow" />
        </div>
      </div>

      <!-- 近期事项 -->
      <div class="section" v-if="recentTasks.length > 0">
        <h2 class="section-header">
          <van-icon name="clock-o" size="24" />
          <span>近期事项</span>
        </h2>
        <TaskCard
          v-for="task in recentTasks"
          :key="task.id"
          :task="task"
          :elderly="true"
          @click="goTaskDetail(task.id)"
        />
      </div>

      <!-- 四大模块快捷入口 -->
      <div class="section">
        <h2 class="section-header">
          <van-icon name="apps-o" size="24" />
          <span>办事分类</span>
        </h2>
        <div class="category-grid">
          <div
            v-for="cat in categoryList"
            :key="cat.value"
            class="category-card"
            :style="{ background: cat.bg }"
            @click="goCategory(cat.value)"
          >
            <van-icon :name="cat.icon" size="32" />
            <span class="category-label">{{ cat.label }}</span>
          </div>
        </div>
      </div>
    </div>
  </ElderlyLayout>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import ElderlyLayout from '../../components/ElderlyLayout.vue'
import TaskCard from '../../components/TaskCard.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getMyTasks } from '../../api/task'

const router = useRouter()
const tasks = ref([])

const categoryList = [
  { value: 'GOVERNMENT', label: '政务帮办', icon: 'balance-o', bg: '#FFF3E0' },
  { value: 'LIFE', label: '生活协助', icon: 'home-o', bg: '#E3F2FD' },
  { value: 'HEALTH', label: '健康支持', icon: 'like-o', bg: '#E8F5E9' },
  { value: 'COMMUNITY', label: '社区连接', icon: 'friends-o', bg: '#FCE4EC' }
]

const todayStr = computed(() => {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
})

function formatDateLocal(val) {
  if (!val) return ''
  // 如果已是日期字符串（如 '2026-05-27' 或 '2026-05-27T00:00:00'），
  // 直接用本地时间解析，避免 .toISOString() 将本地时间转 UTC 造成日期偏移
  const d = new Date(val)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

const todayTasks = computed(() =>
  tasks.value.filter(t => {
    if (t.status === 'COMPLETED' || t.status === 'CANCELLED') return false
    if (!t.planDate) return false
    return formatDateLocal(t.planDate) === todayStr.value
  })
)

const recentTasks = computed(() =>
  tasks.value.filter(t => {
    if (t.status === 'COMPLETED' || t.status === 'CANCELLED') return false
    if (!t.planDate) return false
    const dateStr = formatDateLocal(t.planDate)
    if (dateStr === todayStr.value) return false
    // 7天内
    const now = new Date()
    const taskDate = new Date(t.planDate)
    const diff = (taskDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
    return diff > 0 && diff <= 7
  })
)

function goTaskDetail(id) {
  router.push(`/elderly/task/${id}`)
}

function goCategory(cat) {
  router.push(`/elderly/tasks?category=${cat}`)
}

async function loadTasks() {
  try {
    const res = await getMyTasks()
    tasks.value = res.data || []
  } catch (e) { /* */ }
}

onMounted(() => {
  loadTasks()
})
</script>

<style scoped>
.elderly-home {
  padding-bottom: env(safe-area-inset-bottom);
}

.section {
  margin-bottom: 28px;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: var(--elderly-font-xl);
  font-weight: 700;
  margin-bottom: var(--spacing-md);
  color: var(--text-primary);
}

.today-date {
  font-size: var(--elderly-font-md);
  color: var(--text-hint);
  font-weight: 400;
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.category-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 24px 16px;
  border-radius: var(--radius-lg);
  cursor: pointer;
  transition: transform 0.1s;
  min-height: 100px;
}

.category-card:active {
  transform: scale(0.96);
}

.category-label {
  font-size: var(--elderly-font-md);
  font-weight: 600;
  color: var(--text-primary);
}

.view-all {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  margin-top: 8px;
  padding: 12px;
  font-size: var(--elderly-font-md);
  color: var(--color-primary);
  cursor: pointer;
}
</style>
