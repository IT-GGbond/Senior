<template>
  <div class="step-list" :class="{ elderly: elderly }">
    <div
      v-for="(step, idx) in steps"
      :key="step.id || idx"
      class="step-item"
      :class="{
        'step-completed': step.isCompleted,
        'step-current': idx === currentIndex && !step.isCompleted
      }"
      @click="$emit('toggle', step)"
    >
      <div class="step-number">
        <van-icon
          v-if="step.isCompleted"
          name="success"
          color="#43A047"
          :size="elderly ? 28 : 20"
        />
        <span v-else>{{ idx + 1 }}</span>
      </div>
      <div class="step-content">
        <div class="step-title">{{ step.title }}</div>
        <div v-if="step.description" class="step-desc">{{ step.description }}</div>
      </div>
      <van-checkbox
        v-if="interactive"
        :model-value="!!step.isCompleted"
        @change="$emit('toggle', step)"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  steps: { type: Array, default: () => [] },
  elderly: { type: Boolean, default: false },
  interactive: { type: Boolean, default: true }
})

defineEmits(['toggle'])

const currentIndex = computed(() =>
  props.steps.findIndex(s => !s.isCompleted)
)
</script>

<style scoped>
.step-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 14px 0;
  border-bottom: 1px solid var(--border-color);
  cursor: pointer;
  transition: background 0.2s;
}

.step-item:active {
  background: #FFF8F0;
}

.step-item:last-child {
  border-bottom: none;
}

.step-number {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: var(--bg-gray);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: var(--font-sm);
  font-weight: 600;
  flex-shrink: 0;
  margin-top: 2px;
}

.step-completed .step-number {
  background: #E8F5E9;
}

.step-current .step-number {
  background: var(--color-primary);
  color: var(--text-white);
}

.step-completed .step-title {
  color: var(--text-hint);
  text-decoration: line-through;
}

.step-current .step-title {
  color: var(--color-primary);
  font-weight: 600;
}

.step-content {
  flex: 1;
  min-width: 0;
}

.step-title {
  font-size: var(--font-md);
  line-height: 1.5;
  word-break: break-all;
}

.step-desc {
  font-size: var(--font-sm);
  color: var(--text-secondary);
  margin-top: 4px;
}

/* 适老化 */
.step-list.elderly .step-title {
  font-size: var(--elderly-font-md);
}

.step-list.elderly .step-desc {
  font-size: var(--font-lg);
}

.step-list.elderly .step-number {
  width: 36px;
  height: 36px;
  font-size: var(--elderly-font-md);
}
</style>
