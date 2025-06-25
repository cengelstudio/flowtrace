<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Eşyalar</h1>
        <p class="text-gray-600">Sistemdeki tüm eşyaları görüntüleyin ve yönetin</p>
      </div>
      <div class="flex space-x-3">
        <button
          @click="exportItems"
          class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
        >
          <ArrowDownTrayIcon class="w-4 h-4 mr-2" />
          Dışa Aktar
        </button>
        <router-link
          to="/items/new"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
        >
          <PlusIcon class="w-4 h-4 mr-2" />
          Yeni Eşya
        </router-link>
      </div>
    </div>

    <!-- Filters -->
    <div class="bg-white p-4 rounded-lg shadow border border-gray-200">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <!-- Search -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Ara</label>
          <div class="relative">
            <input
              v-model="filters.search"
              type="text"
              placeholder="Eşya adı, seri no..."
              class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-blue-500 focus:border-blue-500"
              @input="debouncedSearch"
            />
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <MagnifyingGlassIcon class="h-5 w-5 text-gray-400" />
            </div>
          </div>
        </div>

        <!-- Status Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Durum</label>
          <select
            v-model="filters.status"
            class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            @change="applyFilters"
          >
            <option value="">Tüm Durumlar</option>
            <option value="available">Müsait</option>
            <option value="checked_out">Çıkarılmış</option>
            <option value="maintenance">Bakımda</option>
            <option value="damaged">Hasarlı</option>
          </select>
        </div>

        <!-- Category Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
          <select
            v-model="filters.category"
            class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            @change="applyFilters"
          >
            <option value="">Tüm Kategoriler</option>
            <option v-for="category in categories" :key="category" :value="category">
              {{ category }}
            </option>
          </select>
        </div>

        <!-- Warehouse Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Depo</label>
          <select
            v-model="filters.warehouse_id"
            class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            @change="applyFilters"
          >
            <option value="">Tüm Depolar</option>
            <option v-for="warehouse in warehouses" :key="warehouse.id" :value="warehouse.id">
              {{ warehouse.name }}
            </option>
          </select>
        </div>
      </div>
    </div>

    <!-- Items Table -->
    <div class="bg-white shadow overflow-hidden sm:rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <div v-if="loading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          <p class="mt-2 text-sm text-gray-500">Eşyalar yükleniyor...</p>
        </div>

        <div v-else-if="items.length === 0" class="text-center py-12">
          <CubeIcon class="mx-auto h-12 w-12 text-gray-400" />
          <h3 class="mt-2 text-sm font-medium text-gray-900">Eşya bulunamadı</h3>
          <p class="mt-1 text-sm text-gray-500">
            {{ filters.search || filters.status || filters.category ? 'Filtrelere uygun eşya yok.' : 'Henüz hiç eşya eklenmemiş.' }}
          </p>
          <div class="mt-6">
            <router-link
              to="/items/new"
              class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
            >
              <PlusIcon class="w-4 h-4 mr-2" />
              Yeni Eşya Ekle
            </router-link>
          </div>
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
                  Depo
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
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ item.warehouse?.name || 'Depo atanmamış' }}
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
                  <div class="flex items-center space-x-2">
                    <button
                      @click="viewItem(item)"
                      class="text-blue-600 hover:text-blue-900"
                      title="Görüntüle"
                    >
                      <EyeIcon class="w-4 h-4" />
                    </button>
                    <button
                      @click="editItem(item)"
                      class="text-indigo-600 hover:text-indigo-900"
                      title="Düzenle"
                    >
                      <PencilIcon class="w-4 h-4" />
                    </button>
                    <button
                      @click="downloadQR(item)"
                      class="text-green-600 hover:text-green-900"
                      title="QR İndir"
                    >
                      <QrCodeIcon class="w-4 h-4" />
                    </button>
                    <button
                      @click="deleteItem(item)"
                      class="text-red-600 hover:text-red-900"
                      title="Sil"
                    >
                      <TrashIcon class="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <div v-if="pagination && pagination.total_pages > 1" class="mt-6">
          <nav class="flex items-center justify-between">
            <div class="flex-1 flex justify-between sm:hidden">
              <button
                @click="goToPage(pagination.current_page - 1)"
                :disabled="!pagination.prev_page"
                class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Önceki
              </button>
              <button
                @click="goToPage(pagination.current_page + 1)"
                :disabled="!pagination.next_page"
                class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Sonraki
              </button>
            </div>
            <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
              <div>
                <p class="text-sm text-gray-700">
                  <span class="font-medium">{{ pagination.total_count }}</span> sonuçtan
                  <span class="font-medium">{{ ((pagination.current_page - 1) * pagination.per_page) + 1 }}</span> -
                  <span class="font-medium">{{ Math.min(pagination.current_page * pagination.per_page, pagination.total_count) }}</span>
                  arası gösteriliyor
                </p>
              </div>
              <div>
                <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px">
                  <button
                    @click="goToPage(pagination.current_page - 1)"
                    :disabled="!pagination.prev_page"
                    class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <ChevronLeftIcon class="h-5 w-5" />
                  </button>

                  <button
                    v-for="page in visiblePages"
                    :key="page"
                    @click="goToPage(page)"
                    class="relative inline-flex items-center px-4 py-2 border text-sm font-medium"
                    :class="page === pagination.current_page
                      ? 'z-10 bg-blue-50 border-blue-500 text-blue-600'
                      : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50'"
                  >
                    {{ page }}
                  </button>

                  <button
                    @click="goToPage(pagination.current_page + 1)"
                    :disabled="!pagination.next_page"
                    class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <ChevronRightIcon class="h-5 w-5" />
                  </button>
                </nav>
              </div>
            </div>
          </nav>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { debounce } from 'lodash'
