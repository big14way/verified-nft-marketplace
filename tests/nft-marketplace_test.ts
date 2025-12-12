import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.7.1/index.ts';
import { assertEquals, assertExists } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Can verify a collection",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const creator = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('nft-marketplace', 'verify-collection', [
                types.principal(`${deployer.address}.verified-nft`),
                types.ascii("Test Collection"),
                types.principal(creator.address),
                types.uint(500),
                types.principal(creator.address)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk().expectBool(true);
    }
});

Clarinet.test({
    name: "Only admin can verify collections",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const user = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('nft-marketplace', 'verify-collection', [
                types.principal(`${deployer.address}.verified-nft`),
                types.ascii("Fake Collection"),
                types.principal(user.address),
                types.uint(500),
                types.principal(user.address)
            ], user.address)
        ]);
        
        block.receipts[0].result.expectErr().expectUint(12001);
    }
});

Clarinet.test({
    name: "Royalty cannot exceed 10%",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const creator = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('nft-marketplace', 'verify-collection', [
                types.principal(`${deployer.address}.verified-nft`),
                types.ascii("High Royalty"),
                types.principal(creator.address),
                types.uint(1500),
                types.principal(creator.address)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectErr().expectUint(12004);
    }
});

Clarinet.test({
    name: "Get current time returns stacks-block-time",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const user = accounts.get('wallet_1')!;
        let currentTime = chain.callReadOnlyFn('nft-marketplace', 'get-current-time', [], user.address);
        assertExists(currentTime.result);
    }
});

Clarinet.test({
    name: "Can calculate fees correctly",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const creator = accounts.get('wallet_1')!;
        
        chain.mineBlock([
            Tx.contractCall('nft-marketplace', 'verify-collection', [
                types.principal(`${deployer.address}.verified-nft`),
                types.ascii("Test"),
                types.principal(creator.address),
                types.uint(500),
                types.principal(creator.address)
            ], deployer.address)
        ]);
        
        let fees = chain.callReadOnlyFn(
            'nft-marketplace',
            'calculate-fees',
            [types.principal(`${deployer.address}.verified-nft`), types.uint(100000000)],
            deployer.address
        );
        
        const feeData = fees.result.expectTuple();
        assertEquals(feeData['platform-fee'], types.uint(2500000));
        assertEquals(feeData['royalty-fee'], types.uint(5000000));
        assertEquals(feeData['seller-amount'], types.uint(92500000));
    }
});

Clarinet.test({
    name: "Can record mint in provenance",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const minter = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('provenance-registry', 'record-mint', [
                types.principal(`${deployer.address}.verified-nft`),
                types.uint(1),
                types.principal(minter.address)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk().expectUint(0);
    }
});

Clarinet.test({
    name: "Get collection stats from NFT contract",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const user = accounts.get('wallet_1')!;
        let stats = chain.callReadOnlyFn('verified-nft', 'get-collection-stats', [], user.address);
        const data = stats.result.expectTuple();
        assertEquals(data['max-supply'], types.uint(10000));
    }
});
