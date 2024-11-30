class CleanupExpiredMessagesJob < ApplicationJob
  queue_as :default

  def perform
    Message.expired.find_each do |message|
      begin
        # Отзываем сообщение в блокчейне
        if message.blockchain_hash.present?
          Web3Service.new.revoke_message(message.blockchain_hash)
        end

        # Удаляем из IPFS
        if message.ipfs_hash.present?
          IpfsService.new.unpin_hash(message.ipfs_hash)
        end

        # Обновляем статус в MongoDB
        MetadataService.new.update_message_status(message.id, 'expired')

        # Удаляем сообщение
        message.destroy
      rescue StandardError => e
        Rails.logger.error("Failed to cleanup message #{message.id}: #{e.message}")
        next
      end
    end
  end
end 