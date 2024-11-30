class MessageSerializer
  include FastJsonapi::ObjectSerializer
  
  attributes :id,
             :content_type,
             :size,
             :blockchain_hash,
             :ipfs_hash,
             :blockchain_status,
             :status,
             :is_read,
             :read_at,
             :expires_at,
             :created_at,
             :updated_at,
             :metadata

  belongs_to :sender, serializer: :user
  belongs_to :recipient, serializer: :user

  attribute :encrypted_content do |object, params|
    if params && params[:include_content]
      object.encrypted_content
    end
  end

  attribute :can_revoke do |object, params|
    if params && params[:current_user]
      object.sender_id == params[:current_user].id && !object.revoked?
    end
  end

  attribute :can_mark_as_read do |object, params|
    if params && params[:current_user]
      object.recipient_id == params[:current_user].id && !object.is_read?
    end
  end
end 