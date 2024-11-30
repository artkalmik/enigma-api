require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/users' do
    get 'List users' do
      tags 'Users'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'users retrieved' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
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
                      status: { type: :string },
                      created_at: { type: :string, format: 'date-time' },
                      updated_at: { type: :string, format: 'date-time' }
                    }
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
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Get user details' do
      tags 'Users'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'user retrieved' do
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
                    status: { type: :string },
                    created_at: { type: :string, format: 'date-time' },
                    updated_at: { type: :string, format: 'date-time' }
                  }
                }
              }
            }
          }

        let(:id) { '1' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end

      response '404', 'user not found' do
        schema '$ref' => '#/components/schemas/error'

        let(:id) { '0' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end
    end
  end

  path '/api/v1/users/search' do
    get 'Search users' do
      tags 'Users'
      security [bearer_auth: []]
      produces 'application/json'
      parameter name: :q, in: :query, type: :string, description: 'Search query'

      response '200', 'users found' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
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
                      status: { type: :string }
                    }
                  }
                }
              }
            }
          }

        let(:q) { 'john' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/error'

        let(:q) { 'john' }
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end
  end
end 