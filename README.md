# Verified NFT Marketplace

A secure NFT marketplace that only lists verified collections with on-chain provenance tracking and safe trade execution.

## Clarity 4 Features Used

| Feature | Usage |
|---------|-------|
| `contract-hash?` | Verify NFT collections match approved code |
| `restrict-assets?` | Protect marketplace assets during NFT transfers |
| `stacks-block-time` | Manage listing expiry, auctions, and offers |
| `to-ascii?` | Generate provenance certificates and listing messages |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Collection Verification                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  contract-hash?() → Verify NFT contract code         │   │
│  │  verified-collections map → Store approved hashes     │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     NFT Marketplace                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Fixed-price listings & Auctions                      │   │
│  │  Offers on any verified NFT                          │   │
│  │  restrict-assets?() → Safe trade execution           │   │
│  │  Automatic royalty distribution                       │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Provenance Registry                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Track mint, transfer, and sale events                │   │
│  │  to-ascii?() → Generate provenance certificates       │   │
│  │  On-chain history for each NFT                        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Features

### For Collectors
- Only buy from verified, safe collections
- View complete provenance history
- Make offers on any NFT
- Participate in auctions
- Automatic royalty payment to creators

### For Creators
- Get your collection verified
- Set royalty percentage (up to 10%)
- Track sales and volume
- On-chain provenance certificates

### For the Marketplace
- 2.5% platform fee (configurable up to 5%)
- Collection verification system
- Provenance tracking for all NFTs

## Contract Functions

### Marketplace Admin

```clarity
;; Verify a collection
(verify-collection 
    (nft-contract principal)
    (name (string-ascii 64))
    (creator principal)
    (royalty-bps uint)
    (royalty-recipient principal))

;; Revoke verification
(revoke-collection (nft-contract principal))

;; Update platform fee
(set-platform-fee (new-fee-bps uint))
```

### Listing Functions

```clarity
;; Create fixed-price listing
(list-nft 
    (nft-contract principal)
    (token-id uint)
    (price uint)
    (duration uint)
    (nft <nft-trait>))

;; Buy listed NFT
(buy-nft (listing-id uint) (nft <nft-trait>))

;; Cancel listing
(cancel-listing (listing-id uint) (nft <nft-trait>))
```

### Auction Functions

```clarity
;; Create auction
(create-auction
    (nft-contract principal)
    (token-id uint)
    (starting-price uint)
    (duration uint)
    (nft <nft-trait>))

;; Place bid
(place-bid (listing-id uint) (bid-amount uint))

;; End auction
(end-auction (listing-id uint) (nft <nft-trait>))
```

### Offer Functions

```clarity
;; Make offer
(make-offer
    (nft-contract principal)
    (token-id uint)
    (amount uint)
    (duration uint))

;; Accept offer
(accept-offer (offer-id uint) (nft <nft-trait>))

;; Cancel offer
(cancel-offer (offer-id uint))
```

### Read-Only Helpers

```clarity
;; Check collection verification
(is-collection-verified (nft-contract principal))

;; Generate listing message
(generate-listing-message (listing-id uint))
;; Returns: "Listing #1 | Token #42 | Price: 100000000"

;; Generate provenance certificate
(generate-provenance-certificate (nft-contract) (token-id))
;; Returns: "CERTIFICATE | Collection Name #42 | Verified: 1702400000"

;; Calculate fees
(calculate-fees (nft-contract) (sale-price))
;; Returns: { platform-fee, royalty-fee, seller-amount }
```

## Fee Structure

| Fee Type | Default | Max | Recipient |
|----------|---------|-----|-----------|
| Platform | 2.5% | 5% | Marketplace |
| Royalty | Set by creator | 10% | Creator |

Example for 100 STX sale with 5% royalty:
- Platform fee: 2.5 STX
- Creator royalty: 5 STX
- Seller receives: 92.5 STX

## Provenance System

Every NFT gets a complete on-chain history:

```
PROVENANCE CERTIFICATE
======================
Collection: Verified Collection
Token: #42
Verified: 1702400000
Transfer Records: 5

Event History:
1. MINT    | To: ST1ABC... | Time: 1702400000
2. SALE    | ST1ABC → ST2DEF | 50 STX | Time: 1702450000
3. TRANSFER | ST2DEF → ST3GHI | Time: 1702500000
4. SALE    | ST3GHI → ST4JKL | 75 STX | Time: 1702600000
5. NOTE    | "Exhibited at NFT NYC 2024"
```

## Installation & Testing

```bash
cd verified-nft-marketplace
clarinet check
clarinet test
```

## Testnet Deployment

All contracts are deployed on Stacks Testnet with Clarity 4 support:

**Deployer Address:** `ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM`

