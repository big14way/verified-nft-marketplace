import { ChainhookEventObserver } from '@hirosystems/chainhook-client';
import { randomUUID } from 'crypto';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';

dotenv.config();

// Analytics storage (in production, use a database)
const analytics = {
  users: new Set(),
  totalVolume: 0,
  totalSales: 0,
  platformFees: 0,
  royaltyFees: 0,
  listings: [],
  sales: [],
  offers: []
};

// Save analytics to JSON file
function saveAnalytics() {
  const data = {
    ...analytics,
    users: Array.from(analytics.users),
    timestamp: new Date().toISOString(),
    uniqueUsers: analytics.users.size
  };

  fs.writeFileSync(
    path.join(process.cwd(), 'analytics-data.json'),
    JSON.stringify(data, null, 2)
  );

  console.log(`📊 Analytics saved - Users: ${data.uniqueUsers}, Volume: ${data.totalVolume} STX, Sales: ${data.totalSales}`);
}

// Create predicates for marketplace events
function createMarketplacePredicates() {
  const contractId = process.env.NFT_MARKETPLACE_CONTRACT;
  const startBlock = parseInt(process.env.START_BLOCK) || 0;

  return [
    {
      uuid: randomUUID(),
      name: 'nft-listing-events',
      version: 1,
      chain: 'stacks',
      networks: {
        testnet: {
          if_this: {
            scope: 'contract_call',
            contract_identifier: contractId,
            method: 'list-nft'
          },
          then_that: {
            http_post: {
              url: `${process.env.EXTERNAL_BASE_URL}/chainhook/listing`,
              authorization_header: `Bearer ${process.env.SERVER_AUTH_TOKEN}`
            }
          },
          start_block: startBlock
        }
      }
    },
    {
      uuid: randomUUID(),
      name: 'nft-sale-events',
      version: 1,
      chain: 'stacks',
      networks: {
        testnet: {
          if_this: {
            scope: 'contract_call',
            contract_identifier: contractId,
            method: 'buy-nft'
          },
          then_that: {
            http_post: {
              url: `${process.env.EXTERNAL_BASE_URL}/chainhook/sale`,
              authorization_header: `Bearer ${process.env.SERVER_AUTH_TOKEN}`
            }
          },
          start_block: startBlock
        }
      }
    },
    {
      uuid: randomUUID(),
      name: 'nft-offer-events',
      version: 1,
      chain: 'stacks',
      networks: {
        testnet: {
          if_this: {
            scope: 'contract_call',
            contract_identifier: contractId,
            method: 'make-offer'
          },
          then_that: {
            http_post: {
              url: `${process.env.EXTERNAL_BASE_URL}/chainhook/offer`,
              authorization_header: `Bearer ${process.env.SERVER_AUTH_TOKEN}`
            }
          },
          start_block: startBlock
        }
      }
    },
    {
      uuid: randomUUID(),
      name: 'platform-fees-events',
      version: 1,
      chain: 'stacks',
      networks: {
        testnet: {
          if_this: {
            scope: 'print_event',
            contract_identifier: contractId,
            contains: 'platform-fee'
          },
          then_that: {
            http_post: {
              url: `${process.env.EXTERNAL_BASE_URL}/chainhook/fees`,
              authorization_header: `Bearer ${process.env.SERVER_AUTH_TOKEN}`
            }
          },
          start_block: startBlock
        }
      }
    }
  ];
}

// Event handler
async function handleChainhookEvent(uuid, payload) {
  console.log(`\n🔔 Event received: ${uuid}`);

  try {
    // Process transactions in the payload
    if (payload.apply && payload.apply.length > 0) {
      for (const block of payload.apply) {
        console.log(`📦 Block ${block.block_identifier.index}`);

        for (const tx of block.transactions) {
          const sender = tx.metadata.sender;
          analytics.users.add(sender);

          // Process contract calls
          if (tx.metadata.kind?.data?.contract_call) {
            const contractCall = tx.metadata.kind.data.contract_call;
            const method = contractCall.function_name;

            console.log(`  → ${sender} called ${method}`);

            switch (method) {
              case 'list-nft':
                analytics.listings.push({
                  seller: sender,
                  timestamp: new Date().toISOString(),
                  txid: tx.transaction_identifier.hash
                });
                break;

              case 'buy-nft':
                // Extract price from transaction (this would need proper parsing)
                const saleData = {
                  buyer: sender,
                  timestamp: new Date().toISOString(),
                  txid: tx.transaction_identifier.hash
                };
                analytics.sales.push(saleData);
                analytics.totalSales++;
                break;

              case 'make-offer':
                analytics.offers.push({
                  offerer: sender,
                  timestamp: new Date().toISOString(),
                  txid: tx.transaction_identifier.hash
                });
                break;
            }
          }

          // Process print events for fees
          if (tx.metadata.receipt?.events) {
            for (const event of tx.metadata.receipt.events) {
              if (event.type === 'SmartContractEvent') {
                const eventData = event.data;
                // Track platform fees and royalties
                if (eventData.value && eventData.value.includes('platform-fee')) {
                  // Parse fee amount (implementation depends on event structure)
                  console.log(`  💰 Platform fee collected`);
                }
              }
            }
          }
        }
      }

      // Save analytics after processing
      saveAnalytics();
    }

  } catch (error) {
    console.error('Error processing event:', error);
  }
}

// Start the observer
async function start() {
  console.log('🚀 Starting NFT Marketplace Chainhook Observer\n');

  const serverOptions = {
    hostname: process.env.SERVER_HOST,
    port: parseInt(process.env.SERVER_PORT),
    auth_token: process.env.SERVER_AUTH_TOKEN,
    external_base_url: process.env.EXTERNAL_BASE_URL
  };

  const chainhookOptions = {
    base_url: process.env.CHAINHOOK_NODE_URL
  };

  const predicates = createMarketplacePredicates();

  console.log(`📡 Server: ${serverOptions.external_base_url}`);
  console.log(`🔗 Chainhook Node: ${chainhookOptions.base_url}`);
  console.log(`📋 Monitoring ${predicates.length} event types\n`);

  const observer = new ChainhookEventObserver(serverOptions, chainhookOptions);

  try {
    await observer.start(predicates, handleChainhookEvent);
    console.log('✅ Observer started successfully!\n');
    console.log('Waiting for events...\n');
  } catch (error) {
    console.error('❌ Failed to start observer:', error.message);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n\n👋 Shutting down gracefully...');
  saveAnalytics();
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n\n👋 Shutting down gracefully...');
  saveAnalytics();
  process.exit(0);
});

// Start the observer
start().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
