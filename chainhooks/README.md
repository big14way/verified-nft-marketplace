# NFT Marketplace Chainhooks Integration

This directory contains the Hiro Chainhooks implementation for tracking users and fees in the NFT Marketplace smart contracts.

## Overview

The Chainhooks observer monitors on-chain events from the NFT Marketplace contracts and tracks:

- **Users**: Unique addresses interacting with the marketplace
- **Sales Volume**: Total STX traded through the marketplace
- **Platform Fees**: Fees collected by the platform (2.5% default)
- **Royalty Fees**: Creator royalties paid on secondary sales
- **Marketplace Activity**: Listings, sales, offers, and cancellations

## Features

✅ Real-time event monitoring
✅ User interaction tracking
✅ Fee and revenue analytics
✅ Reorg-resistant indexing
✅ JSON analytics export
✅ Extensible for database integration

## Installation

```bash
cd chainhooks
npm install
```

## Configuration

1. Copy the environment template:
```bash
cp .env.example .env
```

2. Update the `.env` file with your configuration:
```env
SERVER_HOST=0.0.0.0
SERVER_PORT=3000
SERVER_AUTH_TOKEN=your_secure_token
EXTERNAL_BASE_URL=http://localhost:3000

CHAINHOOK_NODE_URL=https://api.hiro.so
STACKS_NETWORK=testnet
STACKS_API_URL=https://api.testnet.hiro.so

NFT_MARKETPLACE_CONTRACT=ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-marketplace
START_BLOCK=0
```

## Usage

### Start the Observer

```bash
npm start
```

### Development Mode (with auto-reload)

```bash
npm run dev
```

## Monitored Events

The observer tracks these contract functions:

### NFT Marketplace (`nft-marketplace.clar`)

| Function | Description | Tracked Data |
|----------|-------------|--------------|
| `list-nft` | NFT listing created | Seller, token, price |
| `buy-nft` | NFT purchased | Buyer, seller, price, fees |
| `make-offer` | Offer made on NFT | Offerer, amount |
| `accept-offer` | Offer accepted | Seller, buyer, price, fees |
| `cancel-listing` | Listing cancelled | Seller, token |
| `cancel-offer` | Offer cancelled | Offerer |

### Fee Tracking

The observer captures fee data from:
- Platform fees (2.5% of sale price)
- Creator royalties (configurable per collection)
- Total volume transacted

## Analytics Output

Analytics are saved to `analytics-data.json`:

```json
{
  "users": ["ST1...", "ST2..."],
  "uniqueUsers": 42,
  "totalVolume": 1500000000,
  "totalSales": 156,
  "platformFees": 37500000,
  "royaltyFees": 75000000,
  "listings": [...],
  "sales": [...],
  "offers": [...],
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

## Dashboard Integration

For production deployments, integrate with analytics dashboards:

### Example: PostgreSQL Integration

```javascript
import pg from 'pg';

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL
});

async function saveToDatabase(analytics) {
  await pool.query(
    'INSERT INTO marketplace_stats (users, volume, sales, fees) VALUES ($1, $2, $3, $4)',
    [analytics.uniqueUsers, analytics.totalVolume, analytics.totalSales, analytics.platformFees]
  );
}
```

### Example: GraphQL API

```javascript
import { ApolloServer, gql } from 'apollo-server-express';

const typeDefs = gql`
  type Analytics {
    uniqueUsers: Int!
    totalVolume: Float!
    totalSales: Int!
    platformFees: Float!
  }

  type Query {
    marketplaceStats: Analytics!
  }
`;
```

## API Endpoints

When the observer is running, it exposes these webhooks:

- `POST /chainhook/listing` - Receives listing events
- `POST /chainhook/sale` - Receives sale events
- `POST /chainhook/offer` - Receives offer events
- `POST /chainhook/fees` - Receives fee collection events

## Production Deployment

### Using PM2

```bash
npm install -g pm2
pm2 start index.js --name nft-chainhooks
pm2 save
pm2 startup
```

### Using Docker

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

```bash
docker build -t nft-chainhooks .
docker run -d -p 3000:3000 --env-file .env nft-chainhooks
```

## Monitoring

View real-time logs:

```bash
# PM2
pm2 logs nft-chainhooks

# Docker
docker logs -f <container-id>
```

## Testing

The observer includes a test mode for development:

```bash
npm test
```

## Troubleshooting

### Observer Not Receiving Events

1. Check that contracts are deployed on the correct network
2. Verify `START_BLOCK` is before contract deployment
3. Ensure firewall allows incoming webhooks
4. Confirm `EXTERNAL_BASE_URL` is accessible from Chainhook node

### High Memory Usage

For production with many events, implement database persistence:

```javascript
// Instead of storing in memory
const analytics = {
  users: new Set(),
  // ...
};

// Use database queries
async function getUniqueUsers() {
  const result = await pool.query('SELECT COUNT(DISTINCT user_address) FROM interactions');
  return result.rows[0].count;
}
```

## Security

- Never commit `.env` file
- Use strong random tokens for `SERVER_AUTH_TOKEN`
- Implement rate limiting for production
- Validate all incoming webhook data
- Use HTTPS for `EXTERNAL_BASE_URL` in production

## License

MIT
