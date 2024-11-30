class User < ApplicationRecord
  # Подключаем Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Связи
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id'

  # Валидации
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :wallet_address, uniqueness: true, allow_nil: true
  validates :public_key, uniqueness: true, allow_nil: true

  # Перечисления
  enum status: {
    inactive: 0,
    active: 1,
    suspended: 2
  }

  # Колбэки
  before_create :generate_wallet_and_keys

  # Методы для работы с криптографией
  def generate_wallet_and_keys
    eth_account = Eth::Key.new
    self.wallet_address = eth_account.address
    self.public_key = eth_account.public_hex
    
    # Шифруем приватный ключ с помощью пароля пользователя
    encrypted_key = encrypt_private_key(eth_account.private_hex)
    self.encrypted_private_key = encrypted_key
  end

  def encrypt_private_key(private_key)
    # Используем пароль пользователя для шифрования приватного ключа
    cipher = RbNaCl::SimpleBox.from_secret_key(
      RbNaCl::Hash.sha256(encrypted_password.b)
    )
    Base64.strict_encode64(cipher.encrypt(private_key.b))
  end

  def decrypt_private_key
    return nil unless encrypted_private_key
    
    cipher = RbNaCl::SimpleBox.from_secret_key(
      RbNaCl::Hash.sha256(encrypted_password.b)
    )
    cipher.decrypt(Base64.strict_decode64(encrypted_private_key))
  end

  # 2FA методы
  def enable_two_factor!
    return if two_factor_enabled?
    
    self.two_factor_secret = ROTP::Base32.random
    self.two_factor_enabled = true
    save!
  end

  def disable_two_factor!
    self.two_factor_secret = nil
    self.two_factor_enabled = false
    save!
  end

  def verify_two_factor(code)
    return true unless two_factor_enabled?
    
    totp = ROTP::TOTP.new(two_factor_secret)
    totp.verify(code, drift_behind: 15)
  end

  # Методы для работы с сообщениями
  def unread_messages_count
    received_messages.where(is_read: false).count
  end

  def mark_messages_as_read(messages)
    messages.update_all(is_read: true, read_at: Time.current)
  end

  # Настройки пользователя
  def update_settings(new_settings)
    self.settings = settings.merge(new_settings)
    save!
  end
end 