import axios from 'axios'

// Base API service
class ApiService {
  constructor() {
    this.client = axios
  }

  // Generic CRUD methods
  async get(endpoint, params = {}) {
    try {
      const response = await this.client.get(endpoint, { params })
      return this.handleResponse(response)
    } catch (error) {
      throw this.handleError(error)
    }
  }

  async post(endpoint, data = {}) {
    try {
      const response = await this.client.post(endpoint, data)
      return this.handleResponse(response)
    } catch (error) {
      throw this.handleError(error)
    }
  }

  async put(endpoint, data = {}) {
    try {
      const response = await this.client.put(endpoint, data)
      return this.handleResponse(response)
    } catch (error) {
      throw this.handleError(error)
    }
  }

  async patch(endpoint, data = {}) {
    try {
      const response = await this.client.patch(endpoint, data)
      return this.handleResponse(response)
    } catch (error) {
      throw this.handleError(error)
    }
  }

  async delete(endpoint) {
    try {
      const response = await this.client.delete(endpoint)
      return this.handleResponse(response)
    } catch (error) {
      throw this.handleError(error)
    }
  }

  // Response handler
  handleResponse(response) {
    if (response.data.success) {
      return response.data
    } else {
      throw new Error(response.data.error || 'API hatası oluştu')
    }
  }

  // Error handler
  handleError(error) {
    if (error.response) {
      // Server responded with error status
      const message = error.response.data?.error || error.response.data?.message || 'Sunucu hatası'
      const serverError = new Error(message)
      serverError.status = error.response.status
      serverError.response = error.response
      return serverError
    } else if (error.request) {
      // Request was made but no response received
      return new Error('Sunucuya bağlanılamadı')
    } else {
      // Something else happened
      return error
    }
  }
}

// Create and export singleton instance
export default new ApiService()
