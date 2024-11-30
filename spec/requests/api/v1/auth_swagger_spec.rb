require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/api/v1/auth/register' do
    post 'Register a new user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              username: { type: :string, example: 'johndoe' },
              password: { type: :string, example: 'password123' },
              password_confirmation: { type: :string, example: 'password123' }
            },
            required: [:email, :username, :password, :password_confirmation]
          }
        }
      }

      response '201', 'user created' do
        schema type: :object,
          properties: {
            message: { type: :string },
            user: {
              type: :object,
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
                        public_key: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }

        let(:user) do
          {
            user: {
              email: 'test@example.com',
              username: 'testuser',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end
        run_test!
      end

      response '422', 'invalid request' do
        schema '$ref' => '#/components/schemas/error'

        let(:user) { { user: { email: 'invalid' } } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/login' do
    post 'Login user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: [:email, :password]
      }

      response '200', 'login successful' do
        schema type: :object,
          properties: {
            message: { type: :string },
            token: { type: :string },
            user: {
              type: :object,
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
                        username: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }

        let(:credentials) { { email: 'test@example.com', password: 'password123' } }
        run_test!
      end

      response '200', 'requires 2FA' do
        schema type: :object,
          properties: {
            message: { type: :string },
            requires_2fa: { type: :boolean },
            temp_token: { type: :string }
          }

        let(:credentials) { { email: 'test@example.com', password: 'password123' } }
        run_test!
      end

      response '401', 'invalid credentials' do
        schema '$ref' => '#/components/schemas/error'

        let(:credentials) { { email: 'test@example.com', password: 'wrong' } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/verify_two_factor' do
    post 'Verify 2FA code' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :verification, in: :body, schema: {
        type: :object,
        properties: {
          temp_token: { type: :string },
          code: { type: :string, example: '123456' }
        },
        required: [:temp_token, :code]
      }

      response '200', 'verification successful' do
        schema type: :object,
          properties: {
            message: { type: :string },
            token: { type: :string },
            user: {
              type: :object,
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
                        username: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }

        let(:verification) { { temp_token: 'temp_token', code: '123456' } }
        run_test!
      end

      response '401', 'invalid code' do
        schema '$ref' => '#/components/schemas/error'

        let(:verification) { { temp_token: 'temp_token', code: '000000' } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/logout' do
    delete 'Logout user' do
      tags 'Authentication'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'logout successful' do
        schema type: :object,
          properties: {
            message: { type: :string }
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
end 