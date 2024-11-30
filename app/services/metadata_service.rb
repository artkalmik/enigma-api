require 'mongo'

class MetadataService
  def initialize
    @client = Mongo::Client.new(['mongodb:27017'], database: 'enigma')
    @messages = @client[:messages]
    @files = @client[:files]
  end

  def store_message_metadata(message_data)
    @messages.insert_one({
      sender_id: message_data[:sender_id],
      recipient_id: message_data[:recipient_id],
      ipfs_hash: message_data[:ipfs_hash],
      blockchain_hash: message_data[:blockchain_hash],
      message_type: message_data[:message_type],
      created_at: Time.current,
      expires_at: message_data[:expires_at],
      status: 'pending'
    })
  end

  def update_message_status(message_id, status)
    @messages.update_one(
      { _id: message_id },
      { '$set' => { status: status, updated_at: Time.current } }
    )
  end

  def store_file_metadata(file_data)
    @files.insert_one({
      sender_id: file_data[:sender_id],
      recipient_id: file_data[:recipient_id],
      ipfs_hash: file_data[:ipfs_hash],
      blockchain_hash: file_data[:blockchain_hash],
      filename: file_data[:filename],
      content_type: file_data[:content_type],
      size: file_data[:size],
      created_at: Time.current,
      status: 'pending'
    })
  end

  def get_user_messages(user_id)
    @messages.find(
      '$or' => [
        { sender_id: user_id },
        { recipient_id: user_id }
      ]
    ).sort(created_at: -1)
  end

  def get_user_files(user_id)
    @files.find(
      '$or' => [
        { sender_id: user_id },
        { recipient_id: user_id }
      ]
    ).sort(created_at: -1)
  end

  def delete_expired_messages
    @messages.delete_many(
      expires_at: { '$lt' => Time.current }
    )
  end

  def get_message_metadata(message_id)
    @messages.find(_id: message_id).first
  end

  def get_file_metadata(file_id)
    @files.find(_id: file_id).first
  end
end 