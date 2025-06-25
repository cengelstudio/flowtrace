import { defineStore } from 'pinia'
import axios from 'axios'
import { useToast } from 'vue-toastification'

const toast = useToast()

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    isAuthenticated: false,
    loading: false,
    token: localStorage.getItem('auth_token') || null
  }),

  getters: {
    currentUser: (state) => state.user,
    isAdmin: (state) => state.user?.admin || false,
    canManageItems: (state) => state.user?.can_manage_items || false
  },

  actions: {
    async login(credentials) {
      this.loading = true
      try {
        const response = await axios.post('/auth/login', credentials)

        if (response.data.success) {
          this.user = response.data.data.user
          this.token = response.data.data.token
          this.isAuthenticated = true

          // Token'ı localStorage'a kaydet
          if (this.token) {
            localStorage.setItem('auth_token', this.token)
            axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`
          }

          toast.success('Başarıyla giriş yapıldı!')
          return { success: true }
        } else {
          throw new Error(response.data.error || 'Giriş başarısız')
        }
      } catch (error) {
        const message = error.response?.data?.error || error.message || 'Giriş yapılırken hata oluştu'
        toast.error(message)
        return { success: false, error: message }
      } finally {
        this.loading = false
      }
    },

    async logout() {
      this.loading = true
      try {
        await axios.post('/auth/logout')
      } catch (error) {
        console.error('Logout error:', error)
      } finally {
        this.clearAuth()
        toast.success('Başarıyla çıkış yapıldı')
        this.loading = false
      }
    },

    async checkAuth() {
      if (!this.token) {
        this.clearAuth()
        return false
      }

      // Token'ı header'a ekle
      axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`

      try {
        const response = await axios.get('/auth/me')

        if (response.data.success) {
          this.user = response.data.data
          this.isAuthenticated = true
          return true
        } else {
          this.clearAuth()
          return false
        }
      } catch (error) {
        console.error('Auth check failed:', error)
        this.clearAuth()
        return false
      }
    },

    async register(userData) {
      this.loading = true
      try {
        const response = await axios.post('/auth/register', userData)

        if (response.data.success) {
          toast.success('Hesap başarıyla oluşturuldu! Giriş yapabilirsiniz.')
          return { success: true }
        } else {
          throw new Error(response.data.error || 'Kayıt başarısız')
        }
      } catch (error) {
        const message = error.response?.data?.error || error.message || 'Kayıt olurken hata oluştu'
        toast.error(message)
        return { success: false, error: message }
      } finally {
        this.loading = false
      }
    },

    clearAuth() {
      this.user = null
      this.token = null
      this.isAuthenticated = false
      localStorage.removeItem('auth_token')
      delete axios.defaults.headers.common['Authorization']
    },

    updateUser(userData) {
      if (this.user) {
        this.user = { ...this.user, ...userData }
      }
    }
  }
})
