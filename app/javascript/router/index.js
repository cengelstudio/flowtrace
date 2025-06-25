import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

// Views
import Dashboard from '../views/Dashboard.vue'
import Login from '../views/Login.vue'
import Warehouses from '../views/Warehouses.vue'
import WarehouseDetail from '../views/WarehouseDetail.vue'
import Items from '../views/Items.vue'
import ItemDetail from '../views/ItemDetail.vue'
import Transactions from '../views/Transactions.vue'
import QRScanner from '../views/QRScanner.vue'
import Reports from '../views/Reports.vue'
import Settings from '../views/Settings.vue'

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresAuth: false }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    meta: { requiresAuth: true }
  },
  {
    path: '/warehouses',
    name: 'Warehouses',
    component: Warehouses,
    meta: { requiresAuth: true }
  },
  {
    path: '/warehouses/:id',
    name: 'WarehouseDetail',
    component: WarehouseDetail,
    meta: { requiresAuth: true }
  },
  {
    path: '/items',
    name: 'Items',
    component: Items,
    meta: { requiresAuth: true }
  },
  {
    path: '/items/:id',
    name: 'ItemDetail',
    component: ItemDetail,
    meta: { requiresAuth: true }
  },
  {
    path: '/transactions',
    name: 'Transactions',
    component: Transactions,
    meta: { requiresAuth: true }
  },
  {
    path: '/scan',
    name: 'QRScanner',
    component: QRScanner,
    meta: { requiresAuth: true }
  },
  {
    path: '/reports',
    name: 'Reports',
    component: Reports,
    meta: { requiresAuth: true }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: Settings,
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory('/app'),
  routes
})

// Navigation guard
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  // Public routes (login sayfası gibi)
  if (to.meta.requiresAuth === false) {
    // Eğer kullanıcı zaten giriş yapmışsa dashboard'a yönlendir
    if (authStore.isAuthenticated) {
      next('/dashboard')
    } else {
      next()
    }
    return
  }

  // Protected routes
  if (to.meta.requiresAuth !== false) {
    // Auth durumunu kontrol et
    if (!authStore.isAuthenticated) {
      // Kullanıcı giriş yapmamışsa login sayfasına yönlendir
      next('/login')
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
