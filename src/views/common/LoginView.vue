<template>
  <div class="login-page">
    <div class="login-header">
      <h1 class="app-name">银龄配办</h1>
      <p class="app-desc">生活事务辅助与社区互助平台</p>
    </div>

    <div class="login-form">
      <van-field
        v-model="openid"
        label="用户标识"
        placeholder="请输入您的用户标识"
        clearable
        :rules="[{ required: true, message: '请输入用户标识' }]"
      />
      <van-button
        type="primary"
        round
        block
        :loading="loading"
        class="login-btn"
        @click="handleLogin"
      >
        登录
      </van-button>
      <van-button
        round
        block
        class="register-btn"
        @click="$router.push('/register')"
      >
        注册新账号
      </van-button>
    </div>

    <p class="login-tip">提示：输入任意标识即可登录/注册</p>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { useUserStore } from '../../stores/user'

const router = useRouter()
const userStore = useUserStore()

const openid = ref('')
const loading = ref(false)

async function handleLogin() {
  if (!openid.value.trim()) {
    showToast('请输入用户标识')
    return
  }
  loading.value = true
  try {
    const data = await userStore.doLogin(openid.value.trim())
    if (data.registered) {
      showToast('登录成功')
      router.replace(userStore.homeRoute)
    } else {
      showToast('该账号未注册，请先注册')
      router.push('/register')
    }
  } catch (e) {
    // 错误已在拦截器处理
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 24px;
  background: linear-gradient(135deg, #FFF3E0 0%, #F9F5F0 100%);
}

.login-header {
  text-align: center;
  margin-bottom: 48px;
}

.app-name {
  font-size: 36px;
  font-weight: 700;
  color: var(--color-primary);
  margin-bottom: 12px;
}

.app-desc {
  font-size: var(--font-lg);
  color: var(--text-secondary);
}

.login-form {
  width: 100%;
  max-width: 360px;
}

.login-form :deep(.van-cell) {
  border-radius: var(--radius-md);
  margin-bottom: var(--spacing-lg);
}

.login-btn {
  height: 48px;
  font-size: var(--font-xl);
  margin-bottom: var(--spacing-md);
  background: var(--color-primary);
  border-color: var(--color-primary);
}

.register-btn {
  height: 48px;
  font-size: var(--font-xl);
  color: var(--color-primary);
  border-color: var(--color-primary);
}

.login-tip {
  margin-top: 32px;
  font-size: var(--font-sm);
  color: var(--text-hint);
  text-align: center;
}
</style>
