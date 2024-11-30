require 'swagger_helper'

RSpec.describe 'Profile API', type: :request do
  path '/api/v1/profile' do
    get 'Get user profile' do
      tags 'Profile'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'profile retrieved' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :string },
                type: { type: :string },
                attributes: {
                  type: :object,
                  properties: {
                    email: { type: :string },
                    username: { type: :string },
                    wallet_address: { type: :string },
                    public_key: { type: :string },
                    two_factor_enabled: { type: :boolean },
                    status: { type: :string },
                    unread_messages_count: { type: :integer },
                    settings: { type: :object },
                    created_at: { type: :string, format: 'date-time' },
                    updated_at: { type: :string, format: 'date-time' }
                  }
                }
              }
            }
          }

        let(:Authorization) { 'Bearer token' }
        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/error'

        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end

    patch 'Update user profile' do
      tags 'Profile'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              username: { type: :string },
              email: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string },
              settings: {
                type: :object,
                properties: {
                  theme: { type: :string },
                  notifications: { type: :boolean }
                }
              }
            }
          }
        }
      }

      response '200', 'profile updated' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :string },
                type: { type: :string },
                attributes: {
                  type: :object,
                  properties: {
                    email: { type: :string },
                    username: { type: :string },
                    settings: { type: :object }
                  }
                }
              }
            }
          }

        let(:Authorization) { 'Bearer token' }
        let(:user) do
          {
            user: {
              username: 'newusername',
              settings: { theme: 'dark' }
            }
          }
        end
        run_test!
      end

      response '422', 'invalid request' do
        schema '$ref' => '#/components/schemas/error'

        let(:Authorization) { 'Bearer token' }
        let(:user) { { user: { username: '' } } }
        run_test!
      end
    end
  end

  path '/api/v1/profile/enable_two_factor' do
    post 'Enable two-factor authentication' do
      tags 'Profile'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', '2FA enabled' do
        schema type: :object,
          properties: {
            message: { type: :string },
            secret: { type: :string },
            qr_code: { type: :string }
          }

        let(:Authorization) { 'Bearer token' }
        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/error'

        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/profile/disable_two_factor' do
    post 'Disable two-factor authentication' do
      tags 'Profile'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :verification, in: :body, schema: {
        type: :object,
        properties: {
          code: { type: :string, example: '123456' }
        },
        required: [:code]
      }

      response '200', '2FA disabled' do
        schema type: :object,
          properties: {
            message: { type: :string }
          }

        let(:Authorization) { 'Bearer token' }
        let(:verification) { { code: '123456' } }
        run_test!
      end

      response '422', 'invalid code' do
        schema '$ref' => '#/components/schemas/error'

        let(:Authorization) { 'Bearer token' }
        let(:verification) { { code: '000000' } }
        run_test!
      end
    end
  end

  path '/api/v1/profile/verify_two_factor' do
    post 'Verify two-factor authentication code' do
      tags 'Profile'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :verification, in: :body, schema: {
        type: :object,
        properties: {
          code: { type: :string, example: '123456' }
        },
        required: [:code]
      }

      response '200', 'verification successful' do
        schema type: :object,
          properties: {
            message: { type: :string }
          }

        let(:Authorization) { 'Bearer token' }
        let(:verification) { { code: '123456' } }
        run_test!
      end

      response '422', 'invalid code' do
        schema '$ref' => '#/components/schemas/error'

        let(:Authorization) { 'Bearer token' }
        let(:verification) { { code: '000000' } }
        run_test!
      end
    end
  end
end 