class Message < ApplicationRecord
  # Связи
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  # Валидации
  validates :encrypted_content, presence: true
  validates :blockchain_hash, uniqueness: true, allow_nil: true
  validates :ipfs_hash, uniqueness: true, allow_nil: true

  # Перечисления
  enum status: {
    pending: 0,
    delivered: 1,
    read: 2,
    expired: 3,
    revoked: 4
  }

  enum blockchain_status: {
    not_stored: 0,
    storing: 1,
    stored: 2,
    failed: 3
  }

  # Скоупы
  scope :active, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :unread, -> { where(is_read: false) }
  scope :for_user, ->(user_id) {
    where('sender_id = ? OR recipient_id = ?', user_id, user_id)
  }

  # Колбэки
  before_create :set_metadata
  after_create :process_message
  before_destroy :cleanup_storage

  private

  def set_metadata
    self.size = encrypted_content.bytesize
    self.metadata = {
      created_timestamp: Time.current.to_i,
      sender_address: sender.wallet_address,
      recipient_address: recipient.wallet_address
    }
  end

  def process_message
    StoreMessageJob.perform_later(id)
  end

  def cleanup_storage
    # Удаляем данные из IPFS если они там есть
    IpfsService.new.unpin_hash(ipfs_hash) if ipfs_hash.present?
    
    # Отзываем сообщение в блокчейне если оно там есть
    if blockchain_hash.present?
      Web3Service.new.revoke_message(blockchain_hash)
    end
  end

  # Публичные методы
  def mark_as_read!
    return if is_read?
    
    update!(
      is_read: true,
      read_at: Time.current,
      status: :read
    )
  end

  def revoke!
    return if revoked?
    
    update!(status: :revoked)
    cleanup_storage
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def viewable_by?(user)
    user.id == sender_id || user.id == recipient_id
  end

  def self.cleanup_expired
    expired.find_each(&:destroy)
  end
end 