<template>
  <StandardLayout
    :title="elderlyName"
    :show-back="true"
    :show-tabbar="false"
  >
    <div class="elderly-tasks">
      <!-- 顶层 Tab：任务 | 求助 -->
      <van-tabs v-model:active="mainTab">
        <van-tab title="任务">
          <!-- 任务状态子 tabs -->
          <van-tabs v-model:active="activeTab" @change="onTaskTabChange">
            <van-tab v-for="tab in statusTabs" :key="tab.value" :title="tab.label" />
          </van-tabs>

          <div class="task-list">
            <TaskCard
              v-for="task in tasks"
              :key="task.id"
              :task="task"
              @click="goDetail(task.id)"
            />
            <EmptyState v-if="tasks.length === 0" description="暂无任务" />
          </div>

          <van-button
            type="primary"
            icon="plus"
            round
            block
            class="create-btn"
            @click="$router.push(`/family/task/create/${elderlyId}`)"
          >
            为{{ elderlyName }}创建任务
          </van-button>
        </van-tab>

        <van-tab title="求助记录">
          <div class="task-list">
            <HelpCard
              v-for="item in helpList"
              :key="item.id"
              :help="item"
            />
            <EmptyState v-if="helpList.length === 0" description="该老人暂无求助记录" />
          </div>
        </van-tab>
      </van-tabs>
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import StandardLayout from '../../components/StandardLayout.vue'
import TaskCard from '../../components/TaskCard.vue'
import HelpCard from '../../components/HelpCard.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getElderlyTasks } from '../../api/task'
import { getElderlyHelp } from '../../api/help'

const route = useRoute()
const router = useRouter()
const elderlyId = route.params.elderlyId
const elderlyName = ref(route.query.name || '老人')

const mainTab = ref(0)
const activeTab = ref(0)
const statusTabs = [
  { label: '全部', value: '' },
  { label: '待办', value: 'PENDING' },
  { label: '进行中', value: 'IN_PROGRESS' },
  { label: '已完成', value: 'COMPLETED' }
]

const tasks = ref([])
const helpList = ref([])

function onTaskTabChange(idx) {
  loadTasks(statusTabs[idx].value)
}

function goDetail(id) {
  router.push(`/family/task/${id}`)
}

async function loadTasks(status) {
  try {
    const res = await getElderlyTasks(elderlyId, status || undefined)
    tasks.value = res.data || []
  } catch (e) { /* */ }
}

async function loadHelp() {
  try {
    const res = await getElderlyHelp(elderlyId)
    helpList.value = res.data || []
  } catch (e) { /* */ }
}

watch(mainTab, (val) => {
  if (val === 1) loadHelp()
})

onMounted(() => loadTasks(''))
</script>

<style scoped>
.elderly-tasks {
  padding: var(--spacing-md);
}

.task-list {
  margin-top: var(--spacing-md);
}

.create-btn {
  margin-top: 24px;
  height: 48px;
  font-size: var(--font-lg);
}
</style>
