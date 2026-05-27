<template>
  <div class="standard-layout">
    <header class="standard-header" v-if="showHeader">
      <van-nav-bar
        :title="title"
        :left-text="showBack ? '返回' : ''"
        :left-arrow="showBack"
        @click-left="$router.back()"
        safe-area-inset-top
      />
    </header>
    <main class="standard-main" :class="{ 'has-tabbar': showTabbar }">
      <slot />
    </main>
    <van-tabbar
      v-if="showTabbar && tabs.length > 0"
      v-model="activeTab"
      safe-area-inset-bottom
      @change="onTabChange"
    >
      <van-tabbar-item
        v-for="tab in tabs"
        :key="tab.name"
        :name="tab.name"
        :icon="tab.icon"
      >
        {{ tab.label }}
      </van-tabbar-item>
    </van-tabbar>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const props = defineProps({
  title: { type: String, default: '' },
  showHeader: { type: Boolean, default: true },
  showBack: { type: Boolean, default: false },
  showTabbar: { type: Boolean, default: true },
  tabs: { type: Array, default: () => [] }
})

const emit = defineEmits(['tabChange'])

const router = useRouter()
const route = useRoute()

const activeTab = ref(props.tabs[0]?.name || '')

watch(() => route.path, (path) => {
  const matched = props.tabs.find(t => path.includes(t.route))
  if (matched) activeTab.value = matched.name
}, { immediate: true })

function onTabChange(name) {
  const tab = props.tabs.find(t => t.name === name)
  if (tab?.route) {
    router.push(tab.route)
  }
  emit('tabChange', name)
}
</script>

<style scoped>
.standard-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--bg-page);
}

.standard-header :deep(.van-nav-bar__title) {
  font-size: var(--font-xl);
  font-weight: 600;
}

.standard-main {
  flex: 1;
  overflow-y: auto;
  padding: var(--spacing-md);
}

.standard-main.has-tabbar {
  padding-bottom: 60px;
}
</style>
