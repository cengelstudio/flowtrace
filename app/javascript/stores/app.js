import { defineStore } from 'pinia'

export const useAppStore = defineStore('app', {
  state: () => ({
    isLoading: false,
    sidebarOpen: false,
    currentPage: 'Dashboard',
    notifications: [],
    theme: 'light'
  }),

  getters: {
    loadingState: (state) => state.isLoading,
    unreadNotifications: (state) => state.notifications.filter(n => !n.read),
    notificationCount: (state) => state.notifications.filter(n => !n.read).length
  },

  actions: {
    setLoading(loading) {
      this.isLoading = loading
    },

    toggleSidebar() {
      this.sidebarOpen = !this.sidebarOpen
    },

    setSidebarOpen(open) {
      this.sidebarOpen = open
    },

    setCurrentPage(page) {
      this.currentPage = page
    },

    addNotification(notification) {
      const id = Date.now().toString()
      this.notifications.unshift({
        id,
        read: false,
        timestamp: new Date(),
        ...notification
      })
    },

    markNotificationRead(id) {
      const notification = this.notifications.find(n => n.id === id)
      if (notification) {
        notification.read = true
      }
    },

    markAllNotificationsRead() {
      this.notifications.forEach(n => {
        n.read = true
      })
    },

    removeNotification(id) {
      const index = this.notifications.findIndex(n => n.id === id)
      if (index > -1) {
        this.notifications.splice(index, 1)
      }
    },

    clearNotifications() {
      this.notifications = []
    },

    setTheme(theme) {
      this.theme = theme
      localStorage.setItem('app_theme', theme)

      // HTML'e theme class'ı ekle
      if (theme === 'dark') {
        document.documentElement.classList.add('dark')
      } else {
        document.documentElement.classList.remove('dark')
      }
    },

    initializeTheme() {
      const savedTheme = localStorage.getItem('app_theme') || 'light'
      this.setTheme(savedTheme)
    }
  }
})