| Contract | Address | Explorer |
|----------|---------|----------|
| nft-trait | ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait | [View on Explorer](https://explorer.hiro.so/txid/ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait?chain=testnet) |
| nft-marketplace | ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-marketplace | [View on Explorer](https://explorer.hiro.so/txid/ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-marketplace?chain=testnet) |
| provenance-registry | ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.provenance-registry | [View on Explorer](https://explorer.hiro.so/txid/ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.provenance-registry?chain=testnet) |
| verified-nft | ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.verified-nft | [View on Explorer](https://explorer.hiro.so/txid/ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.verified-nft?chain=testnet) |

**Deployment Details:**
- Network: Stacks Testnet
- Clarity Version: 4
- Epoch: 3.3
- Total Deployment Cost: 5.63 STX
- Transaction Nonces: 5151-5154

## Example: List and Sell an NFT

```typescript
// 1. Admin verifies collection
await verifyCollection({
    nftContract: 'ST...verified-nft',
    name: "Cool Cats",
    creator: creatorAddress,
    royaltyBps: 500, // 5%
    royaltyRecipient: creatorAddress
});

// 2. Seller lists NFT
const listingId = await listNft({
    nftContract: 'ST...verified-nft',
    tokenId: 42,
    price: 100000000, // 100 STX
    duration: 604800  // 1 week
});

// 3. Buyer purchases
await buyNft(listingId);

// 4. Provenance automatically updated
const cert = await generateProvenanceCertificate(nftContract, 42);
console.log(cert);
// "CERTIFICATE | Cool Cats #42 | Verified: 1702400000"
```

## Security Features

1. **Contract Verification**: Only approved collections via `contract-hash?`
2. **Asset Protection**: `restrict-assets?` on all NFT transfers
3. **Expiring Listings**: Prevent stale listings
4. **Automatic Refunds**: Failed auctions refund bidders
5. **Royalty Enforcement**: Creator royalties on every sale

## Collection Verification Process

1. Creator submits collection for review
2. Admin audits contract code for safety
3. Contract hash recorded via `contract-hash?`
4. Collection added to verified map
5. Users can now list NFTs from collection

If collection contract is upgraded (hash changes), verification is invalidated.

## Hiro Chainhooks Integration

This project includes a **Hiro Chainhooks** implementation for real-time monitoring of marketplace activity, user interactions, and fee collection.

### Features

✅ **Real-time Event Tracking**: Monitor NFT listings, sales, offers, and cancellations
✅ **User Analytics**: Track unique users and their marketplace interactions
✅ **Fee Monitoring**: Track platform fees (2.5%) and creator royalties
✅ **Volume Metrics**: Monitor total trading volume and sales count
✅ **Reorg-Resistant**: Chainhook's built-in protection against blockchain reorganizations

### Tracked Events

| Event | Contract Function | Data Collected |
|-------|------------------|----------------|
| NFT Listed | `list-nft` | Seller, token, price, timestamp |
| NFT Sold | `buy-nft` | Buyer, seller, price, fees |
| Offer Made | `make-offer` | Offerer, token, amount |
| Offer Accepted | `accept-offer` | Seller, buyer, price, fees |
| Listing Cancelled | `cancel-listing` | Seller, token |

### Analytics Output

The Chainhooks observer generates real-time analytics:

```json
{
  "uniqueUsers": 42,
  "totalVolume": 1500000000,
  "totalSales": 156,
  "platformFees": 37500000,
  "royaltyFees": 75000000,
  "listings": [...],
  "sales": [...],
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

### Quick Start

```bash
cd chainhooks
npm install
cp .env.example .env
# Edit .env with your configuration
npm start
```

For detailed setup and configuration, see [chainhooks/README.md](./chainhooks/README.md).

### Use Cases

- **Marketplace Analytics Dashboard**: Real-time metrics for traders and creators
- **Fee Revenue Tracking**: Monitor platform earnings and royalty distributions
- **User Engagement Metrics**: Understand marketplace adoption and activity
- **Compliance Monitoring**: Track all transactions for regulatory reporting
- **Trading Bots**: React to marketplace events for automated trading

## License

MIT License

## WalletConnect Integration

This project includes a fully-functional React dApp with WalletConnect v2 integration for seamless interaction with Stacks blockchain wallets.

### Features

- **🔗 Multi-Wallet Support**: Connect with any WalletConnect-compatible Stacks wallet
- **✍️ Transaction Signing**: Sign messages and submit transactions directly from the dApp
- **📝 Contract Interactions**: Call smart contract functions on Stacks testnet
- **🔐 Secure Connection**: End-to-end encrypted communication via WalletConnect relay
- **📱 QR Code Support**: Easy mobile wallet connection via QR code scanning

### Quick Start

#### Prerequisites

- Node.js (v16.x or higher)
- npm or yarn package manager
- A Stacks wallet (Xverse, Leather, or any WalletConnect-compatible wallet)

#### Installation

```bash
cd dapp
npm install
```

#### Running the dApp

```bash
npm start
```

The dApp will open in your browser at `http://localhost:3000`

#### Building for Production

```bash
npm run build
```

### WalletConnect Configuration

The dApp is pre-configured with:

- **Project ID**: 1eebe528ca0ce94a99ceaa2e915058d7
- **Network**: Stacks Testnet (Chain ID: `stacks:2147483648`)
- **Relay**: wss://relay.walletconnect.com
- **Supported Methods**:
  - `stacks_signMessage` - Sign arbitrary messages
  - `stacks_stxTransfer` - Transfer STX tokens
  - `stacks_contractCall` - Call smart contract functions
  - `stacks_contractDeploy` - Deploy new smart contracts

### Project Structure

```
dapp/
├── public/
│   └── index.html
├── src/
│   ├── components/
│   │   ├── WalletConnectButton.js      # Wallet connection UI
│   │   └── ContractInteraction.js       # Contract call interface
│   ├── contexts/
│   │   └── WalletConnectContext.js     # WalletConnect state management
│   ├── hooks/                            # Custom React hooks
│   ├── utils/                            # Utility functions
│   ├── config/
│   │   └── stacksConfig.js             # Network and contract configuration
│   ├── styles/                          # CSS styling
│   ├── App.js                           # Main application component
│   └── index.js                         # Application entry point
└── package.json
```

### Usage Guide

#### 1. Connect Your Wallet

Click the "Connect Wallet" button in the header. A QR code will appear - scan it with your mobile Stacks wallet or use the desktop wallet extension.

#### 2. Interact with Contracts

Once connected, you can:

- View your connected address
- Call read-only contract functions
- Submit contract call transactions
- Sign messages for authentication

#### 3. Disconnect

Click the "Disconnect" button to end the WalletConnect session.

### Customization

#### Updating Contract Configuration

Edit `src/config/stacksConfig.js` to point to your deployed contracts:

```javascript
export const CONTRACT_CONFIG = {
  contractName: 'your-contract-name',
  contractAddress: 'YOUR_CONTRACT_ADDRESS',
  network: 'testnet' // or 'mainnet'
};
```

#### Adding Custom Contract Functions

Modify `src/components/ContractInteraction.js` to add your contract-specific functions:

```javascript
const myCustomFunction = async () => {
  const result = await callContract(
    CONTRACT_CONFIG.contractAddress,
    CONTRACT_CONFIG.contractName,
    'your-function-name',
    [functionArgs]
  );
};
```

### Technical Details

#### WalletConnect v2 Implementation

The dApp uses the official WalletConnect v2 Sign Client with:

- **@walletconnect/sign-client**: Core WalletConnect functionality
- **@walletconnect/utils**: Helper utilities for encoding/decoding
- **@walletconnect/qrcode-modal**: QR code display for mobile connection
- **@stacks/connect**: Stacks-specific wallet integration
- **@stacks/transactions**: Transaction building and signing
- **@stacks/network**: Network configuration for testnet/mainnet

#### BigInt Serialization

The dApp includes BigInt serialization support for handling large numbers in Clarity contracts:

```javascript
BigInt.prototype.toJSON = function() { return this.toString(); };
```

### Supported Wallets

Any wallet supporting WalletConnect v2 and Stacks blockchain, including:

- **Xverse Wallet** (Recommended)
- **Leather Wallet** (formerly Hiro Wallet)
- **Boom Wallet**
- Any other WalletConnect-compatible Stacks wallet

### Troubleshooting

**Connection Issues:**
- Ensure your wallet app supports WalletConnect v2
- Check that you're on the correct network (testnet vs mainnet)
- Try refreshing the QR code or restarting the dApp

**Transaction Failures:**
- Verify you have sufficient STX for gas fees
- Confirm the contract address and function names are correct
- Check that post-conditions are properly configured

**Build Errors:**
- Clear node_modules and reinstall: `rm -rf node_modules && npm install`
- Ensure Node.js version is 16.x or higher
- Check for dependency conflicts in package.json

### Resources

- [WalletConnect Documentation](https://docs.walletconnect.com/)
- [Stacks.js Documentation](https://docs.stacks.co/build-apps/stacks.js)
- [Xverse WalletConnect Guide](https://docs.xverse.app/wallet-connect)
- [Stacks Blockchain Documentation](https://docs.stacks.co/)

### Security Considerations

- Never commit your private keys or seed phrases
- Always verify transaction details before signing
- Use testnet for development and testing
- Audit smart contracts before mainnet deployment
- Keep dependencies updated for security patches

### License

This dApp implementation is provided as-is for integration with the Stacks smart contracts in this repository.

