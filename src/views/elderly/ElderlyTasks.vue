<template>
  <ElderlyLayout title="我的事项" :show-back="true" :show-tabbar="false">
    <div class="elderly-tasks elderly-page">
      <!-- 分类筛选 -->
      <div class="category-filter" v-if="!statusFilter">
        <div
          v-for="cat in categoryTabs"
          :key="cat.value"
          class="filter-chip"
          :class="{ active: activeCategory === cat.value }"
          @click="switchCategory(cat.value)"
        >
          {{ cat.label }}
        </div>
      </div>

      <!-- 状态筛选 -->
      <van-tabs v-model:active="activeStatus" @change="onStatusChange">
        <van-tab v-for="tab in statusTabs" :key="tab.value" :name="tab.value" :title="tab.label" />
      </van-tabs>

      <!-- 任务列表 -->
      <div class="task-list" v-if="tasks.length > 0">
        <TaskCard
          v-for="task in tasks"
          :key="task.id"
          :task="task"
          :elderly="true"
          @click="goDetail(task.id)"
        />
      </div>
      <EmptyState v-else :description="emptyDescription" />
    </div>
  </ElderlyLayout>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import ElderlyLayout from '../../components/ElderlyLayout.vue'
import TaskCard from '../../components/TaskCard.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getMyTasks } from '../../api/task'

const route = useRoute()
const router = useRouter()

const activeCategory = ref(route.query.category || '')
const activeStatus = ref(route.query.status || '')
const statusFilter = ref(!!route.query.status)

const categoryMap = { GOVERNMENT: '政务帮办', LIFE: '生活协助', HEALTH: '健康支持', COMMUNITY: '社区连接' }

const emptyDescription = computed(() => {
  if (activeCategory.value) return `暂无${categoryMap[activeCategory.value] || ''}相关事项`
  return '暂无事项'
})

const categoryTabs = [
  { value: '', label: '全部分类' },
  { value: 'GOVERNMENT', label: '政务帮办' },
  { value: 'LIFE', label: '生活协助' },
  { value: 'HEALTH', label: '健康支持' },
  { value: 'COMMUNITY', label: '社区连接' }
]

const statusTabs = [
  { value: '', label: '全部' },
  { value: 'PENDING', label: '待办' },
  { value: 'IN_PROGRESS', label: '进行中' },
  { value: 'COMPLETED', label: '已完成' },
  { value: 'CANCELLED', label: '已取消' }
]

const tasks = ref([])

function switchCategory(cat) {
  activeCategory.value = cat
  loadTasks()
}

function onStatusChange() {
  loadTasks()
}

function goDetail(id) {
  router.push(`/elderly/task/${id}`)
}

async function loadTasks() {
  try {
    const status = activeStatus.value || undefined
    const res = await getMyTasks(status)
    let data = res.data || []
    // 按分类筛选（前端过滤，因为API可能不支持分类筛选）
    if (activeCategory.value) {
      data = data.filter(t => t.category === activeCategory.value)
    }
    tasks.value = data
  } catch (e) { /* */ }
}

onMounted(() => {
  loadTasks()
})

watch(
  () => [route.query.category, route.query.status],
  ([category, status]) => {
    activeCategory.value = category || ''
    activeStatus.value = status || ''
    statusFilter.value = !!status
    loadTasks()
  }
)
</script>

<style scoped>
.elderly-tasks {
  padding-bottom: env(safe-area-inset-bottom);
}

.category-filter {
  display: flex;
  gap: 10px;
  padding: 8px 0 16px;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.category-filter::-webkit-scrollbar {
  display: none;
}

.filter-chip {
  flex-shrink: 0;
  padding: 10px 20px;
  border-radius: 24px;
  background: var(--bg-white);
  font-size: var(--elderly-font-md);
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
  cursor: pointer;
  white-space: nowrap;
}

.filter-chip.active {
  background: #FFF3E0;
  color: var(--color-primary);
  border-color: var(--color-primary);
  font-weight: 600;
}

.task-list {
  margin-top: var(--spacing-md);
}

:deep(.van-tab) {
  font-size: var(--elderly-font-md);
}
</style>
