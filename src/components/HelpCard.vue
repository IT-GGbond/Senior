<template>
  <div class="help-card card" :class="{ 'elderly-card': elderly }" @click="$emit('click')">
    <div class="help-header">
      <h3>求助</h3>
      <van-tag :type="statusTagType" :class="{ 'elderly-tag': elderly }">
        {{ statusMap[help.status] || help.status }}
      </van-tag>
    </div>

    <div class="help-body">
      <div v-if="help.description" class="help-desc">
        {{ help.description }}
      </div>
      <div class="help-meta">
        <div v-if="help.location" class="meta-item">
          <van-icon name="location-o" />
          <span>{{ help.location }}</span>
        </div>
        <div v-if="help.community" class="meta-item">
          <van-icon name="friends-o" />
          <span>{{ help.community }}</span>
        </div>
        <div v-if="help.phone" class="meta-item">
          <van-icon name="phone-o" />
          <span>{{ help.phone }}</span>
        </div>
      </div>
    </div>

    <div class="help-footer" v-if="showActions && help.status === 'WAITING'">
      <slot name="actions" />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { HELP_STATUS } from '../utils/constants'

const props = defineProps({
  help: { type: Object, required: true },
  elderly: { type: Boolean, default: false },
  showActions: { type: Boolean, default: false }
})

defineEmits(['click'])

const statusMap = HELP_STATUS

const statusTagType = computed(() => {
  const map = {
    WAITING: 'warning',
    ACCEPTED: 'primary',
    IN_SERVICE: 'primary',
    COMPLETED: 'success',
    CANCELLED: 'danger'
  }
  return map[props.help.status] || 'default'
})
</script>

<style scoped>
.help-card {
  cursor: pointer;
}

.help-card:active {
  transform: scale(0.98);
}

.help-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.help-header h3 {
  font-size: var(--font-lg);
  font-weight: 600;
}

.help-desc {
  font-size: var(--font-md);
  color: var(--text-secondary);
  margin-bottom: 10px;
  line-height: 1.5;
}

.help-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 16px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: var(--font-sm);
  color: var(--text-secondary);
}

.help-footer {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--border-color);
}

/* 适老化 */
.elderly-card .help-header h3 {
  font-size: var(--elderly-font-lg);
}

.elderly-card .help-desc {
  font-size: var(--elderly-font-md);
}

.elderly-card .meta-item {
  font-size: var(--elderly-font-md);
}

.elderly-tag {
  font-size: var(--elderly-font-md) !important;
  padding: 6px 12px;
}
</style>
