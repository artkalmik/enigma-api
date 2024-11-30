require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :request do
  let(:user) { create(:user) }
  let(:recipient) { create(:user) }
  let(:message) { create(:message, sender: user, recipient: recipient) }

  before { sign_in user }

  describe 'GET /api/v1/messages' do
    before do
      create_list(:message, 3, sender: user)
      create_list(:message, 2, recipient: user)
    end

    it 'returns user messages' do
      get '/api/v1/messages'

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(5)
    end

    context 'when not authenticated' do
      before { sign_out user }

      it 'returns unauthorized error' do
        get '/api/v1/messages'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/messages/:id' do
    context 'when message belongs to user' do
      it 'returns the message' do
        get "/api/v1/messages/#{message.id}"

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['id'].to_i).to eq(message.id)
      end
    end

    context 'when message does not belong to user' do
      let(:other_message) { create(:message) }

      it 'returns forbidden error' do
        get "/api/v1/messages/#{other_message.id}"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/messages' do
    let(:valid_params) do
      {
        message: {
          recipient_id: recipient.id,
          content: 'Test message',
          content_type: 'text',
          metadata: { importance: 'high' }
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new message' do
        expect {
          post '/api/v1/messages', params: valid_params
        }.to change(Message, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['content_type']).to eq('text')
      end
    end

    context 'with invalid parameters' do
      it 'returns error messages' do
        post '/api/v1/messages', params: { message: { content: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'PATCH /api/v1/messages/:id' do
    let(:valid_params) do
      {
        message: {
          content: 'Updated message',
          metadata: { importance: 'low' }
        }
      }
    end

    context 'when message belongs to user' do
      it 'updates the message' do
        patch "/api/v1/messages/#{message.id}", params: valid_params

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['attributes']['metadata'])
          .to include('importance' => 'low')
      end
    end

    context 'when message does not belong to user' do
      let(:other_message) { create(:message) }

      it 'returns forbidden error' do
        patch "/api/v1/messages/#{other_message.id}", params: valid_params

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/v1/messages/:id' do
    context 'when message belongs to user' do
      it 'deletes the message' do
        delete "/api/v1/messages/#{message.id}"

        expect(response).to have_http_status(:ok)
        expect(Message.exists?(message.id)).to be false
      end
    end

    context 'when message does not belong to user' do
      let(:other_message) { create(:message) }

      it 'returns forbidden error' do
        delete "/api/v1/messages/#{other_message.id}"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/messages/:id/revoke' do
    context 'when message belongs to user' do
      it 'revokes the message' do
        post "/api/v1/messages/#{message.id}/revoke"

        expect(response).to have_http_status(:ok)
        expect(message.reload.revoked?).to be true
      end
    end

    context 'when message does not belong to user' do
      let(:other_message) { create(:message) }

      it 'returns forbidden error' do
        post "/api/v1/messages/#{other_message.id}/revoke"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/messages/:id/mark_as_read' do
    let(:received_message) { create(:message, recipient: user) }

    context 'when user is recipient' do
      it 'marks message as read' do
        post "/api/v1/messages/#{received_message.id}/mark_as_read"

        expect(response).to have_http_status(:ok)
        expect(received_message.reload.read?).to be true
      end
    end

    context 'when user is not recipient' do
      it 'returns forbidden error' do
        post "/api/v1/messages/#{message.id}/mark_as_read"

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /api/v1/messages/unread' do
    before do
      create_list(:message, 2, recipient: user)
      create(:message, :read, recipient: user)
    end

    it 'returns unread messages' do
      get '/api/v1/messages/unread'

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(2)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end 