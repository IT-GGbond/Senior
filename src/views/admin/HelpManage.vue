<template>
  <StandardLayout title="求助管理" :show-back="true" :show-tabbar="false">
    <div class="help-manage">
      <van-tabs v-model:active="activeStatus" @change="loadHelp">
        <van-tab title="全部" name="" />
        <van-tab title="待接单" name="WAITING" />
        <van-tab title="已接单" name="ACCEPTED" />
        <van-tab title="服务中" name="IN_SERVICE" />
        <van-tab title="已完成" name="COMPLETED" />
      </van-tabs>

      <div class="help-list">
        <div v-if="helpList.length > 0">
          <HelpCard
            v-for="item in helpList"
            :key="item.id"
            :help="item"
          />
        </div>
        <EmptyState v-else description="暂无相关求助记录" />
      </div>
    </div>
  </StandardLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import StandardLayout from '../../components/StandardLayout.vue'
import HelpCard from '../../components/HelpCard.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getHelpRequests } from '../../api/admin'

const activeStatus = ref('')
const helpList = ref([])

async function loadHelp() {
  try {
    const res = await getHelpRequests(activeStatus.value || undefined)
    helpList.value = res.data || []
  } catch (e) { /* */ }
}

onMounted(loadHelp)
</script>

<style scoped>
.help-manage {
  padding: var(--spacing-md);
}

.help-list {
  margin-top: var(--spacing-md);
}
</style>
