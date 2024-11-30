require 'rails_helper'

RSpec.describe Api::V1::ProfilesController, type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /api/v1/profile' do
    it 'returns user profile' do
      get '/api/v1/profile'

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['attributes']['email']).to eq(user.email)
    end

    context 'when not authenticated' do
      before { sign_out user }

      it 'returns unauthorized error' do
        get '/api/v1/profile'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/profile' do
    let(:valid_params) do
      {
        user: {
          username: 'newusername',
          settings: { theme: 'dark' }
        }
      }
    end

    context 'with valid parameters' do
      it 'updates user profile' do
        patch '/api/v1/profile', params: valid_params

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['attributes']['username']).to eq('newusername')
        expect(json_response['data']['attributes']['settings']).to include('theme' => 'dark')
      end
    end

    context 'with invalid parameters' do
      it 'returns error messages' do
        patch '/api/v1/profile', params: { user: { username: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'POST /api/v1/profile/enable_two_factor' do
    it 'enables 2FA and returns secret' do
      post '/api/v1/profile/enable_two_factor'

      expect(response).to have_http_status(:ok)
      expect(json_response['secret']).to be_present
      expect(json_response['qr_code']).to be_present
      expect(user.reload.two_factor_enabled).to be true
    end
  end

  describe 'POST /api/v1/profile/disable_two_factor' do
    let(:user) { create(:user, :with_2fa) }
    let(:totp) { ROTP::TOTP.new(user.two_factor_secret) }

    context 'with valid code' do
      it 'disables 2FA' do
        post '/api/v1/profile/disable_two_factor', params: { code: totp.now }

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('2FA disabled successfully')
        expect(user.reload.two_factor_enabled).to be false
      end
    end

    context 'with invalid code' do
      it 'returns error message' do
        post '/api/v1/profile/disable_two_factor', params: { code: '000000' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to be_present
        expect(user.reload.two_factor_enabled).to be true
      end
    end
  end

  describe 'POST /api/v1/profile/verify_two_factor' do
    let(:user) { create(:user, :with_2fa) }
    let(:totp) { ROTP::TOTP.new(user.two_factor_secret) }

    context 'with valid code' do
      it 'verifies 2FA code' do
        post '/api/v1/profile/verify_two_factor', params: { code: totp.now }

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('2FA verification successful')
      end
    end

    context 'with invalid code' do
      it 'returns error message' do
        post '/api/v1/profile/verify_two_factor', params: { code: '000000' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to be_present
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end 