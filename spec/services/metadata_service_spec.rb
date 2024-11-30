require 'rails_helper'

RSpec.describe MetadataService do
  let(:service) { described_class.new }
  let(:message_data) do
    {
      sender_id: 1,
      recipient_id: 2,
      ipfs_hash: 'Qm' + SecureRandom.hex(20),
      blockchain_hash: '0x' + SecureRandom.hex(32),
      message_type: 'text',
      expires_at: 1.day.from_now
    }
  end

  let(:file_data) do
    {
      sender_id: 1,
      recipient_id: 2,
      ipfs_hash: 'Qm' + SecureRandom.hex(20),
      blockchain_hash: '0x' + SecureRandom.hex(32),
      filename: 'test.txt',
      content_type: 'text/plain',
      size: 1024
    }
  end

  let(:messages_collection) { double('messages') }
  let(:files_collection) { double('files') }

  before do
    allow(service).to receive(:instance_variable_get).with(:@messages).and_return(messages_collection)
    allow(service).to receive(:instance_variable_get).with(:@files).and_return(files_collection)
  end

  describe '#store_message_metadata' do
    it 'stores message metadata in MongoDB' do
      expect(messages_collection).to receive(:insert_one) do |doc|
        expect(doc[:sender_id]).to eq(message_data[:sender_id])
        expect(doc[:recipient_id]).to eq(message_data[:recipient_id])
        expect(doc[:ipfs_hash]).to eq(message_data[:ipfs_hash])
        expect(doc[:blockchain_hash]).to eq(message_data[:blockchain_hash])
        expect(doc[:status]).to eq('pending')
      end

      service.store_message_metadata(message_data)
    end
  end

  describe '#update_message_status' do
    let(:message_id) { BSON::ObjectId.new }
    let(:status) { 'delivered' }

    it 'updates message status in MongoDB' do
      expect(messages_collection).to receive(:update_one)
        .with(
          { _id: message_id },
          { '$set' => { status: status, updated_at: instance_of(Time) } }
        )

      service.update_message_status(message_id, status)
    end
  end

  describe '#store_file_metadata' do
    it 'stores file metadata in MongoDB' do
      expect(files_collection).to receive(:insert_one) do |doc|
        expect(doc[:sender_id]).to eq(file_data[:sender_id])
        expect(doc[:recipient_id]).to eq(file_data[:recipient_id])
        expect(doc[:ipfs_hash]).to eq(file_data[:ipfs_hash])
        expect(doc[:blockchain_hash]).to eq(file_data[:blockchain_hash])
        expect(doc[:filename]).to eq(file_data[:filename])
        expect(doc[:content_type]).to eq(file_data[:content_type])
        expect(doc[:size]).to eq(file_data[:size])
        expect(doc[:status]).to eq('pending')
      end

      service.store_file_metadata(file_data)
    end
  end

  describe '#get_user_messages' do
    let(:user_id) { 1 }
    let(:query) do
      {
        '$or' => [
          { sender_id: user_id },
          { recipient_id: user_id }
        ]
      }
    end

    it 'retrieves user messages from MongoDB' do
      expect(messages_collection).to receive(:find)
        .with(query)
        .and_return(double('cursor', sort: []))

      service.get_user_messages(user_id)
    end
  end

  describe '#get_user_files' do
    let(:user_id) { 1 }
    let(:query) do
      {
        '$or' => [
          { sender_id: user_id },
          { recipient_id: user_id }
        ]
      }
    end

    it 'retrieves user files from MongoDB' do
      expect(files_collection).to receive(:find)
        .with(query)
        .and_return(double('cursor', sort: []))

      service.get_user_files(user_id)
    end
  end

  describe '#delete_expired_messages' do
    let(:query) do
      {
        expires_at: { '$lt' => instance_of(Time) }
      }
    end

    it 'deletes expired messages from MongoDB' do
      expect(messages_collection).to receive(:delete_many).with(query)
      service.delete_expired_messages
    end
  end

  describe '#get_message_metadata' do
    let(:message_id) { BSON::ObjectId.new }

    it 'retrieves message metadata from MongoDB' do
      expect(messages_collection).to receive(:find)
        .with(_id: message_id)
        .and_return(double('cursor', first: nil))

      service.get_message_metadata(message_id)
    end
  end

  describe '#get_file_metadata' do
    let(:file_id) { BSON::ObjectId.new }

    it 'retrieves file metadata from MongoDB' do
      expect(files_collection).to receive(:find)
        .with(_id: file_id)
        .and_return(double('cursor', first: nil))

      service.get_file_metadata(file_id)
    end
  end
end 