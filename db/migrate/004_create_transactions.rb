# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string :action_type, null: false # 'in', 'out'
      t.text :destination # Nereye gidiyor (eğer çıkış ise)
      t.text :notes
      t.datetime :return_date # Ne zaman dönecek (eğer çıkış ise)
      t.datetime :actual_return_date # Gerçek dönüş tarihi
      t.string :status, default: 'active' # active, completed, overdue
      t.text :checkout_reason # Çıkış nedeni
      t.text :checkin_notes # Giriş notları

      # References
      t.references :item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :warehouse, null: true, foreign_key: true # Hangi depodan/depoya

      t.timestamps
    end

    add_index :transactions, :action_type
    add_index :transactions, :status
    add_index :transactions, :return_date
    add_index :transactions, :created_at
    add_index :transactions, [:item_id, :status]
    add_index :transactions, [:user_id, :created_at]
  end
end