import { format } from 'date-fns'
import { tr } from 'date-fns/locale'
import { useToast } from 'vue-toastification'
import itemsService from '../services/itemsService'
import {
  PlusIcon,
  MagnifyingGlassIcon,
  CubeIcon,
  EyeIcon,
  PencilIcon,
  QrCodeIcon,
  TrashIcon,
  ArrowDownTrayIcon,
  ChevronLeftIcon,
  ChevronRightIcon
} from '@heroicons/vue/24/outline'

const router = useRouter()
const toast = useToast()

// Reactive data
const loading = ref(false)
const items = ref([])
const categories = ref([])
const warehouses = ref([])
const pagination = ref(null)

const filters = reactive({
  search: '',
  status: '',
  category: '',
  warehouse_id: ''
})

// Computed
const visiblePages = computed(() => {
  if (!pagination.value) return []

  const current = pagination.value.current_page
  const total = pagination.value.total_pages
  const delta = 2

  const range = []
  const rangeWithDots = []

  for (let i = Math.max(2, current - delta); i <= Math.min(total - 1, current + delta); i++) {
    range.push(i)
  }

  if (current - delta > 2) {
    rangeWithDots.push(1, '...')
  } else {
    rangeWithDots.push(1)
  }

  rangeWithDots.push(...range)

  if (current + delta < total - 1) {
    rangeWithDots.push('...', total)
  } else {
    rangeWithDots.push(total)
  }

  return rangeWithDots.filter((page, index, array) => array.indexOf(page) === index)
})

// Methods
const loadItems = async (page = 1) => {
  loading.value = true
  try {
    const params = {
      page,
      per_page: 20,
      ...filters
    }

    // Remove empty filters
    Object.keys(params).forEach(key => {
      if (params[key] === '' || params[key] === null || params[key] === undefined) {
        delete params[key]
      }
    })

    const response = await itemsService.getItems(params)
    items.value = response.data.items
    pagination.value = response.data.pagination
  } catch (error) {
    console.error('Error loading items:', error)
    toast.error('Eşyalar yüklenirken hata oluştu')
  } finally {
    loading.value = false
  }
}

const loadCategories = async () => {
  try {
    const response = await itemsService.getCategories()
    categories.value = response.data
  } catch (error) {
    console.error('Error loading categories:', error)
  }
}

const loadWarehouses = async () => {
  try {
    // Warehouses service buraya eklenecek
    // const response = await warehousesService.getWarehouses()
    // warehouses.value = response.data.items
    warehouses.value = [
      { id: 1, name: 'Ana Depo' },
      { id: 2, name: 'IT Deposu' },
      { id: 3, name: 'Genel Depo' }
    ]
  } catch (error) {
    console.error('Error loading warehouses:', error)
  }
}

const applyFilters = () => {
  loadItems(1)
}

const debouncedSearch = debounce(() => {
  applyFilters()
}, 500)

const goToPage = (page) => {
  if (page >= 1 && page <= pagination.value.total_pages) {
    loadItems(page)
  }
}

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

const formatDate = (dateString) => {
  return format(new Date(dateString), 'dd.MM.yyyy HH:mm', { locale: tr })
}

const viewItem = (item) => {
  router.push(`/items/${item.id}`)
}

const editItem = (item) => {
  router.push(`/items/${item.id}/edit`)
}

const downloadQR = async (item) => {
  try {
    await itemsService.downloadItemQrPdf(item.id)
    toast.success('QR kod PDF\'i indirildi')
  } catch (error) {
    console.error('Error downloading QR:', error)
    toast.error('QR kod indirilemedi')
  }
}

const deleteItem = async (item) => {
  if (confirm(`"${item.name}" eşyasını silmek istediğinizden emin misiniz?`)) {
    try {
      await itemsService.deleteItem(item.id)
      toast.success('Eşya başarıyla silindi')
      loadItems()
    } catch (error) {
      console.error('Error deleting item:', error)
      toast.error('Eşya silinirken hata oluştu')
    }
  }
}

const exportItems = () => {
  // Export functionality
  toast.info('Dışa aktarma özelliği yakında eklenecek')
}

// Lifecycle
onMounted(async () => {
  await Promise.all([
    loadItems(),
    loadCategories(),
    loadWarehouses()
  ])
})
</script>
