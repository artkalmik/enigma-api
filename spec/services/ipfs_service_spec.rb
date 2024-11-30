require 'rails_helper'

RSpec.describe IpfsService do
  let(:service) { described_class.new }
  let(:content) { 'Encrypted test content' }
  let(:ipfs_hash) { 'Qm' + SecureRandom.hex(20) }
  let(:ipfs_response) { double('response', hashcode: ipfs_hash) }

  describe '#store_message' do
    before do
      allow_any_instance_of(IPFS::Client).to receive(:add)
        .with(content).and_return(ipfs_response)
    end

    it 'stores content in IPFS' do
      result = service.store_message(content)
      expect(result).to eq(ipfs_hash)
    end
  end

  describe '#get_message' do
    before do
      allow_any_instance_of(IPFS::Client).to receive(:cat)
        .with(ipfs_hash).and_return(content)
    end

    it 'retrieves content from IPFS' do
      result = service.get_message(ipfs_hash)
      expect(result).to eq(content)
    end
  end

  describe '#store_file' do
    let(:file) { 'Encrypted file content' }

    before do
      allow_any_instance_of(IPFS::Client).to receive(:add)
        .with(file).and_return(ipfs_response)
    end

    it 'stores file in IPFS' do
      result = service.store_file(file)
      expect(result).to eq(ipfs_hash)
    end
  end

  describe '#get_file' do
    let(:file) { 'Encrypted file content' }

    before do
      allow_any_instance_of(IPFS::Client).to receive(:cat)
        .with(ipfs_hash).and_return(file)
    end

    it 'retrieves file from IPFS' do
      result = service.get_file(ipfs_hash)
      expect(result).to eq(file)
    end
  end

  describe '#pin_hash' do
    before do
      allow_any_instance_of(IPFS::Client).to receive_message_chain('pin.add')
        .with(ipfs_hash)
    end

    it 'pins hash in IPFS' do
      expect { service.pin_hash(ipfs_hash) }.not_to raise_error
    end
  end

  describe '#unpin_hash' do
    before do
      allow_any_instance_of(IPFS::Client).to receive_message_chain('pin.rm')
        .with(ipfs_hash)
    end

    it 'unpins hash from IPFS' do
      expect { service.unpin_hash(ipfs_hash) }.not_to raise_error
    end
  end
end 