import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import axios from 'axios'
import App from './App.vue'
import Toast from 'vue-toastification'
import 'vue-toastification/dist/index.css'

// Axios yapılandırması
axios.defaults.baseURL = '/api/v1'
axios.defaults.headers.common['Content-Type'] = 'application/json'
axios.defaults.headers.common['Accept'] = 'application/json'

// CSRF Token'ı Rails'den al
const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
if (csrfToken) {
  axios.defaults.headers.common['X-CSRF-Token'] = csrfToken
}

// HTTP interceptors
axios.interceptors.request.use(
  (config) => {
    // Loading state'i ekle
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

axios.interceptors.response.use(
  (response) => {
    return response
  },
  (error) => {
    if (error.response?.status === 401) {
      // Unauthorized - login sayfasına yönlendir
      router.push('/login')
    } else if (error.response?.status === 403) {
      // Forbidden - yetkisiz erişim
      console.error('Yetkisiz erişim')
    }
    return Promise.reject(error)
  }
)

// Vue uygulamasını oluştur
const app = createApp(App)

// Pinia state management
app.use(createPinia())

// Router
app.use(router)

// Toast notifications
app.use(Toast, {
  position: 'top-right',
  timeout: 5000,
  closeOnClick: true,
  pauseOnFocusLoss: true,
  pauseOnHover: true,
  draggable: true,
  draggablePercent: 0.6,
  showCloseButtonOnHover: false,
  hideProgressBar: false,
  closeButton: 'button',
  icon: true,
  rtl: false
})

// Global properties
app.config.globalProperties.$http = axios

// Mount the app
app.mount('#vue-app')

// Vue uygulaması hazır olduğunda event gönder
window.dispatchEvent(new CustomEvent('vue-app-ready'))
