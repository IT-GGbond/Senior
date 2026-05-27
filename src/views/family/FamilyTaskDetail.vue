<template>
  <StandardLayout
    :title="task.title || '任务详情'"
    :show-back="true"
    :show-tabbar="false"
  >
    <div class="family-task-detail" v-if="task.id">
      <!-- 任务信息 -->
      <div class="detail-section card">
        <div class="section-header">
          <h3>任务信息</h3>
          <van-tag :type="statusType">{{ statusMap[task.status] }}</van-tag>
        </div>
        <div class="info-grid">
          <div class="info-row" v-if="task.category">
            <span class="info-label">分类</span>
            <van-tag type="primary">{{ categoryMap[task.category] }}</van-tag>
          </div>
          <div class="info-row" v-if="task.planDate">
            <span class="info-label">日期</span>
            <span>{{ formatDate(task.planDate) }} {{ task.planTime || '' }}</span>
          </div>
          <div class="info-row" v-if="task.location">
            <span class="info-label">地点</span>
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
        <div class="section-header">
          <h3>材料清单</h3>
          <span class="count-text">
            {{ checkedCount }}/{{ task.materials ? task.materials.length : 0 }}
          </span>
        </div>
        <MaterialList
          v-if="task.materials && task.materials.length > 0"
          :materials="task.materials"
          :interactive="false"
        />
        <div v-else class="empty-text">暂无材料</div>

        <!-- 添加材料 -->
        <div class="add-row" v-if="task.status !== 'COMPLETED' && task.status !== 'CANCELLED'">
          <van-field
            v-model="newMaterial"
            placeholder="输入材料名称"
            size="small"
          />
          <van-button size="small" type="primary" round @click="handleAddMaterial">添加</van-button>
        </div>
      </div>

      <!-- 办事步骤 -->
      <div class="detail-section card">
        <div class="section-header">
          <h3>办事步骤</h3>
          <span class="count-text">
            {{ completedSteps }}/{{ task.steps ? task.steps.length : 0 }}
          </span>
        </div>
        <StepList
          v-if="task.steps && task.steps.length > 0"
          :steps="task.steps"
          :interactive="false"
        />
        <div v-else class="empty-text">暂无步骤</div>

        <!-- 添加步骤 -->
        <div class="add-section" v-if="task.status !== 'COMPLETED' && task.status !== 'CANCELLED'">
          <van-field
            v-model="newStepTitle"
            placeholder="步骤标题"
            size="small"
          />
          <van-field
            v-model="newStepDesc"
            placeholder="步骤说明（选填）"
            size="small"
          />
          <van-button size="small" type="primary" round block @click="handleAddStep">添加步骤</van-button>
        </div>
      </div>
    </div>

    <van-loading v-else class="loading-center" />
  </StandardLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { showToast } from 'vant'
import StandardLayout from '../../components/StandardLayout.vue'
import MaterialList from '../../components/MaterialList.vue'
import StepList from '../../components/StepList.vue'
import { getTaskDetail } from '../../api/task'
import { addMaterial } from '../../api/taskMaterial'
import { addStep } from '../../api/taskStep'
import { TASK_STATUS, CATEGORIES } from '../../utils/constants'

const route = useRoute()
const statusMap = TASK_STATUS
const categoryMap = CATEGORIES

const task = ref({})
const newMaterial = ref('')
const newStepTitle = ref('')
const newStepDesc = ref('')

const statusType = computed(() => {
  const map = {
    PENDING: 'warning',
    IN_PROGRESS: 'primary',
    COMPLETED: 'success',
    CANCELLED: 'danger'
  }
  return map[task.value.status] || 'default'
})

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

async function handleAddMaterial() {
  if (!newMaterial.value.trim()) return
  try {
    const res = await addMaterial(task.value.id, newMaterial.value.trim())
    task.value.materials = task.value.materials || []
    task.value.materials.push(res.data)
    newMaterial.value = ''
    showToast('添加成功')
  } catch (e) { /* */ }
}

async function handleAddStep() {
  if (!newStepTitle.value.trim()) return
  try {
    const sortOrder = (task.value.steps || []).length + 1
    const res = await addStep(task.value.id, {
      sortOrder,
      title: newStepTitle.value.trim(),
      description: newStepDesc.value.trim() || undefined
    })
    task.value.steps = task.value.steps || []
    task.value.steps.push(res.data)
    newStepTitle.value = ''
    newStepDesc.value = ''
    showToast('添加成功')
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
.family-task-detail {
  padding: var(--spacing-md);
}

.detail-section {
  margin-bottom: var(--spacing-md);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-sm);
}

.section-header h3 {
  font-size: var(--font-xl);
  font-weight: 600;
}

.count-text {
  font-size: var(--font-md);
  color: var(--color-success);
  font-weight: 500;
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
  font-size: var(--font-md);
}

.info-label {
  color: var(--text-hint);
  min-width: 50px;
}

.empty-text {
  padding: 20px 0;
  text-align: center;
  color: var(--text-hint);
}

.add-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px dashed var(--border-color);
}

.add-row :deep(.van-cell) {
  flex: 1;
  padding: 8px;
  background: var(--bg-gray);
  border-radius: var(--radius-sm);
}

.add-section {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px dashed var(--border-color);
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.add-section :deep(.van-cell) {
  padding: 8px;
  background: var(--bg-gray);
  border-radius: var(--radius-sm);
}

.loading-center {
  display: flex;
  justify-content: center;
  padding: 80px 0;
}
</style>
