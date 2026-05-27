<template>
  <StandardLayout
    title="我的家人"
    :show-back="false"
    :tabs="tabs"
  >
    <div class="family-home">
      <!-- 绑定老人列表 -->
      <div v-if="elderlyList.length > 0">
        <div
          v-for="elderly in elderlyList"
          :key="elderly.id"
          class="elderly-card card"
          @click="goElderlyTasks(elderly.elderlyId, elderly.elderlyName)"
        >
          <div class="elderly-avatar">
            <van-icon name="user-o" size="28" color="#FF8C00" />
          </div>
          <div class="elderly-info">
            <span class="elderly-name">{{ elderly.elderlyName }}</span>
            <span class="elderly-relation">{{ elderly.relation || '家属' }}</span>
          </div>
          <van-icon name="arrow" size="18" color="#999" />
        </div>
      </div>

      <EmptyState
        v-else
        description="尚未绑定老人，请先绑定"
        action-text="去绑定"
        @action="$router.push('/family/bind')"
      />
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import StandardLayout from '../../components/StandardLayout.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getMyElderly } from '../../api/binding'

const router = useRouter()
const elderlyList = ref([])

const tabs = [
  { name: 'home', label: '家人', icon: 'friends-o', route: '/family/home' },
  { name: 'bind', label: '绑定', icon: 'add-o', route: '/family/bind' },
  { name: 'profile', label: '我的', icon: 'user-o', route: '/family/profile' }
]

function goElderlyTasks(elderlyId, name) {
  router.push(`/family/elderly/${elderlyId}/tasks`)
}

async function loadElderly() {
  try {
    const res = await getMyElderly()
    elderlyList.value = res.data || []
  } catch (e) { /* */ }
}

onMounted(loadElderly)
</script>

<style scoped>
.family-home {
  padding: var(--spacing-md);
}

.elderly-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 16px;
  cursor: pointer;
  transition: transform 0.1s;
}

.elderly-card:active {
  transform: scale(0.98);
}

.elderly-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: #FFF3E0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.elderly-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.elderly-name {
  font-size: var(--font-xl);
  font-weight: 600;
}

.elderly-relation {
  font-size: var(--font-sm);
  color: var(--color-primary);
}
</style>
