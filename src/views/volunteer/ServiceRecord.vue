<template>
  <StandardLayout title="记录服务" :show-back="true" :show-tabbar="false">
    <div class="service-record">
      <van-form @submit="handleSubmit">
        <van-cell-group inset title="服务详情">
          <van-field
            v-model="form.serviceType"
            label="服务方式"
            placeholder="请选择服务方式"
            is-link
            readonly
            @click="showTypePicker = true"
          />
          <van-field
            v-model="form.duration"
            label="服务时长（分钟）"
            placeholder="请输入服务时长"
            type="number"
          />
          <van-field
            v-model="form.content"
            label="服务内容"
            placeholder="请描述本次服务内容"
            type="textarea"
            rows="3"
          />
        </van-cell-group>

        <div class="form-actions">
          <van-button
            round
            block
            type="primary"
            native-type="submit"
            :loading="submitting"
          >
            保存记录
          </van-button>
        </div>
      </van-form>
    </div>

    <van-popup v-model:show="showTypePicker" position="bottom" round>
      <van-picker
        :columns="typeOptions"
        @confirm="onTypeConfirm"
        @cancel="showTypePicker = false"
      />
    </van-popup>
  </StandardLayout>
</template>

<script setup>
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast } from 'vant'
import StandardLayout from '../../components/StandardLayout.vue'
import { createServiceRecord } from '../../api/service'
import { SERVICE_TYPE_OPTIONS } from '../../utils/constants'

const route = useRoute()
const router = useRouter()
const helpId = route.params.helpId

const submitting = ref(false)
const showTypePicker = ref(false)

const typeOptions = SERVICE_TYPE_OPTIONS.map(t => ({ text: t.label, value: t.value }))

const form = ref({
  serviceType: '',
  duration: '',
  content: ''
})

function onTypeConfirm({ selectedOptions }) {
  form.value.serviceType = selectedOptions[0].value
  showTypePicker.value = false
}

async function handleSubmit() {
  submitting.value = true
  try {
    await createServiceRecord({
      helpRequestId: Number(helpId),
      serviceType: form.value.serviceType || undefined,
      duration: form.value.duration ? Number(form.value.duration) : undefined,
      content: form.value.content || undefined
    })
    showToast('记录保存成功')
    router.back()
  } catch (e) { /* */ }
  finally { submitting.value = false }
}
</script>

<style scoped>
.service-record {
  padding: var(--spacing-md);
}

.form-actions {
  margin-top: 24px;
  padding: 0 var(--spacing-sm);
}

.form-actions .van-button {
  height: 48px;
  font-size: var(--font-lg);
}
</style>
