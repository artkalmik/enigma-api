require 'rails_helper'

RSpec.describe Web3Service do
  let(:service) { described_class.new }
  let(:sender_address) { '0x' + SecureRandom.hex(20) }
  let(:recipient_address) { '0x' + SecureRandom.hex(20) }
  let(:ipfs_hash) { SecureRandom.hex(32) }
  let(:message_hash) { SecureRandom.hex(32) }

  before do
    allow(ENV).to receive(:fetch).with('ETHEREUM_TESTNET_ENDPOINT').and_return('http://localhost:8545')
    allow(ENV).to receive(:fetch).with('ENIGMA_MESSAGING_CONTRACT_ADDRESS').and_return('0x' + SecureRandom.hex(20))
  end

  describe '#store_message' do
    let(:tx_hash) { '0x' + SecureRandom.hex(32) }
    let(:receipt) { { 'status' => '0x1' } }

    before do
      allow_any_instance_of(Eth::Contract).to receive_message_chain('functions.storeMessage.send_transaction')
        .and_return(tx_hash)
      allow_any_instance_of(Eth::Client).to receive(:eth_get_transaction_receipt)
        .with(tx_hash).and_return(receipt)
    end

    it 'stores message in blockchain' do
      result = service.store_message(sender_address, recipient_address, ipfs_hash)
      expect(result).to be_a(String)
      expect(result.length).to eq(64) # 32 bytes hex
    end

    context 'when transaction fails' do
      let(:receipt) { { 'status' => '0x0' } }

      it 'raises error' do
        expect {
          service.store_message(sender_address, recipient_address, ipfs_hash)
        }.to raise_error('Transaction failed')
      end
    end
  end

  describe '#revoke_message' do
    let(:tx_hash) { '0x' + SecureRandom.hex(32) }
    let(:receipt) { { 'status' => '0x1' } }

    before do
      allow_any_instance_of(Eth::Contract).to receive_message_chain('functions.revokeMessage.send_transaction')
        .and_return(tx_hash)
      allow_any_instance_of(Eth::Client).to receive(:eth_get_transaction_receipt)
        .with(tx_hash).and_return(receipt)
    end

    it 'revokes message in blockchain' do
      expect(service.revoke_message(message_hash)).to be true
    end

    context 'when transaction fails' do
      let(:receipt) { { 'status' => '0x0' } }

      it 'raises error' do
        expect {
          service.revoke_message(message_hash)
        }.to raise_error('Transaction failed')
      end
    end
  end

  describe '#verify_message' do
    before do
      allow_any_instance_of(Eth::Contract).to receive_message_chain('functions.verifyMessage.call')
        .with(message_hash).and_return(true)
    end

    it 'verifies message in blockchain' do
      expect(service.verify_message(message_hash)).to be true
    end
  end
end 