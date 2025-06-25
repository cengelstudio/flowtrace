<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p class="text-gray-600">Sistem genel durumu ve hızlı erişim</p>
      </div>
      <div class="text-right">
        <p class="text-sm text-gray-500">Son güncelleme</p>
        <p class="text-sm font-medium text-gray-900">{{ lastUpdate }}</p>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div
        v-for="stat in stats"
        :key="stat.name"
        class="bg-white rounded-lg shadow p-6 border border-gray-200"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">{{ stat.name }}</p>
            <p class="text-2xl font-bold text-gray-900">{{ stat.value }}</p>
            <p class="text-sm text-gray-500 mt-1">{{ stat.description }}</p>
          </div>
          <div class="flex-shrink-0">
            <component
              :is="stat.icon"
              class="w-8 h-8"
              :class="stat.iconColor"
            />
          </div>
        </div>
        <div class="mt-4 flex items-center">
          <span
            class="text-sm font-medium"
            :class="stat.changeType === 'increase' ? 'text-green-600' : 'text-red-600'"
          >
            {{ stat.change }}
          </span>
          <span class="text-sm text-gray-500 ml-2">son aydan</span>
        </div>
      </div>
    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Recent Transactions -->
      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold text-gray-900">Son İşlemler</h3>
          <router-link
            to="/transactions"
            class="text-sm text-blue-600 hover:text-blue-800 font-medium"
          >
            Tümünü Görüntüle
          </router-link>
        </div>
        <div class="space-y-3">
          <div
            v-for="transaction in recentTransactions"
            :key="transaction.id"
            class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
          >
            <div class="flex items-center space-x-3">
              <div
                class="w-2 h-2 rounded-full"
                :class="getTransactionStatusColor(transaction.type)"
              ></div>
              <div>
                <p class="text-sm font-medium text-gray-900">{{ transaction.item_name }}</p>
                <p class="text-xs text-gray-500">{{ transaction.user_name }}</p>
              </div>
            </div>
            <div class="text-right">
              <p class="text-sm text-gray-900">{{ formatDate(transaction.created_at) }}</p>
              <p class="text-xs text-gray-500">{{ transaction.type }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Warehouse Status -->
      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold text-gray-900">Depo Durumu</h3>
          <router-link
            to="/warehouses"
            class="text-sm text-blue-600 hover:text-blue-800 font-medium"
          >
            Tümünü Görüntüle
          </router-link>
        </div>
        <div class="space-y-4">
          <div
            v-for="warehouse in warehouseStats"
            :key="warehouse.id"
            class="flex items-center justify-between"
          >
            <div>
              <p class="text-sm font-medium text-gray-900">{{ warehouse.name }}</p>
              <p class="text-xs text-gray-500">{{ warehouse.location }}</p>
            </div>
            <div class="text-right">
              <p class="text-sm font-medium text-gray-900">{{ warehouse.item_count }} eşya</p>
              <div class="w-16 bg-gray-200 rounded-full h-2 mt-1">
                <div
                  class="bg-blue-600 h-2 rounded-full"
                  :style="{ width: `${warehouse.occupancy}%` }"
                ></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="bg-white rounded-lg shadow p-6">
      <h3 class="text-lg font-semibold text-gray-900 mb-4">Hızlı İşlemler</h3>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <router-link
          to="/items/new"
          class="flex flex-col items-center p-4 bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors"
        >
          <PlusIcon class="w-8 h-8 text-blue-600 mb-2" />
          <span class="text-sm font-medium text-blue-900">Yeni Eşya</span>
        </router-link>

        <router-link
          to="/scan"
          class="flex flex-col items-center p-4 bg-green-50 hover:bg-green-100 rounded-lg transition-colors"
        >
          <QrCodeIcon class="w-8 h-8 text-green-600 mb-2" />
          <span class="text-sm font-medium text-green-900">QR Tara</span>
        </router-link>

        <router-link
          to="/warehouses/new"
          class="flex flex-col items-center p-4 bg-purple-50 hover:bg-purple-100 rounded-lg transition-colors"
        >
          <BuildingStorefrontIcon class="w-8 h-8 text-purple-600 mb-2" />
          <span class="text-sm font-medium text-purple-900">Yeni Depo</span>
        </router-link>

        <router-link
          to="/reports"
          class="flex flex-col items-center p-4 bg-orange-50 hover:bg-orange-100 rounded-lg transition-colors"
        >
          <ChartBarIcon class="w-8 h-8 text-orange-600 mb-2" />
          <span class="text-sm font-medium text-orange-900">Raporlar</span>
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { format } from 'date-fns'
import { tr } from 'date-fns/locale'
import {
  CubeIcon,
  BuildingStorefrontIcon,
  ArrowsRightLeftIcon,
  ExclamationCircleIcon,
  PlusIcon,
  QrCodeIcon,
  ChartBarIcon
} from '@heroicons/vue/24/outline'

// Reactive data
const stats = ref([
  {
    name: 'Toplam Eşya',
    value: '1,234',
    description: 'Sistemdeki toplam eşya',
    change: '+12%',
    changeType: 'increase',
    icon: CubeIcon,
    iconColor: 'text-blue-600'
  },
  {
    name: 'Aktif Depolar',
    value: '8',
    description: 'Kullanımdaki depo sayısı',
    change: '+2',
    changeType: 'increase',
    icon: BuildingStorefrontIcon,
    iconColor: 'text-green-600'
  },
  {
    name: 'Bekleyen İşlemler',
    value: '23',
    description: 'Tamamlanmayan işlemler',
    change: '-5%',
    changeType: 'decrease',
    icon: ArrowsRightLeftIcon,
    iconColor: 'text-orange-600'
  },
  {
    name: 'Geciken Eşyalar',
    value: '7',
    description: 'Teslim tarihi geçen eşyalar',
    change: '+3',
    changeType: 'increase',
    icon: ExclamationCircleIcon,
    iconColor: 'text-red-600'
  }
])

const recentTransactions = ref([
  {
    id: 1,
    item_name: 'Laptop Dell XPS 13',
    user_name: 'Ahmet Yılmaz',
    type: 'checkout',
    created_at: new Date(Date.now() - 2 * 60 * 60 * 1000) // 2 saat önce
  },
  {
    id: 2,
    item_name: 'Projeksiyon Makinesi',
    user_name: 'Ayşe Kaya',
    type: 'checkin',
    created_at: new Date(Date.now() - 4 * 60 * 60 * 1000) // 4 saat önce
  },
  {
    id: 3,
    item_name: 'Kamera Canon EOS',
    user_name: 'Mehmet Demir',
    type: 'checkout',
    created_at: new Date(Date.now() - 6 * 60 * 60 * 1000) // 6 saat önce
  }
])

const warehouseStats = ref([
  {
    id: 1,
    name: 'Ana Depo',
    location: 'Zemin Kat',
    item_count: 456,
    occupancy: 78
  },
  {
    id: 2,
    name: 'IT Deposu',
    location: '2. Kat',
    item_count: 234,
    occupancy: 45
  },
  {
    id: 3,
    name: 'Genel Depo',
    location: 'Bodrum',
    item_count: 123,
    occupancy: 23
  }
])

const lastUpdate = computed(() => {
  return format(new Date(), 'dd MMMM yyyy, HH:mm', { locale: tr })
})

const getTransactionStatusColor = (type) => {
  switch (type) {
    case 'checkout':
      return 'bg-orange-500'
    case 'checkin':
      return 'bg-green-500'
    default:
      return 'bg-gray-500'
  }
}

const formatDate = (date) => {
  return format(new Date(date), 'HH:mm', { locale: tr })
}

onMounted(async () => {
  // Gerçek API çağrıları burada yapılacak
  // await loadDashboardData()
})
</script>
