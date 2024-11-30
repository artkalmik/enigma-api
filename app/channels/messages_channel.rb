class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    stop_all_streams
  end

  def self.broadcast_message(message)
    %i[sender recipient].each do |user_type|
      user = message.public_send(user_type)
      next unless user

      broadcast_to(
        user,
        type: 'message',
        action: 'created',
        data: MessageSerializer.new(
          message,
          include: [:sender, :recipient],
          params: { current_user: user }
        ).serializable_hash
      )
    end
  end

  def self.broadcast_status_update(message)
    %i[sender recipient].each do |user_type|
      user = message.public_send(user_type)
      next unless user

      broadcast_to(
        user,
        type: 'message',
        action: 'updated',
        data: {
          id: message.id,
          status: message.status,
          blockchain_status: message.blockchain_status,
          is_read: message.is_read,
          read_at: message.read_at
        }
      )
    end
  end
end 