# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clean up existing data
puts "Cleaning up existing data..."
Transaction.delete_all
Item.delete_all
Warehouse.delete_all
User.delete_all

# Create admin user
puts "Creating admin user..."
admin = User.create!(
  name: "Admin Kullanıcı",
  email: "admin@flowtrace.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin"
)

# Create staff user
puts "Creating staff users..."
staff1 = User.create!(
  name: "Personel 1",
  email: "personel1@flowtrace.com",
  password: "password123",
  password_confirmation: "password123",
  role: "staff"
)

staff2 = User.create!(
  name: "Personel 2",
  email: "personel2@flowtrace.com",
  password: "password123",
  password_confirmation: "password123",
  role: "staff"
)

# Create warehouses
puts "Creating warehouses..."
warehouses = [
  {
    name: "Mavi Dolap",
    location: "2. Kat, Salon",
    description: "Ana depo alanı, kameralar ve aksesuarlar için",
    capacity: 50.0
  },
  {
    name: "Teknik Depo",
    location: "Bodrum Kat, Teknik Oda",
    description: "Teknik ekipmanlar ve yedek parçalar",
    capacity: 30.0
  },
  {
    name: "Arşiv Dolabı",
    location: "1. Kat, Ofis",
    description: "Eski ekipmanlar ve dokümantasyon",
    capacity: 20.0
  }
]

created_warehouses = warehouses.map do |warehouse_data|
  warehouse = Warehouse.create!(warehouse_data)
  puts "  Created warehouse: #{warehouse.name}"
  warehouse
end

# Create items
puts "Creating items..."
categories = ['Kamera', 'Lens', 'Aksesuar', 'Aydınlatma', 'Ses Ekipmanı', 'Bilgisayar']
brands = ['Canon', 'Nikon', 'Sony', 'Fujifilm', 'Panasonic', 'Apple', 'Dell']
statuses = ['stokta', 'kullanımda', 'bakımda']

items_data = [
  {
    name: "Canon EOS R5",
    serial_number: "CNR5-2023-001",
    category: "Kamera",
    brand: "Canon",
    model: "EOS R5",
    description: "45MP Full-frame Mirrorless Kamera",
    value: 89999.99,
    status: "stokta",
    purchase_date: 6.months.ago,
    warranty_date: 18.months.from_now
  },
  {
    name: "Fujifilm X-T4",
    serial_number: "FJX-T4-2023-002",
    category: "Kamera",
    brand: "Fujifilm",
    model: "X-T4",
    description: "26.1MP APS-C Mirrorless Kamera",
    value: 45999.99,
    status: "kullanımda",
    purchase_date: 4.months.ago,
    warranty_date: 16.months.from_now
  },
  {
    name: "Sony FX3",
    serial_number: "SNY-FX3-2023-003",
    category: "Kamera",
    brand: "Sony",
    model: "FX3",
    description: "Full-frame Cinema Kamera",
    value: 99999.99,
    status: "stokta",
    purchase_date: 3.months.ago,
    warranty_date: 15.months.from_now
  },
  {
    name: "Canon RF 24-70mm f/2.8L",
    serial_number: "CNL-2470-2023-004",
    category: "Lens",
    brand: "Canon",
    model: "RF 24-70mm f/2.8L",
    description: "Profesyonel zoom lens",
    value: 59999.99,
    status: "stokta",
    purchase_date: 5.months.ago,
    warranty_date: 17.months.from_now
  },
  {
    name: "Manfrotto Pro Tripod",
    serial_number: "MNF-PRO-2023-005",
    category: "Aksesuar",
    brand: "Manfrotto",
    model: "Pro Carbon",
    description: "Karbon fiber profesyonel tripod",
    value: 12999.99,
    status: "kullanımda",
    purchase_date: 2.months.ago,
    warranty_date: 14.months.from_now
  },
  {
    name: "Aputure 300D II",
    serial_number: "APT-300D-2023-006",
    category: "Aydınlatma",
    brand: "Aputure",
    model: "300D II",
    description: "300W LED Işık",
    value: 29999.99,
    status: "bakımda",
    purchase_date: 8.months.ago,
    warranty_date: 20.months.from_now
  },
  {
    name: "Rode Wireless GO II",
    serial_number: "ROD-WGO2-2023-007",
    category: "Ses Ekipmanı",
    brand: "Rode",
    model: "Wireless GO II",
    description: "Kablosuz mikrofon sistemi",
    value: 8999.99,
    status: "stokta",
    purchase_date: 1.month.ago,
    warranty_date: 13.months.from_now
  },
  {
    name: "MacBook Pro 16\"",
    serial_number: "APL-MBP16-2023-008",
    category: "Bilgisayar",
    brand: "Apple",
    model: "MacBook Pro 16\" M2",
    description: "Video editing için MacBook Pro",
    value: 79999.99,
    status: "kullanımda",
    purchase_date: 7.months.ago,
    warranty_date: 19.months.from_now
  }
]

