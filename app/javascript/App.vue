<template>
  <div id="app" class="min-h-screen bg-gray-50">
    <!-- Navbar -->
    <Navbar v-if="isAuthenticated" />

    <!-- Main Content -->
    <main :class="{ 'ml-64': isAuthenticated }">
      <div class="p-6">
        <router-view />
      </div>
    </main>

    <!-- Loading Overlay -->
    <div v-if="isLoading" class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">
      <div class="bg-white rounded-lg p-6 text-center">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
        <p>Yükleniyor...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useAuthStore } from './stores/auth'
import { useAppStore } from './stores/app'
import Navbar from './components/Navbar.vue'

const authStore = useAuthStore()
const appStore = useAppStore()

const isAuthenticated = computed(() => authStore.isAuthenticated)
const isLoading = computed(() => appStore.isLoading)

onMounted(async () => {
  // Sayfa yüklendiğinde kullanıcı bilgilerini kontrol et
  await authStore.checkAuth()
})
</script>

<style>
/* Tailwind CSS gerekli stilleri */
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

/* Global styles */
#app {
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
