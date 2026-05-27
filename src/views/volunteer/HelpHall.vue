<template>
  <StandardLayout
    title="求助大厅"
    :show-back="false"
    :tabs="tabs"
  >
    <div class="help-hall">
      <!-- 社区筛选 -->
      <div class="filter-bar">
        <van-field
          v-model="community"
          placeholder="输入社区名称筛选求助"
          clearable
          @change="loadHelp"
        >
          <template #button>
            <van-button size="small" type="primary" round @click="loadHelp">
              筛选
            </van-button>
          </template>
        </van-field>
      </div>

      <div v-if="helpList.length > 0">
        <HelpCard
          v-for="item in helpList"
          :key="item.id"
          :help="item"
          :show-actions="true"
        >
          <template #actions>
            <div class="help-actions">
              <div class="elderly-contact">
                <span v-if="item.phone">联系方式：{{ item.phone }}</span>
              </div>
              <van-button
                type="primary"
                round
                size="small"
                @click="handleAccept(item)"
              >
                接单
              </van-button>
            </div>
          </template>
        </HelpCard>
      </div>

      <EmptyState
        v-else
        :description="community ? '该社区暂无待接单求助' : '请输入社区名称查看求助'"
      />
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import StandardLayout from '../../components/StandardLayout.vue'
import HelpCard from '../../components/HelpCard.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getWaitingHelp, acceptHelp } from '../../api/help'

const router = useRouter()
const community = ref('')
const helpList = ref([])

const tabs = [
  { name: 'home', label: '求助大厅', icon: 'search', route: '/volunteer/home' },
  { name: 'orders', label: '我的接单', icon: 'orders-o', route: '/volunteer/orders' },
  { name: 'profile', label: '我的', icon: 'user-o', route: '/volunteer/profile' }
]

async function loadHelp() {
  if (!community.value.trim()) {
    helpList.value = []
    return
  }
  try {
    const res = await getWaitingHelp(community.value.trim())
    helpList.value = res.data || []
  } catch (e) { /* */ }
}

async function handleAccept(item) {
  try {
    await acceptHelp(item.id)
    // 保存到本地，供"我的接单"页面使用
    const stored = localStorage.getItem('volunteer_orders')
    const orders = stored ? JSON.parse(stored) : []
    // 避免重复
    if (!orders.find(o => o.id === item.id)) {
      orders.unshift({ ...item, status: 'ACCEPTED' })
      localStorage.setItem('volunteer_orders', JSON.stringify(orders))
    }
    showToast('接单成功，请前往"我的接单"查看')
    loadHelp()
  } catch (e) { /* */ }
}

onMounted(() => {
  // 尝试加载同社区的求助（如果用户有社区信息）
})
</script>

<style scoped>
.help-hall {
  padding: var(--spacing-md);
}

.filter-bar {
  margin-bottom: var(--spacing-md);
}

.filter-bar :deep(.van-cell) {
  border-radius: var(--radius-md);
}

.help-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.elderly-contact {
  font-size: var(--font-sm);
  color: var(--text-secondary);
}
</style>
