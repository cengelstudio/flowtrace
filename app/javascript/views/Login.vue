<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <!-- Logo ve başlık -->
      <div class="text-center">
        <svg class="mx-auto h-12 w-12 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
          <path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z"/>
        </svg>
        <h2 class="mt-6 text-3xl font-extrabold text-gray-900">
          FlowTrace'e Giriş Yapın
        </h2>
        <p class="mt-2 text-sm text-gray-600">
          Envanter yönetim sisteminize hoş geldiniz
        </p>
      </div>

      <!-- Login Formu -->
      <form class="mt-8 space-y-6" @submit.prevent="handleLogin">
        <div class="rounded-md shadow-sm -space-y-px">
          <div>
            <label for="email" class="sr-only">E-posta</label>
            <input
              id="email"
              v-model="form.email"
              name="email"
              type="email"
              required
              class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
              :class="{ 'border-red-300': errors.email }"
              placeholder="E-posta adresiniz"
            />
            <div v-if="errors.email" class="mt-1 text-sm text-red-600">
              {{ errors.email }}
            </div>
          </div>

          <div>
            <label for="password" class="sr-only">Şifre</label>
            <input
              id="password"
              v-model="form.password"
              name="password"
              type="password"
              required
              class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
              :class="{ 'border-red-300': errors.password }"
              placeholder="Şifreniz"
            />
            <div v-if="errors.password" class="mt-1 text-sm text-red-600">
              {{ errors.password }}
            </div>
          </div>
        </div>

        <div class="flex items-center justify-between">
          <div class="flex items-center">
            <input
              id="remember-me"
              v-model="form.remember"
              name="remember-me"
              type="checkbox"
              class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <label for="remember-me" class="ml-2 block text-sm text-gray-900">
              Beni hatırla
            </label>
          </div>

          <div class="text-sm">
            <a href="#" class="font-medium text-blue-600 hover:text-blue-500">
              Şifrenizi mi unuttunuz?
            </a>
          </div>
        </div>

        <div>
          <button
            type="submit"
            :disabled="loading"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
              <svg
                v-if="!loading"
                class="h-5 w-5 text-blue-500 group-hover:text-blue-400"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2z" clip-rule="evenodd"/>
              </svg>
              <svg
                v-else
                class="animate-spin h-5 w-5 text-blue-500"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            </span>
            {{ loading ? 'Giriş yapılıyor...' : 'Giriş Yap' }}
          </button>
        </div>

        <!-- Demo hesapları -->
        <div class="mt-6">
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-300" />
            </div>
            <div class="relative flex justify-center text-sm">
              <span class="px-2 bg-gray-50 text-gray-500">Demo Hesapları</span>
            </div>
          </div>

          <div class="mt-4 grid grid-cols-2 gap-3">
            <button
              @click="loginAsDemo('admin')"
              type="button"
              class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
            >
              👤 Admin
            </button>
            <button
              @click="loginAsDemo('user')"
              type="button"
              class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
            >
              👥 Kullanıcı
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)

const form = reactive({
  email: '',
  password: '',
  remember: false
})

const errors = reactive({
  email: '',
  password: ''
})

const clearErrors = () => {
  errors.email = ''
  errors.password = ''
}

const validateForm = () => {
  clearErrors()
  let isValid = true

  if (!form.email) {
    errors.email = 'E-posta adresi gerekli'
    isValid = false
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
    errors.email = 'Geçerli bir e-posta adresi girin'
    isValid = false
  }

  if (!form.password) {
    errors.password = 'Şifre gerekli'
    isValid = false
  } else if (form.password.length < 6) {
    errors.password = 'Şifre en az 6 karakter olmalı'
    isValid = false
  }

  return isValid
}

const handleLogin = async () => {
  if (!validateForm()) return

  loading.value = true

  try {
    const result = await authStore.login({
      email: form.email,
      password: form.password,
      remember: form.remember
    })

    if (result.success) {
      router.push('/dashboard')
    }
  } catch (error) {
    console.error('Login error:', error)
  } finally {
    loading.value = false
  }
}

const loginAsDemo = async (role) => {
  loading.value = true

  try {
    // Demo hesap bilgileri
    const demoCredentials = {
      admin: {
        email: 'admin@flowtrace.com',
        password: 'admin123'
      },
      user: {
        email: 'user@flowtrace.com',
        password: 'user123'
      }
    }

    const credentials = demoCredentials[role]
    if (credentials) {
      form.email = credentials.email
      form.password = credentials.password
      await handleLogin()
    }
  } catch (error) {
    console.error('Demo login error:', error)
  } finally {
    loading.value = false
  }
}
</script>
