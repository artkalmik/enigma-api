require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:user) { create(:user) }
  
  before { sign_in user }

  describe 'GET /api/v1/users' do
    before do
      create_list(:user, 3)
    end

    it 'returns list of users except current user' do
      get '/api/v1/users'

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
      expect(json_response['data'].map { |u| u['id'].to_i }).not_to include(user.id)
    end

    context 'when not authenticated' do
      before { sign_out user }

      it 'returns unauthorized error' do
        get '/api/v1/users'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/users/:id' do
    let(:other_user) { create(:user) }

    it 'returns user details' do
      get "/api/v1/users/#{other_user.id}"

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id'].to_i).to eq(other_user.id)
    end

    context 'when user does not exist' do
      it 'returns not found error' do
        get '/api/v1/users/0'

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /api/v1/users/search' do
    let!(:john) { create(:user, username: 'john_doe', email: 'john@example.com') }
    let!(:jane) { create(:user, username: 'jane_doe', email: 'jane@example.com') }
    
    context 'with matching query' do
      it 'returns matching users by username' do
        get '/api/v1/users/search', params: { q: 'john' }

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'][0]['attributes']['username']).to eq('john_doe')
      end

      it 'returns matching users by email' do
        get '/api/v1/users/search', params: { q: 'jane@' }

        expect(response).to have_http_status(:ok)
        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'][0]['attributes']['email']).to eq('jane@example.com')
      end
    end

    context 'with non-matching query' do
      it 'returns empty array' do
        get '/api/v1/users/search', params: { q: 'nonexistent' }

        expect(response).to have_http_status(:ok)
        expect(json_response['data']).to be_empty
      end
    end

    context 'with empty query' do
      it 'returns empty array' do
        get '/api/v1/users/search', params: { q: '' }

        expect(response).to have_http_status(:ok)
        expect(json_response['data']).to be_empty
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end 