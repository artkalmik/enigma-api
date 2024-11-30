class StoreMessageJob < ApplicationJob
  queue_as :default
  
  def perform(message_id)
    message = Message.find(message_id)
    return if message.blockchain_hash.present?

    # Сохраняем в IPFS
    ipfs_service = IpfsService.new
    ipfs_hash = ipfs_service.store_message(message.encrypted_content)
    ipfs_service.pin_hash(ipfs_hash)
    
    # Обновляем статус
    message.update!(
      ipfs_hash: ipfs_hash,
      blockchain_status: :storing
    )

    # Сохраняем в блокчейн
    web3_service = Web3Service.new
    blockchain_hash = web3_service.store_message(
      message.sender.wallet_address,
      message.recipient.wallet_address,
      ipfs_hash
    )

    # Обновляем статус
    message.update!(
      blockchain_hash: blockchain_hash,
      blockchain_status: :stored,
      status: :delivered
    )

    # Сохраняем метаданные в MongoDB
    metadata_service = MetadataService.new
    metadata_service.store_message_metadata(
      sender_id: message.sender_id,
      recipient_id: message.recipient_id,
      ipfs_hash: ipfs_hash,
      blockchain_hash: blockchain_hash,
      message_type: message.content_type,
      expires_at: message.expires_at
    )

  rescue StandardError => e
    message&.update(blockchain_status: :failed)
    Rails.logger.error("Failed to store message #{message_id}: #{e.message}")
    raise e
  end
end 