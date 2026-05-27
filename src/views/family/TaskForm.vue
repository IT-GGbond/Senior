<template>
  <StandardLayout title="创建任务" :show-back="true" :show-tabbar="false">
    <div class="task-form">
      <van-form @submit="handleSubmit">
        <van-cell-group inset title="基本信息">
          <van-field
            v-model="form.title"
            label="任务标题"
            placeholder="请输入任务标题，如'去医院复诊'"
            :rules="[{ required: true, message: '请输入任务标题' }]"
          />
          <van-field
            v-model="form.category"
            label="所属分类"
            placeholder="请选择分类"
            is-link
            readonly
            @click="showCategoryPicker = true"
            :rules="[{ required: true, message: '请选择分类' }]"
          />
          <van-field
            v-model="form.planDate"
            label="预计日期"
            placeholder="请选择日期"
            is-link
            readonly
            @click="showDatePicker = true"
          />
          <van-field
            v-model="form.planTime"
            label="预计时间"
            placeholder="请选择时间"
            is-link
            readonly
            @click="showTimePicker = true"
          />
          <van-field
            v-model="form.location"
            label="办理地点"
            placeholder="请输入办理地点"
          />
          <van-field
            v-model="form.remark"
            label="备注"
            placeholder="补充说明"
            type="textarea"
            rows="2"
          />
        </van-cell-group>

        <!-- 选择流程模板 -->
        <van-cell-group inset title="流程模板（可选）" style="margin-top: 12px">
          <van-field
            v-model="selectedTemplateName"
            label="选择模板"
            placeholder="选择模板自动带入步骤和材料"
            is-link
            readonly
            @click="showTemplatePicker = true"
          />
        </van-cell-group>

        <div class="form-actions">
          <van-button round block type="primary" native-type="submit" :loading="submitting">
            创建任务
          </van-button>
        </div>
      </van-form>

      <!-- 分类选择器 -->
      <van-popup v-model:show="showCategoryPicker" position="bottom" round>
        <van-picker
          :columns="categoryOptions"
          @confirm="onCategoryConfirm"
          @cancel="showCategoryPicker = false"
        />
      </van-popup>

      <!-- 日期选择器 -->
      <van-popup v-model:show="showDatePicker" position="bottom" round>
        <van-date-picker
          :min-date="minDate"
          @confirm="onDateConfirm"
          @cancel="showDatePicker = false"
        />
      </van-popup>

      <!-- 时间选择器 -->
      <van-popup v-model:show="showTimePicker" position="bottom" round>
        <van-time-picker
          @confirm="onTimeConfirm"
          @cancel="showTimePicker = false"
        />
      </van-popup>

      <!-- 模板选择器 -->
      <van-popup v-model:show="showTemplatePicker" position="bottom" round>
        <van-picker
          :columns="templateColumns"
          @confirm="onTemplateConfirm"
          @cancel="showTemplatePicker = false"
        />
      </van-popup>
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast } from 'vant'
import StandardLayout from '../../components/StandardLayout.vue'
import { createTask } from '../../api/task'
import { getTemplateList } from '../../api/template'
import { CATEGORY_LIST } from '../../utils/constants'

const route = useRoute()
const router = useRouter()
const elderlyId = route.params.elderlyId

const submitting = ref(false)

const categoryOptions = CATEGORY_LIST.map(c => ({ text: c.label, value: c.value }))

const form = ref({
  title: '',
  category: '',
  planDate: '',
  planTime: '',
  location: '',
  remark: '',
  templateId: null
})

const showCategoryPicker = ref(false)
const showDatePicker = ref(false)
const showTimePicker = ref(false)
const showTemplatePicker = ref(false)
const selectedTemplateName = ref('')
const templates = ref([])
const minDate = new Date()

const templateColumns = ref([])

function onCategoryConfirm({ selectedOptions }) {
  form.value.category = selectedOptions[0].value
  showCategoryPicker.value = false
}

function onDateConfirm({ selectedValues }) {
  form.value.planDate = selectedValues.join('-')
  showDatePicker.value = false
}

function onTimeConfirm({ selectedValues }) {
  form.value.planTime = selectedValues.join(':')
  showTimePicker.value = false
}

function onTemplateConfirm({ selectedOptions }) {
  const tpl = selectedOptions[0]
  if (tpl && tpl.value !== 'none') {
    form.value.templateId = tpl.value
    selectedTemplateName.value = tpl.text
  } else {
    form.value.templateId = null
    selectedTemplateName.value = ''
  }
  showTemplatePicker.value = false
}

async function loadTemplates() {
  try {
    const res = await getTemplateList()
    templates.value = res.data || []
    const options = [{ text: '不使用模板', value: 'none' }]
    templates.value.forEach(t => {
      options.push({ text: t.name, value: t.id })
    })
    templateColumns.value = options
  } catch (e) { /* */ }
}

async function handleSubmit() {
  submitting.value = true
  try {
    const data = {
      title: form.value.title,
      category: form.value.category || undefined,
      planDate: form.value.planDate || undefined,
      planTime: form.value.planTime || undefined,
      location: form.value.location || undefined,
      remark: form.value.remark || undefined,
      elderlyId: elderlyId ? Number(elderlyId) : undefined,
      templateId: form.value.templateId || undefined
    }
    await createTask(data)
    showToast('任务创建成功')
    router.back()
  } catch (e) { /* */ }
  finally { submitting.value = false }
}

onMounted(loadTemplates)
</script>

<style scoped>
.task-form {
  padding: var(--spacing-md);
}

.form-actions {
  margin-top: 24px;
  padding: 0 var(--spacing-sm);
}

.form-actions .van-button {
  height: 48px;
  font-size: var(--font-xl);
}
</style>
