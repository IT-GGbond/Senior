<template>
  <StandardLayout title="流程模板管理">
    <div class="template-manage">
      <div class="toolbar">
        <van-button type="primary" round size="small" icon="plus" @click="showCreatePopup = true">
          创建模板
        </van-button>
      </div>

      <!-- 模板列表 -->
      <div v-if="templates.length > 0">
        <div
          v-for="tpl in templates"
          :key="tpl.id"
          class="template-card card"
        >
          <div class="tpl-header">
            <h4>{{ tpl.name }}</h4>
            <van-tag v-if="tpl.category" type="primary">
              {{ categoryMap[tpl.category] }}
            </van-tag>
          </div>
          <div class="tpl-actions">
            <van-button size="small" plain round @click="viewDetail(tpl.id)">
              查看详情
            </van-button>
            <van-button size="small" plain round type="danger" @click="handleDelete(tpl.id)">
              删除
            </van-button>
          </div>
        </div>
      </div>
      <EmptyState v-else description="暂无流程模板" />

      <!-- 创建模板弹窗 -->
      <van-popup v-model:show="showCreatePopup" position="bottom" round :style="{ padding: '24px', maxHeight: '80vh', overflowY: 'auto' }">
        <h3 class="popup-title">创建模板</h3>
        <van-field v-model="createForm.name" label="模板名称" placeholder="请输入模板名称" />
        <van-field
          v-model="createForm.category"
          label="所属分类"
          placeholder="请选择分类"
          is-link
          readonly
          @click="showCategoryPicker = true"
        />
        <div class="material-section">
          <h4 class="subsection-title">材料清单</h4>
          <div v-for="(m, i) in createForm.materials" :key="i" class="inline-item">
            <van-field v-model="createForm.materials[i]" placeholder="材料名称" />
            <van-button size="small" icon="cross" round @click="createForm.materials.splice(i, 1)" />
          </div>
          <van-button size="small" plain icon="plus" round @click="createForm.materials.push('')">添加材料</van-button>
        </div>
        <div class="step-section">
          <h4 class="subsection-title">办事步骤</h4>
          <div v-for="(s, i) in createForm.steps" :key="i" class="step-item">
            <van-field v-model="s.title" placeholder="步骤标题" />
            <van-field v-model="s.description" placeholder="步骤说明（选填）" />
            <van-button size="small" icon="cross" round @click="createForm.steps.splice(i, 1)" />
          </div>
          <van-button size="small" plain icon="plus" round @click="createForm.steps.push({ title: '', description: '', sortOrder: createForm.steps.length + 1 })">添加步骤</van-button>
        </div>
        <van-button type="primary" round block :loading="creating" class="popup-btn" @click="handleCreate">确认创建</van-button>
      </van-popup>

      <!-- 分类选择 -->
      <van-popup v-model:show="showCategoryPicker" position="bottom" round>
        <van-picker
          :columns="categoryOptions"
          @confirm="onCategoryConfirm"
          @cancel="showCategoryPicker = false"
        />
      </van-popup>

      <!-- 模板详情弹窗 -->
      <van-popup
        v-model:show="showDetailPopup"
        position="bottom"
        round
        :style="{ padding: '24px', maxHeight: '70vh', overflowY: 'auto' }"
      >
        <template v-if="detailTemplate">
          <h3 class="popup-title">{{ detailTemplate.name }}</h3>
          <van-tag v-if="detailTemplate.category" type="primary" class="detail-tag">
            {{ categoryMap[detailTemplate.category] || detailTemplate.category }}
          </van-tag>

          <div class="detail-section" v-if="detailTemplate.steps && detailTemplate.steps.length > 0">
            <h4 class="detail-subtitle">办事步骤</h4>
            <div v-for="(s, i) in detailTemplate.steps" :key="s.id || i" class="detail-step">
              <span class="step-index">{{ i + 1 }}</span>
              <div class="step-body">
                <div class="step-title">{{ s.title }}</div>
                <div class="step-desc" v-if="s.description">{{ s.description }}</div>
              </div>
            </div>
          </div>

          <div class="detail-section" v-if="detailTemplate.materials && detailTemplate.materials.length > 0">
            <h4 class="detail-subtitle">默认材料清单</h4>
            <div v-for="m in detailTemplate.materials" :key="m.id" class="detail-material">
              <van-icon name="circle" size="8" color="#FF8C00" />
              <span>{{ m.name }}</span>
            </div>
          </div>

          <div v-if="!detailTemplate.steps?.length && !detailTemplate.materials?.length" class="detail-empty">
            此模板暂无步骤和材料
          </div>
        </template>
      </van-popup>
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { showToast, showConfirmDialog } from 'vant'
import StandardLayout from '../../components/StandardLayout.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getTemplateList, createTemplate, getTemplateDetail, deleteTemplate } from '../../api/template'
import { CATEGORIES, CATEGORY_LIST } from '../../utils/constants'

