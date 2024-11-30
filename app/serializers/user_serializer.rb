class UserSerializer
  include FastJsonapi::ObjectSerializer
  
  attributes :id,
             :email,
             :username,
             :wallet_address,
             :public_key,
             :two_factor_enabled,
             :status,
             :created_at,
             :updated_at

  attribute :unread_messages_count do |object|
    object.unread_messages_count
  end

  attribute :settings do |object|
    object.settings
  end
end 