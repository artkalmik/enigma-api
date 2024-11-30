require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username) }
    it { should validate_length_of(:username).is_at_least(3).is_at_most(50) }
    it { should validate_uniqueness_of(:wallet_address).allow_nil }
    it { should validate_uniqueness_of(:public_key).allow_nil }
  end

  describe 'associations' do
    it { should have_many(:sent_messages) }
    it { should have_many(:received_messages) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(inactive: 0, active: 1, suspended: 2) }
  end

  describe 'callbacks' do
    describe '#generate_wallet_and_keys' do
      let(:user) { build(:user) }

      it 'generates wallet address and keys before create' do
        expect(user.wallet_address).to be_nil
        expect(user.public_key).to be_nil
        expect(user.encrypted_private_key).to be_nil

        user.save!

        expect(user.wallet_address).to be_present
        expect(user.public_key).to be_present
        expect(user.encrypted_private_key).to be_present
      end
    end
  end

  describe '#encrypt_private_key' do
    let(:user) { create(:user) }
    let(:private_key) { SecureRandom.hex(32) }

    it 'encrypts private key using password' do
      encrypted_key = user.encrypt_private_key(private_key)
      expect(encrypted_key).to be_present
      expect(encrypted_key).not_to eq(private_key)
    end
  end

  describe '#decrypt_private_key' do
    let(:user) { create(:user) }
    let(:private_key) { SecureRandom.hex(32) }

    it 'decrypts private key correctly' do
      encrypted_key = user.encrypt_private_key(private_key)
      user.update!(encrypted_private_key: encrypted_key)

      decrypted_key = user.decrypt_private_key
      expect(decrypted_key).to eq(private_key)
    end
  end

  describe '2FA methods' do
    let(:user) { create(:user) }

    describe '#enable_two_factor!' do
      it 'enables 2FA and generates secret' do
        expect {
          user.enable_two_factor!
        }.to change { user.two_factor_enabled }.from(false).to(true)
        .and change { user.two_factor_secret }.from(nil)
      end
    end

    describe '#disable_two_factor!' do
      let(:user) { create(:user, :with_2fa) }

      it 'disables 2FA and removes secret' do
        expect {
          user.disable_two_factor!
        }.to change { user.two_factor_enabled }.from(true).to(false)
        .and change { user.two_factor_secret }.to(nil)
      end
    end

    describe '#verify_two_factor' do
      context 'when 2FA is enabled' do
        let(:user) { create(:user, :with_2fa) }
        let(:totp) { ROTP::TOTP.new(user.two_factor_secret) }

        it 'verifies valid code' do
          expect(user.verify_two_factor(totp.now)).to be true
        end

        it 'rejects invalid code' do
          expect(user.verify_two_factor('invalid')).to be false
        end
      end

      context 'when 2FA is disabled' do
        let(:user) { create(:user) }

        it 'returns true regardless of code' do
          expect(user.verify_two_factor('any')).to be true
        end
      end
    end
  end

  describe 'message methods' do
    let(:user) { create(:user) }
    let!(:unread_messages) { create_list(:message, 3, recipient: user) }
    let!(:read_messages) { create_list(:message, 2, :read, recipient: user) }

    describe '#unread_messages_count' do
      it 'returns count of unread messages' do
        expect(user.unread_messages_count).to eq(3)
      end
    end

    describe '#mark_messages_as_read' do
      it 'marks messages as read' do
        expect {
          user.mark_messages_as_read(unread_messages)
        }.to change { user.unread_messages_count }.from(3).to(0)
      end
    end
  end
end 