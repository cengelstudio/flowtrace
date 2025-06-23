# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.string :serial_number
      t.string :category, null: false
      t.text :description
      t.string :qr_code, null: false
      t.string :qr_code_url
      t.string :status, default: 'stokta' # stokta, kullanımda, bakımda
      t.decimal :value, precision: 10, scale: 2
      t.string :brand
      t.string :model
      t.date :purchase_date
      t.date :warranty_date

      # References
      t.references :warehouse, null: false, foreign_key: true

      t.timestamps
    end

    add_index :items, :name
    add_index :items, :serial_number
    add_index :items, :category
    add_index :items, :qr_code, unique: true
    add_index :items, :status
    add_index :items, :brand
  end
end
