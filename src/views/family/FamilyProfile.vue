<template>
  <StandardLayout title="个人中心" :tabs="tabs">
    <div class="family-profile">
      <div class="user-card card">
        <van-image
          round
          width="56"
          height="56"
          :src="userInfo.avatarUrl || ''"
        >
          <template #loading>
            <van-icon name="user-o" size="36" color="#CCC" />
          </template>
        </van-image>
        <div class="user-info">
          <span class="user-name">{{ userInfo.name || userInfo.nickname || '未设置' }}</span>
          <span class="user-phone">{{ userInfo.phone || '未绑定手机号' }}</span>
        </div>
        <van-icon name="arrow" @click="showEditPopup = true" />
      </div>

      <div class="menu-section card">
        <van-cell title="编辑资料" icon="edit" is-link @click="showEditPopup = true" />
        <van-cell
          title="我绑定的老人"
          icon="friends-o"
          :value="`${elderlyCount}人`"
          is-link
          @click="$router.push('/family/home')"
        />
        <van-cell
          title="绑定新老人"
          icon="add-o"
          is-link
          @click="$router.push('/family/bind')"
        />
      </div>

      <!-- 角色切换 -->
      <div class="menu-section card" v-if="userStore.roles.length > 1">
        <div class="section-label">切换角色</div>
        <van-cell
          v-for="role in userStore.roles"
          :key="role"
          :title="roleMap[role]"
          :value="role === userStore.activeRole ? '当前' : ''"
          @click="switchRole(role)"
        />
      </div>

      <van-button round block class="logout-btn" @click="handleLogout">退出登录</van-button>

      <!-- 编辑弹窗 -->
      <van-popup v-model:show="showEditPopup" position="bottom" round :style="{ padding: '24px' }">
        <h3 class="popup-title">编辑资料</h3>
        <van-field v-model="editForm.name" label="姓名" placeholder="请输入姓名" />
        <van-field v-model="editForm.phone" label="手机号" placeholder="请输入手机号" />
        <van-button type="primary" round block :loading="saving" class="save-btn" @click="saveProfile">保存</van-button>
      </van-popup>
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import StandardLayout from '../../components/StandardLayout.vue'
import { useUserStore } from '../../stores/user'
import { updateUserInfo } from '../../api/user'
import { getMyElderly } from '../../api/binding'

const router = useRouter()
const userStore = useUserStore()

const tabs = [
  { name: 'home', label: '家人', icon: 'friends-o', route: '/family/home' },
  { name: 'bind', label: '绑定', icon: 'add-o', route: '/family/bind' },
  { name: 'profile', label: '我的', icon: 'user-o', route: '/family/profile' }
]
const userInfo = computed(() => userStore.userInfo || {})

const roleMap = { ELDERLY: '老人', FAMILY: '家属', VOLUNTEER: '志愿者', ADMIN: '管理员' }

const elderlyCount = ref(0)
const showEditPopup = ref(false)
const saving = ref(false)
const editForm = ref({ name: '', phone: '' })

function switchRole(role) {
  userStore.switchRole(role)
  const routeMap = {
    ELDERLY: '/elderly/home',
    FAMILY: '/family/home',
    VOLUNTEER: '/volunteer/home',
    ADMIN: '/admin/home'
  }
  router.replace(routeMap[role] || '/')
}

async function saveProfile() {
  saving.value = true
  try {
    await updateUserInfo({ name: editForm.value.name, phone: editForm.value.phone })
    await userStore.fetchUserInfo()
    showToast('保存成功')
    showEditPopup.value = false
  } catch (e) { /* */ }
  finally { saving.value = false }
}

function handleLogout() {
  userStore.logout()
  router.replace('/login')
}

async function loadCount() {
  try {
    const res = await getMyElderly()
    elderlyCount.value = (res.data || []).length
  } catch (e) { /* */ }
}

onMounted(() => {
  loadCount()
  editForm.value = {
    name: userInfo.value.name || '',
    phone: userInfo.value.phone || ''
  }
})
</script>

<style scoped>
.family-profile {
  padding: var(--spacing-md);
}

.user-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px;
}

.user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.user-name {
  font-size: var(--font-xl);
  font-weight: 600;
}

.user-phone {
  font-size: var(--font-md);
  color: var(--text-hint);
}

.menu-section {
  margin-top: var(--spacing-md);
}

.section-label {
  padding: 12px 16px 4px;
  font-size: var(--font-sm);
  color: var(--text-hint);
}

.logout-btn {
  margin-top: 32px;
  height: 48px;
  color: var(--text-hint);
  border-color: var(--border-color);
}

.popup-title {
  font-size: var(--font-xl);
  font-weight: 600;
  margin-bottom: 16px;
  text-align: center;
}

.save-btn {
  margin-top: 24px;
  height: 48px;
}
</style>