const categoryMap = CATEGORIES
const categoryOptions = CATEGORY_LIST.map(c => ({ text: c.label, value: c.value }))

const templates = ref([])
const showCreatePopup = ref(false)
const showCategoryPicker = ref(false)
const creating = ref(false)

const createForm = ref({
  name: '',
  category: '',
  steps: [],
  materials: []
})

function onCategoryConfirm({ selectedOptions }) {
  createForm.value.category = selectedOptions[0].value
  showCategoryPicker.value = false
}

const showDetailPopup = ref(false)
const detailTemplate = ref(null)

async function viewDetail(id) {
  try {
    const res = await getTemplateDetail(id)
    detailTemplate.value = res.data
    showDetailPopup.value = true
  } catch (e) { /* */ }
}

async function handleCreate() {
  if (!createForm.value.name.trim()) {
    showToast('请输入模板名称')
    return
  }
  creating.value = true
  try {
    await createTemplate({
      name: createForm.value.name,
      category: createForm.value.category || undefined,
      steps: createForm.value.steps.filter(s => s.title.trim()).length > 0
        ? createForm.value.steps.filter(s => s.title.trim())
        : undefined,
      materials: createForm.value.materials.filter(m => m.trim()).length > 0
        ? createForm.value.materials.filter(m => m.trim())
        : undefined
    })
    showToast('创建成功')
    showCreatePopup.value = false
    createForm.value = { name: '', category: '', steps: [], materials: [] }
    loadTemplates()
  } catch (e) { /* */ }
  finally { creating.value = false }
}

async function handleDelete(id) {
  try {
    await showConfirmDialog({ title: '确认', message: '确定删除该模板吗？' })
    await deleteTemplate(id)
    showToast('已删除')
    loadTemplates()
  } catch (e) { /* */ }
}

async function loadTemplates() {
  try {
    const res = await getTemplateList()
    templates.value = res.data || []
  } catch (e) { /* */ }
}

onMounted(loadTemplates)
</script>

<style scoped>
.template-manage {
  padding: var(--spacing-md);
}

.toolbar {
  margin-bottom: var(--spacing-md);
  display: flex;
  justify-content: flex-end;
}

.template-card {
  margin-bottom: var(--spacing-sm);
}

.tpl-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.tpl-header h4 {
  font-size: var(--font-lg);
  font-weight: 600;
}

.tpl-actions {
  display: flex;
  gap: 8px;
}

.popup-title {
  font-size: var(--font-xl);
  font-weight: 600;
  margin-bottom: 16px;
  text-align: center;
}

.subsection-title {
  font-size: var(--font-md);
  font-weight: 600;
  margin: 16px 0 8px;
  padding: 0 8px;
}

.material-section,
.step-section {
  margin-top: 8px;
}

.inline-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.inline-item :deep(.van-cell) {
  flex: 1;
}

.step-item {
  margin-bottom: 12px;
  padding: 8px;
  background: var(--bg-gray);
  border-radius: var(--radius-sm);
}

.step-item :deep(.van-cell) {
  background: transparent;
  padding: 4px 8px;
}

.popup-btn {
  margin-top: 24px;
  height: 48px;
}

.detail-tag {
  margin-bottom: 16px;
}

.detail-section {
  margin-top: 16px;
}

.detail-subtitle {
  font-size: var(--font-md);
  font-weight: 600;
  margin-bottom: 10px;
  color: var(--text-primary);
}

.detail-step {
  display: flex;
  gap: 10px;
  padding: 8px 0;
  border-bottom: 1px solid #F5F5F5;
}

.detail-step:last-child {
  border-bottom: none;
}

.step-index {
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: #FFF3E0;
  color: var(--color-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
  flex-shrink: 0;
  margin-top: 2px;
}

.step-body {
  flex: 1;
}

.step-body .step-title {
  font-size: var(--font-md);
  font-weight: 500;
}

.step-body .step-desc {
  font-size: var(--font-sm);
  color: var(--text-hint);
  margin-top: 2px;
}

.detail-material {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 0;
  font-size: var(--font-md);
}

.detail-empty {
  text-align: center;
  padding: 20px;
  color: var(--text-hint);
}
</style>
