<template>
  <div class="space-y-6">
    <!-- Breadcrumb -->
    <nav class="flex" aria-label="Breadcrumb">
      <ol class="inline-flex items-center space-x-1 md:space-x-3">
        <li class="inline-flex items-center">
          <router-link to="/warehouses" class="text-gray-700 hover:text-gray-900">
            Depolar
          </router-link>
        </li>
        <li>
          <div class="flex items-center">
            <span class="mx-2 text-gray-400">/</span>
            <span class="text-gray-500">{{ warehouse?.name || 'Depo Detayı' }}</span>
          </div>
        </li>
      </ol>
    </nav>

    <!-- Header -->
    <div class="bg-white shadow rounded-lg p-6">
      <div class="flex items-center justify-between">
        <div class="flex items-center space-x-4">
          <BuildingStorefrontIcon class="w-12 h-12 text-blue-600" />
          <div>
            <h1 class="text-2xl font-bold text-gray-900">{{ warehouse?.name }}</h1>
            <p class="text-gray-600">{{ warehouse?.location }}</p>
            <p class="text-sm text-gray-500 mt-1">{{ warehouse?.description }}</p>
          </div>
        </div>
        <div class="flex space-x-3">
          <button
            @click="downloadQR"
            class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            <QrCodeIcon class="w-4 h-4 mr-2" />
            QR İndir
          </button>
          <button
            @click="editWarehouse"
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
          >
            <PencilIcon class="w-4 h-4 mr-2" />
            Düzenle
          </button>
        </div>
      </div>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <CubeIcon class="w-8 h-8 text-blue-600" />
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">Toplam Eşya</p>
            <p class="text-2xl font-bold text-gray-900">{{ warehouse?.item_count || 0 }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <CheckCircleIcon class="w-8 h-8 text-green-600" />
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">Müsait</p>
            <p class="text-2xl font-bold text-gray-900">{{ warehouse?.available_count || 0 }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <ExclamationCircleIcon class="w-8 h-8 text-orange-600" />
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">Çıkarılmış</p>
            <p class="text-2xl font-bold text-gray-900">{{ warehouse?.checked_out_count || 0 }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <ChartBarIcon class="w-8 h-8 text-purple-600" />
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">Doluluk</p>
            <p class="text-2xl font-bold text-gray-900">{{ warehouse?.occupancy || 0 }}%</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Items Table -->
    <div class="bg-white shadow rounded-lg">
      <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-medium text-gray-900">Depo Eşyaları</h3>
      </div>
      <div class="p-6">
        <div v-if="loading" class="text-center py-8">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          <p class="mt-2 text-sm text-gray-500">Eşyalar yükleniyor...</p>
        </div>

        <div v-else-if="items.length === 0" class="text-center py-8">
          <CubeIcon class="mx-auto h-12 w-12 text-gray-400" />
          <h3 class="mt-2 text-sm font-medium text-gray-900">Bu depoda eşya yok</h3>
          <p class="mt-1 text-sm text-gray-500">Bu depoya henüz hiç eşya atanmamış.</p>
        </div>

        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Eşya
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Kategori
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Durum
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Son İşlem
                </th>
                <th class="relative px-6 py-3">
                  <span class="sr-only">İşlemler</span>
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr
                v-for="item in items"
                :key="item.id"
                class="hover:bg-gray-50"
              >
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div class="flex-shrink-0 h-10 w-10">
                      <div class="h-10 w-10 rounded-lg bg-gray-300 flex items-center justify-center">
                        <CubeIcon class="h-6 w-6 text-gray-600" />
                      </div>
                    </div>
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">{{ item.name }}</div>
                      <div class="text-sm text-gray-500">{{ item.serial_number }}</div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                    {{ item.category || 'Belirtilmemiş' }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                    :class="getStatusColor(item.status)"
                  >
                    {{ getStatusLabel(item.status) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDate(item.updated_at) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <router-link
                    :to="`/items/${item.id}`"
                    class="text-blue-600 hover:text-blue-900"
                  >
                    Görüntüle
                  </router-link>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { format } from 'date-fns'
import { tr } from 'date-fns/locale'
import {
  BuildingStorefrontIcon,
  CubeIcon,
  CheckCircleIcon,
  ExclamationCircleIcon,
  ChartBarIcon,
  QrCodeIcon,
  PencilIcon
} from '@heroicons/vue/24/outline'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const warehouse = ref({
  id: 1,
  name: 'Ana Depo',
  location: 'Zemin Kat, A Blok',
  description: 'Genel amaçlı ana depolama alanı',
  item_count: 15,
  available_count: 12,
  checked_out_count: 3,
  occupancy: 78
})

const items = ref([
  {
    id: 1,
    name: 'Laptop Dell XPS 13',
    serial_number: 'DL001234',
    category: 'Bilgisayar',
    status: 'available',
    updated_at: new Date(Date.now() - 2 * 60 * 60 * 1000)
  },
  {
    id: 2,
    name: 'Projeksiyon Makinesi',
    serial_number: 'PR005678',
    category: 'Sunum',
    status: 'checked_out',
    updated_at: new Date(Date.now() - 4 * 60 * 60 * 1000)
  }
])

const getStatusColor = (status) => {
  switch (status) {
    case 'available':
      return 'bg-green-100 text-green-800'
    case 'checked_out':
      return 'bg-orange-100 text-orange-800'
    case 'maintenance':
      return 'bg-yellow-100 text-yellow-800'
    case 'damaged':
      return 'bg-red-100 text-red-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

const getStatusLabel = (status) => {
  switch (status) {
    case 'available':
      return 'Müsait'
    case 'checked_out':
      return 'Çıkarılmış'
    case 'maintenance':
      return 'Bakımda'
    case 'damaged':
      return 'Hasarlı'
    default:
      return status
  }
}

const formatDate = (date) => {
  return format(new Date(date), 'dd.MM.yyyy HH:mm', { locale: tr })
}

const editWarehouse = () => {
  router.push(`/warehouses/${route.params.id}/edit`)
}

const downloadQR = () => {
  alert(`${warehouse.value.name} QR kodu indiriliyor...`)
}

onMounted(() => {
  // Load warehouse data from API
  // const warehouseId = route.params.id
})
</script>
