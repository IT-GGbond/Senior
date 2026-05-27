<template>
  <div class="elderly-layout">
    <header class="elderly-header" v-if="showHeader">
      <van-nav-bar
        :title="title"
        :left-text="showBack ? '返回' : ''"
        :left-arrow="showBack"
        @click-left="$router.back()"
        safe-area-inset-top
      />
    </header>
    <main class="elderly-main" :class="{ 'has-tabbar': showTabbar }">
      <slot />
    </main>
    <van-tabbar
      v-if="showTabbar"
      v-model="activeTab"
      safe-area-inset-bottom
      @change="onTabChange"
    >
      <van-tabbar-item name="home" icon="home-o">首页</van-tabbar-item>
      <van-tabbar-item name="help" icon="phone-o">求助</van-tabbar-item>
      <van-tabbar-item name="profile" icon="user-o">我的</van-tabbar-item>
    </van-tabbar>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'

defineProps({
  title: { type: String, default: '银龄配办' },
  showHeader: { type: Boolean, default: true },
  showBack: { type: Boolean, default: false },
  showTabbar: { type: Boolean, default: true }
})

const router = useRouter()
const route = useRoute()

const activeTab = ref('home')

watch(() => route.path, (path) => {
  if (path === '/elderly/profile') activeTab.value = 'profile'
  else if (path === '/elderly/help') activeTab.value = 'help'
  else if (path === '/elderly/home') activeTab.value = 'home'
}, { immediate: true })

function onTabChange(name) {
  if (name === 'home') router.push('/elderly/home')
  else if (name === 'help') router.push('/elderly/help')
  else if (name === 'profile') router.push('/elderly/profile')
}
</script>

<style scoped>
.elderly-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--bg-page);
}

.elderly-header :deep(.van-nav-bar) {
  background: var(--color-primary);
}

.elderly-header :deep(.van-nav-bar__title),
.elderly-header :deep(.van-nav-bar__text),
.elderly-header :deep(.van-icon) {
  color: var(--text-white);
  font-size: var(--elderly-font-md);
}

.elderly-main {
  flex: 1;
  overflow-y: auto;
  padding: var(--spacing-md);
  padding-bottom: var(--spacing-md);
}

.elderly-main.has-tabbar {
  padding-bottom: 60px;
}

:deep(.van-tabbar-item) {
  font-size: var(--elderly-font-md);
}
</style>
