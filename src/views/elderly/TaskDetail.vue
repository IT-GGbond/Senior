<template>
  <ElderlyLayout
    :title="task.title || '任务详情'"
    :show-back="true"
    :show-tabbar="false"
  >
    <div class="task-detail elderly-page" v-if="task.id">
      <!-- 任务信息 -->
      <div class="detail-section card">
        <h3 class="section-title">任务信息</h3>
        <div class="info-grid">
          <div class="info-row" v-if="task.category">
            <span class="info-label">分类</span>
            <van-tag type="primary">{{ categoryMap[task.category] }}</van-tag>
          </div>
          <div class="info-row" v-if="task.planDate">
            <span class="info-label">办理日期</span>
            <span>{{ formatDate(task.planDate) }} {{ task.planTime || '' }}</span>
          </div>
          <div class="info-row" v-if="task.location">
            <span class="info-label">办理地点</span>
            <span>{{ task.location }}</span>
          </div>
          <div class="info-row" v-if="task.remark">
            <span class="info-label">备注</span>
            <span>{{ task.remark }}</span>
          </div>
        </div>
      </div>

      <!-- 材料清单 -->
      <div class="detail-section card">
        <div class="section-title-row">
          <h3 class="section-title">材料清单</h3>
          <span class="material-count">
            {{ checkedCount }}/{{ task.materials ? task.materials.length : 0 }}
          </span>
        </div>
        <MaterialList
          v-if="task.materials && task.materials.length > 0"
          :materials="task.materials"
          :elderly="true"
          @toggle="handleMaterialToggle"
        />
        <EmptyState v-else description="暂无材料清单" />
      </div>

      <!-- 办事步骤 -->
      <div class="detail-section card">
        <div class="section-title-row">
          <h3 class="section-title">办事步骤</h3>
          <span class="step-count">
            {{ completedSteps }}/{{ task.steps ? task.steps.length : 0 }}
          </span>
        </div>
        <StepList
          v-if="task.steps && task.steps.length > 0"
          :steps="task.steps"
          :elderly="true"
          @toggle="handleStepToggle"
        />
        <EmptyState v-else description="暂无办事步骤" />
      </div>

      <!-- 占位：固定底部按钮的高度 -->
      <div style="height: 80px;" />
    </div>

    <!-- 加载状态 -->
    <van-loading v-else class="loading-center" />

    <!-- 底部操作栏 -->
    <div class="bottom-bar" v-if="task.id">
      <!-- 状态操作 -->
      <div class="status-actions">
        <van-button
          v-if="task.status === 'PENDING'"
          type="primary"
          round
          @click="changeStatus('IN_PROGRESS')"
        >
          开始办理
        </van-button>
        <van-button
          v-if="task.status === 'IN_PROGRESS'"
          type="success"
          round
          @click="changeStatus('COMPLETED')"
        >
          标记完成
        </van-button>
        <van-button
          v-if="task.status === 'PENDING' || task.status === 'IN_PROGRESS'"
          round
          @click="changeStatus('CANCELLED')"
        >
          取消
        </van-button>
      </div>
    </div>
  </ElderlyLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast, showConfirmDialog } from 'vant'
import ElderlyLayout from '../../components/ElderlyLayout.vue'
import MaterialList from '../../components/MaterialList.vue'
import StepList from '../../components/StepList.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getTaskDetail, updateTaskStatus } from '../../api/task'
import { checkMaterial } from '../../api/taskMaterial'
import { completeStep } from '../../api/taskStep'
import { CATEGORIES } from '../../utils/constants'

const route = useRoute()
const router = useRouter()
const categoryMap = CATEGORIES

const task = ref({})

const checkedCount = computed(() =>
  task.value.materials ? task.value.materials.filter(m => m.isChecked).length : 0
)
const completedSteps = computed(() =>
  task.value.steps ? task.value.steps.filter(s => s.isCompleted).length : 0
)

async function loadTask() {
  try {
    const res = await getTaskDetail(route.params.id)
    task.value = res.data || {}
  } catch (e) { /* */ }
}

async function handleMaterialToggle(item) {
  try {
    const newChecked = !item.isChecked
    await checkMaterial(item.id, newChecked)
    item.isChecked = newChecked ? 1 : 0
  } catch (e) { /* */ }
}

async function handleStepToggle(step) {
  if (step.isCompleted) return
  try {
    await completeStep(step.id)
    step.isCompleted = 1
    showToast('步骤完成！')
  } catch (e) { /* */ }
}

async function changeStatus(status) {
  const labels = { COMPLETED: '标记完成', CANCELLED: '取消任务', IN_PROGRESS: '开始办理' }
  try {
    await showConfirmDialog({
      title: '确认操作',
      message: `确定要${labels[status]}吗？`
    })
    await updateTaskStatus(task.value.id, status)
    task.value.status = status
    showToast(`${labels[status]}成功`)
    if (status === 'COMPLETED' || status === 'CANCELLED') {
      router.replace('/elderly/home')
    }
  } catch (e) { /* */ }
}

function formatDate(val) {
  if (!val) return ''
  const d = new Date(val)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

onMounted(loadTask)
</script>

<style scoped>
.task-detail {
  padding-bottom: 0;
}

.detail-section {
  margin-bottom: var(--spacing-md);
}

.section-title {
  font-size: var(--elderly-font-lg);
  font-weight: 700;
  margin-bottom: var(--spacing-sm);
}

.section-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-sm);
}

.section-title-row .section-title {
  margin-bottom: 0;
}

.material-count,
.step-count {
  font-size: var(--elderly-font-md);
  color: var(--color-success);
  font-weight: 600;
}

.info-grid {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: var(--elderly-font-md);
}

.info-label {
  color: var(--text-hint);
  min-width: 70px;
}

.loading-center {
  display: flex;
  justify-content: center;
  padding: 80px 0;
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 12px 16px;
  padding-bottom: calc(12px + env(safe-area-inset-bottom));
  background: var(--bg-white);
  box-shadow: 0 -2px 8px rgba(0,0,0,0.1);
  z-index: 100;
}

.status-actions {
  display: flex;
  gap: 8px;
}

.status-actions .van-button {
  flex: 1;
  height: 44px;
  font-size: var(--elderly-font-md);
}

</style>
