<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Depolar</h1>
        <p class="text-gray-600">Depo lokasyonlarını görüntüleyin ve yönetin</p>
      </div>
      <router-link
        to="/warehouses/new"
        class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
      >
        <PlusIcon class="w-4 h-4 mr-2" />
        Yeni Depo
      </router-link>
    </div>

    <!-- Warehouses Grid -->
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      <p class="mt-2 text-sm text-gray-500">Depolar yükleniyor...</p>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="warehouse in warehouses"
        :key="warehouse.id"
        class="bg-white rounded-lg shadow border border-gray-200 hover:shadow-lg transition-shadow cursor-pointer"
        @click="viewWarehouse(warehouse)"
      >
        <div class="p-6">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center">
              <BuildingStorefrontIcon class="w-8 h-8 text-blue-600 mr-3" />
              <div>
                <h3 class="text-lg font-semibold text-gray-900">{{ warehouse.name }}</h3>
                <p class="text-sm text-gray-500">{{ warehouse.location }}</p>
              </div>
            </div>
            <div class="flex space-x-2">
              <button
                @click.stop="editWarehouse(warehouse)"
                class="text-indigo-600 hover:text-indigo-900"
                title="Düzenle"
              >
                <PencilIcon class="w-4 h-4" />
              </button>
              <button
                @click.stop="downloadQR(warehouse)"
                class="text-green-600 hover:text-green-900"
                title="QR İndir"
              >
                <QrCodeIcon class="w-4 h-4" />
              </button>
            </div>
          </div>

          <div class="space-y-3">
            <div class="flex justify-between items-center">
              <span class="text-sm text-gray-600">Toplam Eşya</span>
              <span class="text-sm font-medium text-gray-900">{{ warehouse.item_count || 0 }}</span>
            </div>

            <div class="flex justify-between items-center">
              <span class="text-sm text-gray-600">Doluluk Oranı</span>
              <span class="text-sm font-medium text-gray-900">{{ warehouse.occupancy || 0 }}%</span>
            </div>

            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                class="h-2 rounded-full"
                :class="getOccupancyColor(warehouse.occupancy)"
                :style="{ width: `${warehouse.occupancy || 0}%` }"
              ></div>
            </div>

            <div class="flex justify-between items-center pt-2">
              <span class="text-sm text-gray-600">Son Güncelleme</span>
              <span class="text-sm text-gray-500">{{ formatDate(warehouse.updated_at) }}</span>
            </div>
          </div>

          <div class="mt-4 pt-4 border-t border-gray-200">
            <div class="flex justify-between">
              <button
                @click.stop="viewItems(warehouse)"
                class="text-sm text-blue-600 hover:text-blue-800"
              >
                Eşyaları Görüntüle
              </button>
              <span class="text-xs text-gray-400">
                {{ warehouse.description || 'Açıklama yok' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="warehouses.length === 0" class="col-span-full">
        <div class="text-center py-12">
          <BuildingStorefrontIcon class="mx-auto h-12 w-12 text-gray-400" />
          <h3 class="mt-2 text-sm font-medium text-gray-900">Depo bulunamadı</h3>
          <p class="mt-1 text-sm text-gray-500">Henüz hiç depo eklenmemiş.</p>
          <div class="mt-6">
            <router-link
              to="/warehouses/new"
              class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
            >
              <PlusIcon class="w-4 h-4 mr-2" />
              İlk Deponu Ekle
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { format } from 'date-fns'
import { tr } from 'date-fns/locale'
import {
  BuildingStorefrontIcon,
  PlusIcon,
  PencilIcon,
  QrCodeIcon
} from '@heroicons/vue/24/outline'

const router = useRouter()
const loading = ref(false)

// Demo data
const warehouses = ref([
  {
    id: 1,
    name: 'Ana Depo',
    location: 'Zemin Kat, A Blok',
    description: 'Genel amaçlı ana depolama alanı',
    item_count: 456,
    occupancy: 78,
    updated_at: new Date(Date.now() - 2 * 60 * 60 * 1000)
  },
  {
    id: 2,
    name: 'IT Deposu',
    location: '2. Kat, Bilgi İşlem',
    description: 'Teknoloji ekipmanları için özel depo',
    item_count: 234,
    occupancy: 45,
    updated_at: new Date(Date.now() - 4 * 60 * 60 * 1000)
  },
  {
    id: 3,
    name: 'Genel Depo',
    location: 'Bodrum Kat',
    description: 'Çeşitli malzemeler için depolama',
    item_count: 123,
    occupancy: 23,
    updated_at: new Date(Date.now() - 6 * 60 * 60 * 1000)
  }
])

const getOccupancyColor = (occupancy) => {
  if (occupancy >= 80) return 'bg-red-500'
  if (occupancy >= 60) return 'bg-yellow-500'
  return 'bg-green-500'
}

const formatDate = (date) => {
  return format(new Date(date), 'dd.MM.yyyy HH:mm', { locale: tr })
}

const viewWarehouse = (warehouse) => {
  router.push(`/warehouses/${warehouse.id}`)
}

const editWarehouse = (warehouse) => {
  router.push(`/warehouses/${warehouse.id}/edit`)
}

const viewItems = (warehouse) => {
  router.push(`/items?warehouse_id=${warehouse.id}`)
}

const downloadQR = (warehouse) => {
  // QR download functionality
  alert(`${warehouse.name} QR kodu indiriliyor...`)
}

onMounted(() => {
  // Load warehouses from API
  loading.value = false
})
</script>
