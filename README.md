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

## License

MIT License
