class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      
      # Контент
      t.text :encrypted_content
      t.string :content_type, default: 'text'
      t.integer :size
      
      # Криптография
      t.string :encryption_key # Зашифрованный ключ для получателя
      t.string :nonce
      t.string :signature
      
      # Блокчейн и IPFS
      t.string :blockchain_hash
      t.string :ipfs_hash
      t.integer :blockchain_status, default: 0
      
      # Метаданные
      t.datetime :expires_at
      t.integer :status, default: 0
      t.boolean :is_read, default: false
      t.datetime :read_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :messages, :blockchain_hash, unique: true
    add_index :messages, :ipfs_hash, unique: true
    add_index :messages, :status
    add_index :messages, :blockchain_status
    add_index :messages, :expires_at
  end
end 