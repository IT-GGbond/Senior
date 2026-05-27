<template>
  <div class="register-page">
    <van-nav-bar
      title="注册账号"
      left-text="返回"
      left-arrow
      @click-left="$router.back()"
    />

    <div class="register-content">
      <!-- 步骤指示 -->
      <van-steps :active="step" class="steps">
        <van-step>基本信息</van-step>
        <van-step>选择角色</van-step>
        <van-step>补充信息</van-step>
      </van-steps>

      <!-- 第0步：基本信息 -->
      <van-form v-if="step === 0" @submit="nextStep">
        <van-cell-group inset>
          <van-field
            v-model="form.code"
            name="code"
            label="用户标识"
            placeholder="请输入您的用户标识"
            :rules="[{ required: true, message: '请输入用户标识' }]"
          />
          <van-field
            v-model="form.nickname"
            name="nickname"
            label="昵称"
            placeholder="请输入昵称（选填）"
          />
        </van-cell-group>
        <div class="form-actions">
          <van-button round block type="primary" native-type="submit">
            下一步
          </van-button>
        </div>
      </van-form>

      <!-- 第1步：选择角色（多选） -->
      <div v-if="step === 1" class="role-select">
        <h3 class="section-title">请选择您的角色（可多选）</h3>
        <van-checkbox-group v-model="form.roles">
          <van-checkbox
            v-for="role in registerableRoles"
            :key="role.value"
            :name="role.value"
            icon-size="24"
            label-position="left"
            class="role-checkbox"
          >
            <div class="role-info">
              <span class="role-label">{{ role.label }}</span>
              <span class="role-desc">{{ role.desc }}</span>
            </div>
          </van-checkbox>
        </van-checkbox-group>
        <div class="form-actions">
          <van-button round block @click="step = 0">上一步</van-button>
          <van-button
            round
            block
            type="primary"
            :disabled="form.roles.length === 0"
            @click="step = 2"
          >
            下一步
          </van-button>
        </div>
      </div>

      <!-- 第2步：补充角色信息 -->
      <van-form v-if="step === 2" @submit="handleRegister">
        <van-cell-group inset>
          <van-field
            v-model="form.name"
            label="真实姓名"
            placeholder="请输入真实姓名（选填）"
          />
          <van-field
            v-model="form.phone"
            label="手机号"
            placeholder="请输入手机号（选填）"
          />

          <!-- 老人/志愿者需要社区信息 -->
          <van-field
            v-if="needsCommunity"
            v-model="form.community"
            label="所在社区"
            placeholder="请输入所在社区"
          />

          <!-- 家属需要关系信息 -->
          <van-field
            v-if="needsRelation"
            v-model="form.relation"
            label="与老人关系"
            placeholder="请填写与老人的关系（选填）"
          />
        </van-cell-group>

        <div class="form-actions">
          <van-button round block @click="step = 1">上一步</van-button>
          <van-button round block type="primary" native-type="submit" :loading="loading">
            完成注册
          </van-button>
        </div>
        <p class="register-note">注册后可在个人中心完善更多信息</p>
      </van-form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { useUserStore } from '../../stores/user'

const router = useRouter()
const userStore = useUserStore()

const registerableRoles = [
  { value: 'ELDERLY', label: '老人', desc: '查看任务、办事流程、求助' },
  { value: 'FAMILY', label: '家属', desc: '绑定老人、代建任务、查看进度' },
  { value: 'VOLUNTEER', label: '志愿者', desc: '接单求助、提供服务' }
]

const step = ref(0)
const loading = ref(false)

const form = ref({
  code: '',
  nickname: '',
  name: '',
  phone: '',
  community: '',
  relation: '',
  roles: []
})

const needsCommunity = computed(() =>
  form.value.roles.includes('ELDERLY') || form.value.roles.includes('VOLUNTEER')
)
const needsRelation = computed(() => form.value.roles.includes('FAMILY'))

function nextStep() {
  step.value = 1
}

async function handleRegister() {
  if (form.value.roles.length === 0) {
    showToast('请至少选择一个角色')
    return
  }
  loading.value = true
  try {
    await userStore.doRegister({
      code: form.value.code,
      nickname: form.value.nickname || undefined,
      name: form.value.name || undefined,
      phone: form.value.phone || undefined,
      community: form.value.community || undefined,
      relation: form.value.relation || undefined,
      roles: form.value.roles
    })
    showToast('注册成功')
    router.replace(userStore.homeRoute)
  } catch (e) {
    // 错误已在拦截器处理
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  background: var(--bg-page);
}

.register-content {
  padding: var(--spacing-md);
}

.steps {
  margin-bottom: 24px;
}

.section-title {
  font-size: var(--font-lg);
  font-weight: 600;
  margin-bottom: var(--spacing-md);
  color: var(--text-primary);
}

.role-checkbox {
  padding: var(--spacing-md);
  margin-bottom: var(--spacing-sm);
  background: var(--bg-white);
  border-radius: var(--radius-md);
  border: 1px solid var(--border-color);
}

.role-checkbox:active {
  background: #FFF3E0;
}

.role-checkbox :deep(.van-checkbox__icon) {
  flex-shrink: 0;
}

.role-checkbox :deep(.van-checkbox__label) {
  flex: 1;
  width: 100%;
}

.role-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.role-label {
  font-size: var(--font-lg);
  font-weight: 500;
}

.role-desc {
  font-size: var(--font-sm);
  color: var(--text-hint);
}

.form-actions {
  display: flex;
  gap: var(--spacing-sm);
  margin-top: 24px;
}

.form-actions .van-button {
  flex: 1;
  height: 44px;
}

.form-actions .van-button--primary {
  background: var(--color-primary);
  border-color: var(--color-primary);
}

.role-select .form-actions {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: var(--spacing-md);
  padding-bottom: calc(var(--spacing-md) + env(safe-area-inset-bottom));
  background: var(--bg-white);
  box-shadow: 0 -2px 8px rgba(0,0,0,0.08);
}

.role-select {
  padding-bottom: 100px;
}

.register-note {
  text-align: center;
  font-size: var(--font-sm);
  color: var(--text-hint);
  margin-top: 16px;
}
</style>