created_items = items_data.map.with_index do |item_data, index|
  warehouse = created_warehouses[index % created_warehouses.length]
  item = Item.create!(item_data.merge(warehouse: warehouse))
  puts "  Created item: #{item.name} in #{warehouse.name}"
  item
end

# Create transactions
puts "Creating sample transactions..."

# Checkout some items
checkout_items = created_items.select { |item| item.status == 'kullanımda' }
checkout_items.each do |item|
  Transaction.create!(
    item: item,
    user: [staff1, staff2].sample,
    warehouse: item.warehouse,
    action_type: 'out',
    destination: ['Saha Çekimi', 'Stüdyo A', 'Dış Mekan Çekimi', 'Röportaj'].sample,
    checkout_reason: ['Proje çekimi', 'Müşteri sunumu', 'Test çekimi'].sample,
    return_date: rand(1..30).days.from_now,
    status: 'active',
    notes: 'Normal çıkış işlemi'
  )
end

# Create some completed transactions (returned items)
completed_items = created_items.select { |item| item.status == 'stokta' }.first(2)
completed_items.each do |item|
  # Checkout transaction
  checkout_transaction = Transaction.create!(
    item: item,
    user: [staff1, staff2].sample,
    warehouse: item.warehouse,
    action_type: 'out',
    destination: 'Tamamlanan Proje',
    checkout_reason: 'Proje çekimi',
    return_date: 3.days.ago,
    actual_return_date: 2.days.ago,
    status: 'completed',
    notes: 'Proje tamamlandı',
    created_at: 1.week.ago
  )

  # Checkin transaction
  Transaction.create!(
    item: item,
    user: admin,
    warehouse: item.warehouse,
    action_type: 'in',
    status: 'completed',
    checkin_notes: 'Ekipman temiz durumda geri teslim edildi',
    created_at: 2.days.ago
  )
end

# Create an overdue transaction
overdue_item = created_items.select { |item| item.status == 'stokta' }.last
if overdue_item
  Transaction.create!(
    item: overdue_item,
    user: staff1,
    warehouse: overdue_item.warehouse,
    action_type: 'out',
    destination: 'Geciken Proje',
    checkout_reason: 'Uzun süreli proje',
    return_date: 5.days.ago,
    status: 'overdue',
    notes: 'Bu eşya geç kaldı!',
    created_at: 2.weeks.ago
  )

  # Update item status
  overdue_item.update!(status: 'kullanımda')
end

puts "\n✅ Seed data created successfully!"
puts "👤 Admin user: admin@flowtrace.com / password123"
puts "👥 Staff users: personel1@flowtrace.com, personel2@flowtrace.com / password123"
puts "🏪 Warehouses: #{Warehouse.count}"
puts "📦 Items: #{Item.count}"
puts "📋 Transactions: #{Transaction.count}"
puts "\nYou can now start the application with: rails server"
