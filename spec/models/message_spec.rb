require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'validations' do
    subject { build(:message) }

    it { should validate_presence_of(:encrypted_content) }
    it { should validate_uniqueness_of(:blockchain_hash).allow_nil }
    it { should validate_uniqueness_of(:ipfs_hash).allow_nil }
  end

  describe 'associations' do
    it { should belong_to(:sender).class_name('User') }
    it { should belong_to(:recipient).class_name('User') }
  end

  describe 'enums' do
    it {
      should define_enum_for(:status)
        .with_values(pending: 0, delivered: 1, read: 2, expired: 3, revoked: 4)
    }

    it {
      should define_enum_for(:blockchain_status)
        .with_values(not_stored: 0, storing: 1, stored: 2, failed: 3)
    }
  end

  describe 'scopes' do
    let!(:active_message) { create(:message) }
    let!(:expired_message) { create(:message, :expired) }
    let!(:unread_message) { create(:message) }
    let!(:read_message) { create(:message, :read) }
    let(:user) { create(:user) }
    let!(:sent_message) { create(:message, sender: user) }
    let!(:received_message) { create(:message, recipient: user) }

    describe '.active' do
      it 'returns only active messages' do
        expect(Message.active).to include(active_message)
        expect(Message.active).not_to include(expired_message)
      end
    end

    describe '.expired' do
      it 'returns only expired messages' do
        expect(Message.expired).to include(expired_message)
        expect(Message.expired).not_to include(active_message)
      end
    end

    describe '.unread' do
      it 'returns only unread messages' do
        expect(Message.unread).to include(unread_message)
        expect(Message.unread).not_to include(read_message)
      end
    end

    describe '.for_user' do
      it 'returns messages where user is sender or recipient' do
        messages = Message.for_user(user.id)
        expect(messages).to include(sent_message, received_message)
        expect(messages).not_to include(active_message)
      end
    end
  end

  describe 'callbacks' do
    describe '#set_metadata' do
      let(:message) { build(:message) }

      it 'sets metadata before create' do
        message.save!
        expect(message.size).to eq(message.encrypted_content.bytesize)
        expect(message.metadata).to include(
          'created_timestamp',
          'sender_address',
          'recipient_address'
        )
      end
    end

    describe '#process_message' do
      let(:message) { build(:message) }

      it 'enqueues StoreMessageJob after create' do
        expect {
          message.save!
        }.to have_enqueued_job(StoreMessageJob).with(message.id)
      end
    end
  end

  describe '#mark_as_read!' do
    let(:message) { create(:message) }

    it 'marks message as read' do
      expect {
        message.mark_as_read!
      }.to change { message.is_read }.from(false).to(true)
      .and change { message.status }.to('read')
      .and change { message.read_at }.from(nil)
    end

    it 'does nothing if message is already read' do
      message.mark_as_read!
      read_at = message.read_at

      expect {
        message.mark_as_read!
      }.not_to change { message.read_at }
    end
  end

  describe '#revoke!' do
    let(:message) { create(:message) }

    it 'revokes the message' do
      expect {
        message.revoke!
      }.to change { message.status }.to('revoked')
    end

    it 'does nothing if message is already revoked' do
      message.revoke!
      expect {
        message.revoke!
      }.not_to change { message.status }
    end
  end

  describe '#expired?' do
    it 'returns true for expired messages' do
      message = create(:message, :expired)
      expect(message).to be_expired
    end

    it 'returns false for active messages' do
      message = create(:message)
      expect(message).not_to be_expired
    end
  end

  describe '#viewable_by?' do
    let(:message) { create(:message) }
    let(:other_user) { create(:user) }

    it 'returns true for sender' do
      expect(message.viewable_by?(message.sender)).to be true
    end

    it 'returns true for recipient' do
      expect(message.viewable_by?(message.recipient)).to be true
    end

    it 'returns false for other users' do
      expect(message.viewable_by?(other_user)).to be false
    end
  end
end 