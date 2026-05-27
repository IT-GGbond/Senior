<template>
  <ElderlyLayout title="我的求助" :show-back="true">
    <div class="my-help elderly-page">
      <!-- 发起求助按钮 -->
      <van-button
        type="danger"
        round
        block
        icon="phone-o"
        class="new-help-btn"
        @click="showHelpPopup = true"
      >
        一键求助
      </van-button>

      <div v-if="helpList.length > 0">
        <HelpCard
          v-for="item in helpList"
          :key="item.id"
          :help="item"
          :elderly="true"
        >
          <template #actions>
            <div class="help-actions">
              <van-button
                v-if="item.status === 'WAITING'"
                round
                size="small"
                @click="cancelHelp(item.id)"
              >
                取消求助
              </van-button>
              <span v-else-if="item.status === 'ACCEPTED' || item.status === 'IN_SERVICE'" class="accepted-tip">
                志愿者已接单，请保持电话畅通
              </span>
              <van-button
                v-if="item.status === 'COMPLETED'"
                round
                size="small"
                type="warning"
                icon="star-o"
                @click="openReview(item)"
              >
                评价服务
              </van-button>
            </div>
          </template>
        </HelpCard>
      </div>
      <EmptyState v-else description="暂无求助记录" />
    </div>

    <!-- 发起求助弹窗 -->
    <van-popup v-model:show="showHelpPopup" position="bottom" round :style="{ padding: '24px' }">
      <h3 class="popup-title">发起求助</h3>
      <van-field
        v-model="helpForm.description"
        label="问题描述"
        placeholder="请简单描述一下遇到的问题"
        type="textarea"
        rows="3"
      />
      <van-field
        v-model="helpForm.location"
        label="所在位置"
        placeholder="请输入您当前的位置"
      />
      <van-button
        type="danger"
        round
        block
        :loading="helpLoading"
        class="submit-btn"
        @click="submitHelp"
      >
        立即求助
      </van-button>
    </van-popup>

    <!-- 评价弹窗 -->
    <van-popup v-model:show="showReviewPopup" position="bottom" round :style="{ padding: '24px' }">
      <h3 class="popup-title">评价服务</h3>
      <div class="rating-row">
        <span class="rating-label">评分</span>
        <van-rate v-model="reviewForm.rating" :size="28" color="#FF8C00" void-color="#E5E5E5" />
      </div>
      <van-field
        v-model="reviewForm.comment"
        label="评语"
        placeholder="请输入评语（选填）"
        type="textarea"
        rows="2"
      />
      <van-button
        type="primary"
        round
        block
        :loading="reviewLoading"
        class="submit-btn"
        @click="submitReview"
      >
        提交评价
      </van-button>
    </van-popup>
  </ElderlyLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { showToast, showConfirmDialog } from 'vant'
import ElderlyLayout from '../../components/ElderlyLayout.vue'
import HelpCard from '../../components/HelpCard.vue'
import EmptyState from '../../components/EmptyState.vue'
import { getMyHelp, cancelHelp as cancelHelpApi, createHelp } from '../../api/help'
import { submitReview as submitReviewApi } from '../../api/service'

const helpList = ref([])
const showReviewPopup = ref(false)
const reviewLoading = ref(false)
const currentHelp = ref(null)
const reviewForm = ref({ rating: 0, comment: '', serviceRecordId: null })

const showHelpPopup = ref(false)
const helpLoading = ref(false)
const helpForm = ref({ description: '', location: '' })

async function submitHelp() {
  if (!helpForm.value.description.trim()) {
    showToast('请填写问题描述')
    return
  }
  helpLoading.value = true
  try {
    await createHelp({
      description: helpForm.value.description,
      location: helpForm.value.location || undefined
    })
    showToast('求助已发出，请等待志愿者响应')
    showHelpPopup.value = false
    helpForm.value = { description: '', location: '' }
    loadHelp()
  } catch (e) { /* */ }
  finally { helpLoading.value = false }
}

async function loadHelp() {
  try {
    const res = await getMyHelp()
    helpList.value = res.data || []
  } catch (e) { /* */ }
}

async function cancelHelp(id) {
  try {
    await showConfirmDialog({ title: '确认', message: '确定取消求助吗？' })
    await cancelHelpApi(id)
    showToast('已取消')
    loadHelp()
  } catch (e) { /* */ }
}

function openReview(item) {
  currentHelp.value = item
  reviewForm.value = { rating: 0, comment: '', serviceRecordId: item.serviceRecordId || null }
  showReviewPopup.value = true
}

async function submitReview() {
  if (reviewForm.value.rating === 0) {
    showToast('请选择评分')
    return
  }
  if (!reviewForm.value.serviceRecordId) {
    showToast('暂未找到服务记录，请联系志愿者确认')
    return
  }
  reviewLoading.value = true
  try {
    await submitReviewApi({
      serviceRecordId: reviewForm.value.serviceRecordId,
      rating: reviewForm.value.rating,
      comment: reviewForm.value.comment || undefined
    })
    showToast('评价提交成功，感谢您的反馈！')
    showReviewPopup.value = false
    loadHelp()
  } catch (e) { /* */ }
  finally { reviewLoading.value = false }
}

onMounted(loadHelp)
</script>

<style scoped>
.my-help {
  padding: var(--spacing-md);
}

.new-help-btn {
  height: 56px;
  font-size: var(--elderly-font-xl);
  margin-bottom: var(--spacing-lg);
}

.help-actions {
  display: flex;
  justify-content: flex-end;
}

.accepted-tip {
  font-size: var(--elderly-font-md);
  color: var(--color-primary);
  font-weight: 500;
}

.popup-title {
  font-size: var(--elderly-font-lg);
  font-weight: 600;
  margin-bottom: 16px;
  text-align: center;
}

.rating-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
}

.rating-label {
  font-size: var(--elderly-font-md);
  color: var(--text-primary);
}

.submit-btn {
  margin-top: 24px;
  height: 48px;
  font-size: var(--elderly-font-md);
}
</style>
