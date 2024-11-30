require 'swagger_helper'

RSpec.describe 'Messages API', type: :request do
  path '/api/v1/messages' do
    get 'List messages' do
      tags 'Messages'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'messages retrieved' do
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
                      content_type: { type: :string },
                      size: { type: :integer },
                      blockchain_hash: { type: :string },
                      ipfs_hash: { type: :string },
                      blockchain_status: { type: :string },
                      status: { type: :string },
                      is_read: { type: :boolean },
                      read_at: { type: :string, format: 'date-time', nullable: true },
                      expires_at: { type: :string, format: 'date-time', nullable: true },
                      created_at: { type: :string, format: 'date-time' },
                      updated_at: { type: :string, format: 'date-time' },
                      metadata: { type: :object }
                    }
                  },
                  relationships: {
                    type: :object,
                    properties: {
                      sender: {
                        type: :object,
                        properties: {
                          data: {
                            type: :object,
                            properties: {
                              id: { type: :string },
                              type: { type: :string }
                            }
                          }
                        }
                      },
                      recipient: {
                        type: :object,
                        properties: {
                          data: {
                            type: :object,
                            properties: {
                              id: { type: :string },
                              type: { type: :string }
                            }
                          }
                        }
                      }
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

    post 'Create message' do
      tags 'Messages'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :message, in: :body, schema: {
        type: :object,
        properties: {
          message: {
            type: :object,
            properties: {
              recipient_id: { type: :integer },
              content: { type: :string },
              content_type: { type: :string, enum: ['text', 'file'] },
              expires_at: { type: :string, format: 'date-time' },
              metadata: {
                type: :object,
                properties: {
                  importance: { type: :string },
                  tags: { type: :array, items: { type: :string } }
                }
              }
            },
            required: [:recipient_id, :content]
          }
        }
      }

      response '201', 'message created' do
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
                    content_type: { type: :string },
                    size: { type: :integer },
                    status: { type: :string },
                    created_at: { type: :string, format: 'date-time' }
                  }
                }
              }
            }
          }

        let(:Authorization) { 'Bearer token' }
        let(:message) do
          {
            message: {
              recipient_id: 1,
              content: 'Test message',
              content_type: 'text'
            }
          }
        end
        run_test!
      end

      response '422', 'invalid request' do
        schema '$ref' => '#/components/schemas/error'

        let(:Authorization) { 'Bearer token' }
        let(:message) { { message: { content: '' } } }
        run_test!
      end
    end
  end

  path '/api/v1/messages/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Get message' do
      tags 'Messages'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'message retrieved' do
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
                    content_type: { type: :string },
                    size: { type: :integer },
                    blockchain_hash: { type: :string },
                    ipfs_hash: { type: :string },
                    blockchain_status: { type: :string },
                    status: { type: :string },
                    is_read: { type: :boolean },
                    read_at: { type: :string, format: 'date-time', nullable: true },
                    expires_at: { type: :string, format: 'date-time', nullable: true },
                    created_at: { type: :string, format: 'date-time' },
                    updated_at: { type: :string, format: 'date-time' },
                    metadata: { type: :object }
                  }
                }
              }
            }
          }

        let(:id) { '1' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end

      response '404', 'message not found' do
        schema '$ref' => '#/components/schemas/error'

        let(:id) { '0' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end
    end

    delete 'Delete message' do
      tags 'Messages'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'message deleted' do
        let(:id) { '1' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end

      response '403', 'forbidden' do
        schema '$ref' => '#/components/schemas/error'

        let(:id) { '1' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end
    end
  end

  path '/api/v1/messages/{id}/revoke' do
    parameter name: :id, in: :path, type: :string

    post 'Revoke message' do
      tags 'Messages'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'message revoked' do
        schema type: :object,
          properties: {
            message: { type: :string }
          }

        let(:id) { '1' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end

      response '403', 'forbidden' do
        schema '$ref' => '#/components/schemas/error'

        let(:id) { '1' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end
    end
  end

  path '/api/v1/messages/{id}/mark_as_read' do
    parameter name: :id, in: :path, type: :string

    post 'Mark message as read' do
      tags 'Messages'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'message marked as read' do
        schema type: :object,
          properties: {
            message: { type: :string }
          }

        let(:id) { '1' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end

      response '403', 'forbidden' do
        schema '$ref' => '#/components/schemas/error'

        let(:id) { '1' }
        let(:Authorization) { 'Bearer token' }
        run_test!
      end
    end
  end

  path '/api/v1/messages/unread' do
    get 'List unread messages' do
      tags 'Messages'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'unread messages retrieved' do
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
                      content_type: { type: :string },
                      size: { type: :integer },
                      status: { type: :string },
                      created_at: { type: :string, format: 'date-time' }
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
end 