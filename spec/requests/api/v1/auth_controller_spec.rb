require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :request do
  let(:user) { create(:user) }
  let(:valid_credentials) { { email: user.email, password: 'password123' } }
  let(:invalid_credentials) { { email: user.email, password: 'wrong' } }

  describe 'POST /api/v1/auth/register' do
    let(:valid_params) do
      {
        user: {
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/api/v1/auth/register', params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['user']['data']['attributes']['email']).to eq('test@example.com')
      end
    end

    context 'with invalid parameters' do
      it 'returns error messages' do
        post '/api/v1/auth/register', params: { user: { email: 'invalid' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'POST /api/v1/auth/login' do
    context 'with valid credentials' do
      context 'without 2FA' do
        it 'returns authentication token' do
          post '/api/v1/auth/login', params: valid_credentials

          expect(response).to have_http_status(:ok)
          expect(response.headers['Authorization']).to be_present
          expect(json_response['token']).to be_present
        end
      end

      context 'with 2FA enabled' do
        let(:user) { create(:user, :with_2fa) }

        it 'requires 2FA code' do
          post '/api/v1/auth/login', params: valid_credentials

          expect(response).to have_http_status(:ok)
          expect(json_response['requires_2fa']).to be true
          expect(json_response['temp_token']).to be_present
        end
      end
    end

    context 'with invalid credentials' do
      it 'returns error message' do
        post '/api/v1/auth/login', params: invalid_credentials

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'POST /api/v1/auth/verify_two_factor' do
    let(:user) { create(:user, :with_2fa) }
    let(:totp) { ROTP::TOTP.new(user.two_factor_secret) }

    before do
      post '/api/v1/auth/login', params: valid_credentials
      @temp_token = json_response['temp_token']
    end

    context 'with valid code' do
      it 'returns authentication token' do
        post '/api/v1/auth/verify_two_factor', params: {
          temp_token: @temp_token,
          code: totp.now
        }

        expect(response).to have_http_status(:ok)
        expect(json_response['token']).to be_present
      end
    end

    context 'with invalid code' do
      it 'returns error message' do
        post '/api/v1/auth/verify_two_factor', params: {
          temp_token: @temp_token,
          code: '000000'
        }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/auth/logout' do
    context 'when authenticated' do
      before { sign_in user }

      it 'invalidates the token' do
        delete '/api/v1/auth/logout'

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Logged out successfully')
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized error' do
        delete '/api/v1/auth/logout'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end 