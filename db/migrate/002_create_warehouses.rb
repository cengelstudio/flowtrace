# frozen_string_literal: true

class CreateWarehouses < ActiveRecord::Migration[7.0]
  def change
    create_table :warehouses do |t|
      t.string :name, null: false
      t.text :location, null: false
      t.string :qr_code, null: false
      t.string :qr_code_url
      t.text :description
      t.decimal :capacity, precision: 10, scale: 2
      t.string :status, default: 'active' # active, inactive

      t.timestamps
    end

    add_index :warehouses, :name
    add_index :warehouses, :qr_code, unique: true
    add_index :warehouses, :status
  end
end
