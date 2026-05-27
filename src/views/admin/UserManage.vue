<template>
  <StandardLayout title="用户管理" :show-back="true" :show-tabbar="false">
    <div class="user-manage">
      <van-tabs v-model:active="activeRole" @change="loadUsers">
        <van-tab title="全部" name="" />
        <van-tab title="老人" name="ELDERLY" />
        <van-tab title="家属" name="FAMILY" />
        <van-tab title="志愿者" name="VOLUNTEER" />
      </van-tabs>

      <div class="user-list">
        <div v-if="users.length > 0">
          <div
            v-for="user in users"
            :key="user.id"
            class="user-item card"
          >
            <div class="user-avatar">
              <van-icon name="user-o" size="24" color="#FF8C00" />
            </div>
            <div class="user-detail">
              <span class="u-name">{{ user.name || user.nickname || '未设置' }}</span>
              <span class="u-phone">{{ user.phone || '未绑定手机' }}</span>
              <span class="u-community" v-if="user.community">{{ user.community }}</span>
            </div>
            <van-tag v-if="user.inviteCode" type="warning" size="small">
              {{ user.inviteCode }}
            </van-tag>
          </div>
        </div>
        <EmptyState v-else description="暂无用户数据" />
      </div>
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import StandardLayout from '../../components/StandardLayout.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getUsers } from '../../api/admin'

const activeRole = ref('')
const users = ref([])

async function loadUsers() {
  try {
    const res = await getUsers(activeRole.value || undefined)
    users.value = res.data || []
  } catch (e) { /* */ }
}

onMounted(loadUsers)
</script>

<style scoped>
.user-manage {
  padding: var(--spacing-md);
}

.user-list {
  margin-top: var(--spacing-md);
}

.user-item {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: var(--spacing-sm);
}

.user-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: #FFF3E0;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.user-detail {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}

.u-name {
  font-size: var(--font-lg);
  font-weight: 500;
}

.u-phone {
  font-size: var(--font-sm);
  color: var(--text-hint);
}

.u-community {
  font-size: var(--font-sm);
  color: var(--text-secondary);
}
</style>
