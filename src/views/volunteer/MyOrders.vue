<template>
  <StandardLayout title="我的接单" :tabs="tabs">
    <div class="my-orders">
      <van-tabs v-model:active="activeTab">
        <van-tab title="进行中" />
        <van-tab title="已完成" />
      </van-tabs>

      <!-- 进行中 -->
      <div class="order-list" v-if="activeTab === 0">
        <div v-if="activeOrders.length > 0">
          <div
            v-for="item in activeOrders"
            :key="item.id"
            class="order-card card"
          >
            <div class="order-header">
              <h4>求助详情</h4>
              <van-tag type="primary">{{ item.status === 'ACCEPTED' ? '已接单' : '服务中' }}</van-tag>
            </div>
            <div class="order-info">
              <div class="info-row" v-if="item.description">
                <span class="info-label">描述：</span>{{ item.description }}
              </div>
              <div class="info-row" v-if="item.location">
                <span class="info-label">位置：</span>{{ item.location }}
              </div>
              <div class="info-row" v-if="item.phone">
                <span class="info-label">电话：</span>
                <a :href="'tel:' + item.phone">{{ item.phone }}</a>
              </div>
            </div>
            <div class="order-actions">
              <van-button
                size="small"
                round
                type="primary"
                @click="$router.push(`/volunteer/record/${item.id}`)"
              >
                记录服务
              </van-button>
            </div>
          </div>
        </div>
        <EmptyState v-else description="暂无进行中的服务，去求助大厅接单吧" action-text="去接单" @action="$router.push('/volunteer/home')" />
      </div>

      <!-- 已完成（服务记录） -->
      <div class="order-list" v-if="activeTab === 1">
        <div v-if="records.length > 0">
          <div
            v-for="record in records"
            :key="record.id"
            class="order-card card"
          >
            <div class="order-header">
              <h4>服务记录</h4>
              <van-tag type="success">已完成</van-tag>
            </div>
            <div class="order-info">
              <div class="info-row" v-if="record.serviceType">
                <span class="info-label">方式：</span>{{ record.serviceType === 'ONLINE' ? '线上指导' : '线下协助' }}
              </div>
              <div class="info-row" v-if="record.duration">
                <span class="info-label">时长：</span>{{ record.duration }} 分钟
              </div>
              <div class="info-row" v-if="record.content">
                <span class="info-label">内容：</span>{{ record.content }}
              </div>
              <div class="info-row" v-if="record.points">
                <span class="info-label">积分：</span>+{{ record.points }}
              </div>
            </div>
          </div>
        </div>
        <EmptyState v-else description="暂无已完成的服务记录" />
      </div>
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import StandardLayout from '../../components/StandardLayout.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getMyRecords } from '../../api/service'

const activeTab = ref(0)
const records = ref([])
const activeOrders = ref([])

const tabs = [
  { name: 'home', label: '求助大厅', icon: 'search', route: '/volunteer/home' },
  { name: 'orders', label: '我的接单', icon: 'orders-o', route: '/volunteer/orders' },
  { name: 'profile', label: '我的', icon: 'user-o', route: '/volunteer/profile' }
]

function loadActiveOrders() {
  try {
    const stored = localStorage.getItem('volunteer_orders')
    activeOrders.value = stored ? JSON.parse(stored) : []
  } catch (e) {
    activeOrders.value = []
  }
}

async function loadRecords() {
  try {
    const res = await getMyRecords()
    records.value = res.data || []
  } catch (e) { /* */ }
}

onMounted(() => {
  loadActiveOrders()
  loadRecords()
})
</script>

<style scoped>
.my-orders {
  padding: var(--spacing-md);
}

.order-list {
  margin-top: var(--spacing-md);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.order-header h4 {
  font-size: var(--font-lg);
  font-weight: 600;
}

.order-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.info-row {
  font-size: var(--font-md);
  line-height: 1.5;
}

.info-label {
  color: var(--text-hint);
}

.info-row a {
  color: var(--color-primary);
}

.order-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--border-color);
}
</style>
