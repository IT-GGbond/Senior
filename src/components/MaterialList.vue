<template>
  <div class="material-list" :class="{ elderly: elderly }">
    <div
      v-for="item in materials"
      :key="item.id"
      class="material-item"
      :class="{ 'material-checked': item.isChecked }"
      @click="interactive && $emit('toggle', item)"
    >
      <van-icon
        :name="item.isChecked ? 'checked' : 'circle'"
        :color="item.isChecked ? '#43A047' : '#CCCCCC'"
        :size="elderly ? 26 : 20"
      />
      <span class="material-name">{{ item.name }}</span>
    </div>
  </div>
</template>

<script setup>
defineProps({
  materials: { type: Array, default: () => [] },
  elderly: { type: Boolean, default: false },
  interactive: { type: Boolean, default: true }
})

defineEmits(['toggle'])
</script>

<style scoped>
.material-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid var(--border-color);
  cursor: pointer;
}

.material-item:active {
  background: #FFF8F0;
}

.material-item:last-child {
  border-bottom: none;
}

.material-checked .material-name {
  color: var(--text-hint);
  text-decoration: line-through;
}

.material-name {
  font-size: var(--font-md);
  flex: 1;
}

/* 适老化 */
.material-list.elderly .material-name {
  font-size: var(--elderly-font-md);
}

.material-list.elderly .material-item {
  padding: 16px 0;
}
</style>
