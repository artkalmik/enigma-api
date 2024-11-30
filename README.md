# Enigma - Secure Blockchain Messenger API

Enigma is a secure messaging platform that leverages blockchain technology and end-to-end encryption to provide a private and secure communication channel.

## Features

- End-to-end encryption using TweetNaCl.js
- Blockchain-based message verification using Ethereum/Polygon
- IPFS storage for encrypted messages
- Two-factor authentication
- Message expiration and revocation
- Real-time updates using WebSocket
- Comprehensive API documentation

## Technology Stack

- Ruby on Rails 7.1
- PostgreSQL (primary database)
- MongoDB (metadata storage)
- Redis (caching and background jobs)
- IPFS (distributed storage)
- Ethereum/Polygon (blockchain)
- WebSocket (real-time updates)
- Docker (containerization)

## Prerequisites

- Docker and Docker Compose
- Ruby 3.2.2
- Node.js and Yarn
- IPFS node
- Ethereum/Polygon node or provider

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/enigma.git
cd enigma
```

2. Copy the example environment file:
```bash
cp .env.example .env
```

3. Configure your environment variables in `.env`:
```
DATABASE_URL=postgresql://postgres:password@postgres:5432/enigma_development
REDIS_URL=redis://redis:6379/0
MONGODB_URL=mongodb://mongodb:27017/enigma
ETHEREUM_MAINNET_ENDPOINT=https://your-ethereum-node
ETHEREUM_TESTNET_ENDPOINT=https://your-testnet-node
IPFS_HOST=ipfs
IPFS_PORT=5001
```

4. Build and start the services:
```bash
docker-compose up --build
```

5. Create and migrate the database:
```bash
docker-compose exec api rails db:create db:migrate
```

## Development

The application will be available at:
- API: http://localhost:3000
- API Documentation: http://localhost:3000/api-docs
- Sidekiq Dashboard: http://localhost:3000/sidekiq

### Running Tests

```bash
docker-compose exec api bundle exec rspec
```

### Code Quality

```bash
docker-compose exec api bundle exec rubocop
docker-compose exec api bundle exec brakeman
```

### Generating API Documentation

```bash
docker-compose exec api rake rswag:specs:swaggerize
```

## API Documentation

The API documentation is available at `/api-docs` when the server is running. It is generated using RSwag and follows the OpenAPI 3.0 specification.

### Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```
Authorization: Bearer your-token-here
```

### WebSocket Connection

To connect to the WebSocket for real-time updates:

```javascript
const socket = new WebSocket('ws://localhost:3000/cable')
socket.send(JSON.stringify({
  command: 'subscribe',
  identifier: JSON.stringify({
    channel: 'MessagesChannel',
    token: 'your-jwt-token'
  })
}))
```

## Deployment

The application is configured for deployment to AWS ECS using GitHub Actions. Required secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

## Security

- All messages are encrypted end-to-end using TweetNaCl.js
- Private keys never leave the client
- Two-factor authentication available
- All API endpoints require authentication
- Regular security audits using Brakeman
- Comprehensive test coverage

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
