<template>
  <StandardLayout title="绑定老人" :show-back="true" :show-tabbar="false">
    <div class="bind-elderly">
      <div class="bind-card card">
        <div class="bind-desc">
          <van-icon name="info-o" size="20" color="#FF8C00" />
          <span>输入老人提供的6位邀请码，完成绑定后即可查看老人任务和进度。</span>
        </div>

        <van-form @submit="handleBind">
          <van-field
            v-model="inviteCode"
            label="邀请码"
            placeholder="请输入6位邀请码"
            maxlength="6"
            :rules="[{ required: true, message: '请输入邀请码' }]"
          />
          <van-field
            v-model="relation"
            label="与老人关系"
            placeholder="请选择或填写关系"
            is-link
            readonly
            @click="showRelationPicker = true"
          />
          <van-button
            round
            block
            type="primary"
            native-type="submit"
            :loading="loading"
            class="bind-btn"
          >
            确认绑定
          </van-button>
        </van-form>
      </div>

      <!-- 已绑定列表 -->
      <div class="bound-section" v-if="elderlyList.length > 0">
        <h3 class="section-title">已绑定的老人</h3>
        <div
          v-for="elderly in elderlyList"
          :key="elderly.id"
          class="bound-card card"
        >
          <div class="bound-info">
            <span class="bound-name">{{ elderly.elderlyName }}</span>
            <span class="bound-relation">{{ elderly.relation }}</span>
          </div>
          <van-button
            size="small"
            round
            @click="handleUnbind(elderly.id)"
          >
            解除
          </van-button>
        </div>
      </div>
    </div>

    <van-popup v-model:show="showRelationPicker" position="bottom" round>
      <van-picker
        :columns="relationOptions"
        @confirm="onRelationConfirm"
        @cancel="showRelationPicker = false"
      />
    </van-popup>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { showToast, showConfirmDialog } from 'vant'
import StandardLayout from '../../components/StandardLayout.vue'
import { bindElderly, getMyElderly, unbind } from '../../api/binding'
import { RELATION_OPTIONS } from '../../utils/constants'

const inviteCode = ref('')
const relation = ref('')
const loading = ref(false)
const showRelationPicker = ref(false)
const elderlyList = ref([])

const relationOptions = RELATION_OPTIONS.map(r => ({ text: r.label, value: r.value }))

function onRelationConfirm({ selectedOptions }) {
  relation.value = selectedOptions[0].value
  showRelationPicker.value = false
}

async function handleBind() {
  loading.value = true
  try {
    await bindElderly({
      inviteCode: inviteCode.value.trim(),
      relation: relation.value || undefined
    })
    showToast('绑定成功')
    inviteCode.value = ''
    relation.value = ''
    loadBound()
  } catch (e) { /* */ }
  finally { loading.value = false }
}

async function handleUnbind(id) {
  try {
    await showConfirmDialog({ title: '确认', message: '确定解除绑定吗？' })
    await unbind(id)
    showToast('已解除绑定')
    loadBound()
  } catch (e) { /* */ }
}

async function loadBound() {
  try {
    const res = await getMyElderly()
    elderlyList.value = res.data || []
  } catch (e) { /* */ }
}

onMounted(loadBound)
</script>

<style scoped>
.bind-elderly {
  padding: var(--spacing-md);
}

.bind-desc {
  display: flex;
  gap: 10px;
  padding: 14px;
  background: #FFF8F0;
  border-radius: var(--radius-sm);
  margin-bottom: var(--spacing-md);
  font-size: var(--font-md);
  color: var(--text-secondary);
  line-height: 1.6;
}

.bind-desc .van-icon {
  margin-top: 2px;
  flex-shrink: 0;
}

.bind-btn {
  margin-top: 24px;
  height: 48px;
  font-size: var(--font-xl);
}

.bound-section {
  margin-top: 28px;
}

.section-title {
  font-size: var(--font-xl);
  font-weight: 600;
  margin-bottom: var(--spacing-sm);
}

.bound-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.bound-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.bound-name {
  font-size: var(--font-lg);
  font-weight: 500;
}

.bound-relation {
  font-size: var(--font-sm);
  color: var(--color-primary);
}
</style>
