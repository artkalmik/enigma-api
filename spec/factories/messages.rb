FactoryBot.define do
  factory :message do
    association :sender, factory: :user
    association :recipient, factory: :user
    encrypted_content { Base64.strict_encode64('Test message') }
    content_type { 'text' }
    status { :pending }
    blockchain_status { :not_stored }

    trait :with_blockchain do
      blockchain_hash { SecureRandom.hex(32) }
      blockchain_status { :stored }
      status { :delivered }
    end

    trait :with_ipfs do
      ipfs_hash { SecureRandom.hex(32) }
    end

    trait :expired do
      expires_at { 1.day.ago }
      status { :expired }
    end

    trait :read do
      is_read { true }
      read_at { Time.current }
      status { :read }
    end

    trait :revoked do
      status { :revoked }
    end

    trait :with_metadata do
      metadata do
        {
          device: 'web',
          client_version: '1.0.0',
          encryption_type: 'aes-256-gcm'
        }
      end
    end
  end
end 