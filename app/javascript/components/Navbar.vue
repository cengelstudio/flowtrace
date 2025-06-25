<template>
  <div class="fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg border-r border-gray-200">
    <!-- Header -->
    <div class="flex items-center justify-between h-16 px-6 border-b border-gray-200">
      <div class="flex items-center">
        <svg class="w-8 h-8 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
          <path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z"/>
        </svg>
        <h1 class="ml-3 text-xl font-bold text-gray-900">FlowTrace</h1>
      </div>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 px-4 py-6 space-y-2">
      <router-link
        v-for="item in navigation"
        :key="item.name"
        :to="item.path"
        class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
        :class="[
          $route.path === item.path
            ? 'bg-blue-50 text-blue-700 border-r-2 border-blue-700'
            : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
        ]"
      >
        <component :is="item.icon" class="w-5 h-5 mr-3" />
        {{ item.name }}
        <span v-if="item.badge" class="ml-auto bg-red-100 text-red-600 px-2 py-1 text-xs rounded-full">
          {{ item.badge }}
        </span>
      </router-link>
    </nav>

    <!-- User Menu -->
    <div class="border-t border-gray-200 p-4">
      <div class="flex items-center">
        <div class="flex-shrink-0">
          <div class="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center">
            <span class="text-white text-sm font-medium">
              {{ userInitials }}
            </span>
          </div>
        </div>
        <div class="ml-3 flex-1">
          <p class="text-sm font-medium text-gray-900">{{ currentUser?.name || 'Kullanıcı' }}</p>
          <p class="text-xs text-gray-500">{{ currentUser?.email }}</p>
        </div>
        <div class="ml-3">
          <button
            @click="showUserMenu = !showUserMenu"
            class="flex items-center p-2 text-gray-400 hover:text-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500 rounded-md"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"/>
            </svg>
          </button>
        </div>
      </div>

      <!-- User Dropdown Menu -->
      <div v-if="showUserMenu" class="mt-3 py-2 bg-gray-50 rounded-lg">
        <router-link
          to="/settings"
          class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-md"
          @click="showUserMenu = false"
        >
          <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
          </svg>
          Ayarlar
        </router-link>
        <button
          @click="handleLogout"
          class="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 rounded-md"
        >
          <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
          </svg>
          Çıkış Yap
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

// Icons
import {
  HomeIcon,
  CubeIcon,
  BuildingStorefrontIcon,
  ArrowsRightLeftIcon,
  QrCodeIcon,
  ChartBarIcon,
  UsersIcon
} from '@heroicons/vue/24/outline'

const router = useRouter()
const authStore = useAuthStore()

const showUserMenu = ref(false)

const currentUser = computed(() => authStore.currentUser)
const userInitials = computed(() => {
  if (!currentUser.value?.name) return 'U'
  return currentUser.value.name
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
})

const navigation = computed(() => [
  {
    name: 'Dashboard',
    path: '/dashboard',
    icon: HomeIcon
  },
  {
    name: 'Depolar',
    path: '/warehouses',
    icon: BuildingStorefrontIcon
  },
  {
    name: 'Eşyalar',
    path: '/items',
    icon: CubeIcon
  },
  {
    name: 'İşlemler',
    path: '/transactions',
    icon: ArrowsRightLeftIcon
  },
  {
    name: 'QR Tarama',
    path: '/scan',
    icon: QrCodeIcon
  },
  {
    name: 'Raporlar',
    path: '/reports',
    icon: ChartBarIcon
  },
  ...(authStore.isAdmin ? [{
    name: 'Kullanıcılar',
    path: '/admin/users',
    icon: UsersIcon
  }] : [])
])

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}

// Close menu when clicking outside
const handleClickOutside = (event) => {
  if (!event.target.closest('.user-menu')) {
    showUserMenu.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>
