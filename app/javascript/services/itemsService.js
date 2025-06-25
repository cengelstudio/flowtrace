import api from './api'

class ItemsService {
  async getItems(params = {}) {
    return await api.get('/items', params)
  }

  async getItem(id) {
    return await api.get(`/items/${id}`)
  }

  async createItem(itemData) {
    return await api.post('/items', { item: itemData })
  }

  async updateItem(id, itemData) {
    return await api.patch(`/items/${id}`, { item: itemData })
  }

  async deleteItem(id) {
    return await api.delete(`/items/${id}`)
  }

  async checkoutItem(id, checkoutData) {
    return await api.post(`/items/${id}/checkout`, { checkout: checkoutData })
  }

  async checkinItem(id, checkinData) {
    return await api.post(`/items/${id}/checkin`, { checkin: checkinData })
  }

  async getItemQrCode(id) {
    // QR kod için özel handling
    try {
      const response = await api.client.get(`/items/${id}/qr_code`, {
        responseType: 'blob'
      })
      return URL.createObjectURL(response.data)
    } catch (error) {
      throw api.handleError(error)
    }
  }

  async downloadItemQrPdf(id) {
    try {
      const response = await api.client.get(`/items/${id}/qr_code_pdf`, {
        responseType: 'blob'
      })

      // PDF'i indir
      const url = window.URL.createObjectURL(new Blob([response.data]))
      const link = document.createElement('a')
      link.href = url
      link.setAttribute('download', `item_${id}_qr.pdf`)
      document.body.appendChild(link)
      link.click()
      link.remove()
      window.URL.revokeObjectURL(url)

      return true
    } catch (error) {
      throw api.handleError(error)
    }
  }

  async getCategories() {
    return await api.get('/items/categories')
  }

  async getBrands() {
    return await api.get('/items/brands')
  }

  // Search items
  async searchItems(query, filters = {}) {
    const params = {
      search: query,
      ...filters
    }
    return await api.get('/items', params)
  }

  // Filter items by status
  async getItemsByStatus(status, additionalFilters = {}) {
    const params = {
      status,
      ...additionalFilters
    }
    return await api.get('/items', params)
  }

  // Filter items by warehouse
  async getItemsByWarehouse(warehouseId, additionalFilters = {}) {
    const params = {
      warehouse_id: warehouseId,
      ...additionalFilters
    }
    return await api.get('/items', params)
  }

  // Filter items by category
  async getItemsByCategory(category, additionalFilters = {}) {
    const params = {
      category,
      ...additionalFilters
    }
    return await api.get('/items', params)
  }

  // Filter items by brand
  async getItemsByBrand(brand, additionalFilters = {}) {
    const params = {
      brand,
      ...additionalFilters
    }
    return await api.get('/items', params)
  }
}

export default new ItemsService()
