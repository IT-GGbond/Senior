<template>
  <ElderlyLayout title="个人中心">
    <div class="profile elderly-page">
      <!-- 用户信息 -->
      <div class="user-card card">
        <van-image
          round
          width="60"
          height="60"
          :src="userInfo.avatarUrl || ''"
          class="avatar"
        >
          <template #loading>
            <van-icon name="user-o" size="40" color="#CCC" />
          </template>
        </van-image>
        <div class="user-info">
          <span class="user-name">{{ userInfo.name || userInfo.nickname || '未设置姓名' }}</span>
          <span class="user-phone">{{ userInfo.phone || '未绑定手机号' }}</span>
        </div>
        <van-icon name="arrow" size="20" @click="showEditPopup = true" />
      </div>

      <!-- 邀请码（仅老人角色） -->
      <div class="invite-card card" v-if="isElderly">
        <div class="invite-header">
          <span class="invite-label">我的邀请码</span>
          <span class="invite-desc">家属输入此码即可绑定</span>
        </div>
        <div class="invite-code" @click="copyInviteCode">
          <span class="code-text">{{ inviteCode || '加载中...' }}</span>
          <van-icon name="description" size="22" />
        </div>
        <span class="copy-tip" v-if="copied">已复制到剪贴板</span>
      </div>

      <!-- 快捷菜单 -->
      <div class="menu-section card">
        <van-cell title="全部事项" icon="orders-o" is-link @click="$router.push('/elderly/tasks')" />
        <van-cell title="已完成事项" icon="checked" is-link @click="$router.push('/elderly/tasks?status=COMPLETED')" />
        <van-cell title="我的求助记录" icon="phone-o" is-link @click="$router.push('/elderly/help')" />
        <van-cell title="绑定我的家属" icon="friends-o" is-link @click="showFamilyPopup = true" />
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

      <van-button round block class="logout-btn" @click="handleLogout">
        退出登录
      </van-button>
    </div>

    <!-- 编辑资料弹窗 -->
    <van-popup v-model:show="showEditPopup" position="bottom" round :style="{ padding: '24px' }">
      <h3 class="popup-title">编辑资料</h3>
      <van-field v-model="editForm.name" label="姓名" placeholder="请输入姓名" />
      <van-field v-model="editForm.phone" label="手机号" placeholder="请输入手机号" />
      <van-field v-model="editForm.community" label="所在社区" placeholder="请输入社区" />
      <van-button type="primary" round block :loading="saving" class="save-btn" @click="saveProfile">
        保存
      </van-button>
    </van-popup>

    <!-- 绑定家属列表弹窗 -->
    <van-popup v-model:show="showFamilyPopup" position="bottom" round :style="{ padding: '24px', maxHeight: '60vh', overflowY: 'auto' }">
      <h3 class="popup-title">绑定我的家属</h3>
      <div v-if="familyList.length > 0">
        <div
          v-for="f in familyList"
          :key="f.id"
          class="family-item"
        >
          <van-icon name="user-o" size="22" color="#FF8C00" />
          <div class="family-info">
            <span class="family-name">{{ f.familyName || '家属' }}</span>
            <span class="family-relation">{{ f.relation || '未设置关系' }}</span>
          </div>
        </div>
      </div>
      <EmptyState v-else description="暂无家属绑定，将邀请码发给家属即可绑定" />
    </van-popup>
  </ElderlyLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import ElderlyLayout from '../../components/ElderlyLayout.vue'
import EmptyState from '../../components/EmptyState.vue'
import { useUserStore } from '../../stores/user'
import { getInviteCode, updateUserInfo } from '../../api/user'
import { getMyFamily } from '../../api/binding'

const router = useRouter()
const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo || {})

const roleMap = { ELDERLY: '老人', FAMILY: '家属', VOLUNTEER: '志愿者', ADMIN: '管理员' }
const isElderly = computed(() => userStore.roles.includes('ELDERLY'))

const inviteCode = ref('')
const copied = ref(false)
const showEditPopup = ref(false)
const showFamilyPopup = ref(false)
const saving = ref(false)
const familyList = ref([])
const editForm = ref({ name: '', phone: '', community: '' })

async function loadInviteCode() {
  try {
    const res = await getInviteCode()
    inviteCode.value = res.data
  } catch (e) { /* */ }
}

async function copyInviteCode() {
  try {
    await navigator.clipboard.writeText(inviteCode.value)
    copied.value = true
    setTimeout(() => (copied.value = false), 2000)
  } catch (e) {
    showToast('复制失败')
  }
}

async function loadFamily() {
  try {
    const res = await getMyFamily()
    familyList.value = res.data || []
  } catch (e) { /* */ }
}

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
    await updateUserInfo({
      name: editForm.value.name,
      phone: editForm.value.phone,
      community: editForm.value.community
    })
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

onMounted(() => {
  if (isElderly.value) {
    loadInviteCode()
    loadFamily()
  }
  editForm.value = {
    name: userInfo.value.name || '',
    phone: userInfo.value.phone || '',
    community: userInfo.value.community || ''
  }
})
</script>

<style scoped>
.profile {
  padding: var(--spacing-md);
}

.user-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 20px;
}

.user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.user-name {
  font-size: var(--elderly-font-lg);
  font-weight: 600;
}

.user-phone {
  font-size: var(--elderly-font-md);
  color: var(--text-hint);
}

.invite-card {
  padding: 20px;
  text-align: center;
}

.invite-header {
  margin-bottom: 12px;
}

.invite-label {
  font-size: var(--elderly-font-lg);
  font-weight: 600;
  display: block;
}

.invite-desc {
  font-size: var(--font-md);
  color: var(--text-hint);
}

.invite-code {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: #FFF3E0;
  padding: 12px 24px;
  border-radius: var(--radius-md);
  cursor: pointer;
  letter-spacing: 4px;
}

.code-text {
  font-size: 28px;
  font-weight: 700;
  color: var(--color-primary);
  letter-spacing: 6px;
}

.copy-tip {
  display: block;
  margin-top: 8px;
  font-size: var(--font-md);
  color: var(--color-success);
}

.menu-section {
  margin-top: var(--spacing-md);
}

.section-label {
  padding: 12px 16px 4px;
  font-size: var(--font-sm);
  color: var(--text-hint);
}

.menu-section :deep(.van-cell__title) {
  font-size: var(--elderly-font-md);
}

.logout-btn {
  margin-top: 32px;
  height: 48px;
  font-size: var(--elderly-font-md);
  color: var(--text-hint);
  border-color: var(--border-color);
}

.popup-title {
  font-size: var(--elderly-font-lg);
  font-weight: 600;
  margin-bottom: 16px;
  text-align: center;
}

.save-btn {
  margin-top: 24px;
  height: 48px;
  background: var(--color-primary);
  border-color: var(--color-primary);
}

.family-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 0;
  border-bottom: 1px solid var(--border-color);
}

.family-item:last-child {
  border-bottom: none;
}

.family-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.family-name {
  font-size: var(--elderly-font-md);
  font-weight: 500;
}

.family-relation {
  font-size: var(--font-md);
  color: var(--text-hint);
}
</style>
