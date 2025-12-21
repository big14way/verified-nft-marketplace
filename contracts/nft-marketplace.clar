;; nft-marketplace.clar
;; Verified NFT marketplace with contract verification and safe trades
;; Uses Clarity 4 features: contract-hash?, restrict-assets?, stacks-block-time, to-ascii?

;; ========================================
;; Constants
;; ========================================

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u12001))
(define-constant ERR_LISTING_NOT_FOUND (err u12002))
(define-constant ERR_COLLECTION_NOT_VERIFIED (err u12003))
(define-constant ERR_INVALID_PRICE (err u12004))
(define-constant ERR_LISTING_EXPIRED (err u12005))
(define-constant ERR_ASSET_PROTECTION_FAILED (err u12007))
(define-constant ERR_ALREADY_LISTED (err u12008))
(define-constant ERR_OFFER_NOT_FOUND (err u12009))
(define-constant ERR_BULK_OPERATION_FAILED (err u12010))
(define-constant ERR_BUNDLE_NOT_FOUND (err u12011))
(define-constant ERR_INVALID_BUNDLE (err u12012))
(define-constant ERR_BUNDLE_LIMIT_EXCEEDED (err u12013))
(define-constant ERR_RENTAL_NOT_FOUND (err u12014))
(define-constant ERR_RENTAL_ACTIVE (err u12015))
(define-constant ERR_RENTAL_NOT_EXPIRED (err u12016))
(define-constant ERR_ALREADY_RENTED (err u12017))
(define-constant ERR_INVALID_ROYALTY (err u12018))
(define-constant ERR_ROYALTY_NOT_SET (err u12019))
(define-constant ERR_ROYALTY_ALREADY_SET (err u12020))
(define-constant ERR_INSUFFICIENT_AMOUNT (err u12021))
(define-constant ERR_FRACTION_NOT_FOUND (err u12022))
(define-constant ERR_FRACTION_EXISTS (err u12023))
(define-constant ERR_INVALID_SHARES (err u12024))
(define-constant ERR_INSUFFICIENT_SHARES (err u12025))
(define-constant ERR_FRACTION_LOCKED (err u12026))
(define-constant ERR_NOT_SHAREHOLDER (err u12027))

(define-constant LISTING_FIXED_PRICE u0)
(define-constant LISTING_AUCTION u1)
(define-constant MAX_BULK_LISTINGS u20)
(define-constant MAX_BUNDLE_SIZE u10)

;; ========================================
;; Data Variables
;; ========================================

(define-data-var listing-counter uint u0)
(define-data-var offer-counter uint u0)
(define-data-var platform-fee-bps uint u250)
(define-data-var total-volume uint u0)
(define-data-var total-sales uint u0)
(define-data-var bundle-counter uint u0)

;; ========================================
;; Data Maps
;; ========================================

(define-map verified-collections
    principal
    {
        name: (string-ascii 64),
        contract-hash: (buff 32),
        creator: principal,
        royalty-bps: uint,
        royalty-recipient: principal,
        verified-at: uint,
        total-volume: uint,
        total-sales: uint,
        active: bool
    }
)

(define-map listings
    uint
    {
        nft-contract: principal,
        token-id: uint,
        seller: principal,
        price: uint,
        listing-type: uint,
        auction-end: (optional uint),
        highest-bid: uint,
        highest-bidder: (optional principal),
        created-at: uint,
        expires-at: uint,
        active: bool
    }
)

(define-map nft-to-listing
    { nft-contract: principal, token-id: uint }
    uint
)

(define-map offers
    uint
    {
        nft-contract: principal,
        token-id: uint,
        offerer: principal,
        amount: uint,
        expires-at: uint,
        active: bool
    }
)

;; NFT bundle listings (multiple NFTs from same collection sold together)
(define-map bundles
    uint
    {
        nft-contract: principal,
        token-ids: (list 10 uint),
        seller: principal,
        total-price: uint,
        discount-bps: uint,      ;; Discount in basis points
        created-at: uint,
        expires-at: uint,
        active: bool
    }
)

;; ========================================
;; NFT Rental System Data Structures
;; ========================================

(define-data-var rental-counter uint u0)

;; Active NFT rentals
(define-map rentals
    uint
    {
        nft-contract: principal,
        token-id: uint,
        owner: principal,
        renter: principal,
        rental-price: uint,
        start-time: uint,
        end-time: uint,
        deposit-amount: uint,
        returned: bool,
        rental-active: bool
    }
)

;; Map NFT to rental ID
(define-map nft-to-rental
    { nft-contract: principal, token-id: uint }
    uint
)

;; Track rental history per owner
(define-map owner-rentals
    principal
    (list 50 uint)
)

;; Track rental history per renter
(define-map renter-rentals
    principal
    (list 50 uint)
)

;; ========================================
;; Creator Royalty System
;; ========================================

(define-data-var contract-principal principal tx-sender)
(define-data-var max-royalty-bps uint u1000) ;; Max 10% royalties
(define-data-var total-royalties-paid uint u0)

;; Royalty settings per collection
(define-map collection-royalties
    { nft-contract: principal }
    {
        creator: principal,
        royalty-bps: uint,  ;; Basis points (100 = 1%)
        total-earned: uint,
        set-at: uint,
        active: bool
    }
)

;; Track royalty payments
(define-map royalty-payments
    { payment-id: uint }
    {
        nft-contract: principal,
        token-id: uint,
        sale-price: uint,
        royalty-amount: uint,
        creator: principal,
        paid-at: uint,
        seller: principal,
        buyer: principal
    }
)

(define-data-var royalty-payment-counter uint u0)

;; Track creator's claimable royalties
(define-map creator-claimable-royalties
    { creator: principal, nft-contract: principal }
    {
        total-claimable: uint,
        total-claimed: uint,
        last-claim-at: uint
    }
)

;; Track sale history for royalty compliance
(define-map nft-sale-history
    { nft-contract: principal, token-id: uint }
    (list 20 uint)  ;; List of payment-ids
)

;; ========================================
;; Fractional Ownership System
;; ========================================

(define-data-var fraction-counter uint u0)

;; Fractionalized NFTs
(define-map fractional-nfts
    { nft-contract: principal, token-id: uint }
    {
        total-shares: uint,
        share-price: uint,
        shares-sold: uint,
        created-at: uint,
        creator: principal,
        active: bool,
        locked-until: uint,
        buyout-price: uint,
        buyout-enabled: bool
    }
)

;; Shareholder balances
(define-map shareholder-balances
    { nft-contract: principal, token-id: uint, shareholder: principal }
    {
        shares: uint,
        acquired-at: uint,
        total-spent: uint
    }
)

;; Track all shareholders for an NFT
(define-map nft-shareholders
    { nft-contract: principal, token-id: uint }
    (list 100 principal)
)

;; Dividend distributions
(define-map dividend-distributions
    { nft-contract: principal, token-id: uint, distribution-id: uint }
    {
        total-amount: uint,
        per-share-amount: uint,
        distributed-at: uint,
        source: (string-ascii 64)
    }
)

;; Track claimed dividends
(define-map dividend-claims
    { nft-contract: principal, token-id: uint, distribution-id: uint, shareholder: principal }
    {
        amount-claimed: uint,
        claimed-at: uint
    }
)

(define-data-var distribution-counter uint u0)

;; ========================================
;; NFT Trait Import
;; ========================================

(use-trait nft-trait .nft-trait.nft-trait)

;; ========================================
;; Read-Only Functions
;; ========================================

(define-read-only (get-current-time)
    stacks-block-time
)

(define-read-only (get-collection (nft-contract principal))
    (map-get? verified-collections nft-contract)
)

(define-read-only (is-collection-verified (nft-contract principal))
    (match (map-get? verified-collections nft-contract)
        collection (and 
            (get active collection)
            (match (contract-hash? nft-contract)
                current-hash (is-eq current-hash (get contract-hash collection))
                false
            )
        )
        false
    )
)

(define-read-only (get-listing (listing-id uint))
    (map-get? listings listing-id)
)

(define-read-only (get-offer (offer-id uint))
    (map-get? offers offer-id)
)

(define-read-only (is-listing-active (listing-id uint))
    (match (map-get? listings listing-id)
        listing (and (get active listing) (< stacks-block-time (get expires-at listing)))
        false
    )
)

(define-read-only (generate-listing-message (listing-id uint))
    (match (map-get? listings listing-id)
        listing (let
            (
                (id-str (unwrap-panic (to-ascii? listing-id)))
                (price-str (unwrap-panic (to-ascii? (get price listing))))
                (token-str (unwrap-panic (to-ascii? (get token-id listing))))
            )
            (concat (concat (concat "Listing #" id-str) (concat " | Token #" token-str)) (concat " | Price: " price-str))
        )
        "Listing not found"
    )
)

(define-read-only (generate-provenance-certificate (nft-contract principal) (token-id uint))
    (match (map-get? verified-collections nft-contract)
        collection (let
            (
                (token-str (unwrap-panic (to-ascii? token-id)))
                (verified-str (unwrap-panic (to-ascii? (get verified-at collection))))
            )
            (concat (concat (concat "CERTIFICATE | " (get name collection)) (concat " #" token-str)) (concat " | Verified: " verified-str))
        )
        "Unverified"
    )
)

(define-read-only (calculate-fees (nft-contract principal) (sale-price uint))
    (let ((platform-fee (/ (* sale-price (var-get platform-fee-bps)) u10000))
          (royalty-fee (match (map-get? verified-collections nft-contract)
              collection (/ (* sale-price (get royalty-bps collection)) u10000)
              u0
          )))
        { platform-fee: platform-fee, royalty-fee: royalty-fee, seller-amount: (- sale-price (+ platform-fee royalty-fee)) }
    )
)

(define-read-only (get-platform-stats)
    {
        total-listings: (var-get listing-counter),
        total-offers: (var-get offer-counter),
        total-volume: (var-get total-volume),
        total-sales: (var-get total-sales),
        platform-fee-bps: (var-get platform-fee-bps),
        total-bundles: (var-get bundle-counter)
    }
)

;; Get bundle details
(define-read-only (get-bundle (bundle-id uint))
    (map-get? bundles bundle-id)
)

;; Check if bundle is active
(define-read-only (is-bundle-active (bundle-id uint))
    (match (map-get? bundles bundle-id)
        bundle (and (get active bundle) (< stacks-block-time (get expires-at bundle)))
        false
    )
)

;; Calculate bundle savings
(define-read-only (calculate-bundle-savings (bundle-id uint) (individual-prices (list 10 uint)))
    (match (map-get? bundles bundle-id)
        bundle (let
            (
                (total-individual (fold + individual-prices u0))
                (bundle-price (get total-price bundle))
                (savings (if (> total-individual bundle-price) (- total-individual bundle-price) u0))
            )
            (ok { total-individual: total-individual, bundle-price: bundle-price, savings: savings, discount-bps: (get discount-bps bundle) })
        )
        (err ERR_BUNDLE_NOT_FOUND)
    )
)

;; ========================================
;; NFT Rental Read-Only Functions
;; ========================================

(define-read-only (get-rental (rental-id uint))
    (map-get? rentals rental-id)
)

(define-read-only (get-nft-rental (nft-contract principal) (token-id uint))
    (match (map-get? nft-to-rental { nft-contract: nft-contract, token-id: token-id })
        rental-id (get-rental rental-id)
        none
    )
)

(define-read-only (is-rental-active (rental-id uint))
    (match (get-rental rental-id)
        rental (and
            (get rental-active rental)
            (< stacks-block-time (get end-time rental))
            (not (get returned rental))
        )
        false
    )
)

(define-read-only (is-rental-expired (rental-id uint))
    (match (get-rental rental-id)
        rental (and
            (>= stacks-block-time (get end-time rental))
            (not (get returned rental))
        )
        false
    )
)

(define-read-only (get-owner-rentals (owner principal))
    (default-to (list) (map-get? owner-rentals owner))
)

(define-read-only (get-renter-rentals (renter principal))
    (default-to (list) (map-get? renter-rentals renter))
)

(define-read-only (calculate-rental-earnings (rental-id uint))
    (match (get-rental rental-id)
        rental (ok {
            rental-price: (get rental-price rental),
            deposit: (get deposit-amount rental),
            total-earnings: (+ (get rental-price rental) (get deposit-amount rental))
        })
        ERR_RENTAL_NOT_FOUND
    )
)

;; ========================================
;; Admin Functions
;; ========================================

(define-public (verify-collection (nft-contract principal) (name (string-ascii 64)) (creator principal) (royalty-bps uint) (royalty-recipient principal))
    (let ((contract-hash (unwrap! (contract-hash? nft-contract) ERR_COLLECTION_NOT_VERIFIED))
          (current-time stacks-block-time))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (<= royalty-bps u1000) ERR_INVALID_PRICE)
        
        (map-set verified-collections nft-contract {
            name: name, contract-hash: contract-hash, creator: creator,
            royalty-bps: royalty-bps, royalty-recipient: royalty-recipient,
            verified-at: current-time, total-volume: u0, total-sales: u0, active: true
        })
        (ok true)
    )
)

(define-public (revoke-collection (nft-contract principal))
    (let ((collection (unwrap! (map-get? verified-collections nft-contract) ERR_COLLECTION_NOT_VERIFIED)))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (map-set verified-collections nft-contract (merge collection { active: false }))
        (ok true)
    )
)

(define-public (set-platform-fee (new-fee-bps uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (<= new-fee-bps u500) ERR_INVALID_PRICE)
        (var-set platform-fee-bps new-fee-bps)
        (ok true)
    )
)

;; ========================================
;; Listing Functions
;; ========================================

(define-public (list-nft (nft-contract principal) (token-id uint) (price uint) (duration uint) (nft <nft-trait>))
    (let ((caller tx-sender) (current-time stacks-block-time) (listing-id (+ (var-get listing-counter) u1)))
        (begin
            (asserts! (is-collection-verified nft-contract) ERR_COLLECTION_NOT_VERIFIED)
            (asserts! (> price u0) ERR_INVALID_PRICE)
            (asserts! (is-none (map-get? nft-to-listing { nft-contract: nft-contract, token-id: token-id })) ERR_ALREADY_LISTED)
            (asserts! (is-some (restrict-assets? u1 u0)) ERR_ASSET_PROTECTION_FAILED)
            (try! (contract-call? nft transfer token-id caller (as-contract tx-sender)))
            (map-set listings listing-id {
                nft-contract: nft-contract, token-id: token-id, seller: caller, price: price,
                listing-type: LISTING_FIXED_PRICE, auction-end: none, highest-bid: u0,
                highest-bidder: none, created-at: current-time, expires-at: (+ current-time duration), active: true
            })
            (map-set nft-to-listing { nft-contract: nft-contract, token-id: token-id } listing-id)
            (var-set listing-counter listing-id)
            (print (generate-listing-message listing-id))
            (ok listing-id)
        )
    )
)

(define-public (buy-nft (listing-id uint) (nft <nft-trait>))
    (let ((caller tx-sender)
          (listing (unwrap! (map-get? listings listing-id) ERR_LISTING_NOT_FOUND))
          (fees (calculate-fees (get nft-contract listing) (get price listing))))
        (asserts! (get active listing) ERR_LISTING_NOT_FOUND)
        (asserts! (< stacks-block-time (get expires-at listing)) ERR_LISTING_EXPIRED)
        
        (try! (stx-transfer? (get price listing) caller (as-contract tx-sender)))

        (asserts! (is-some (restrict-assets? u1 u0)) ERR_ASSET_PROTECTION_FAILED)
        (try! (as-contract (contract-call? nft transfer (get token-id listing) tx-sender caller)))
        (try! (as-contract (stx-transfer? (get seller-amount fees) tx-sender (get seller listing))))
        (try! (as-contract (stx-transfer? (get platform-fee fees) tx-sender CONTRACT_OWNER)))

        (if (> (get royalty-fee fees) u0)
            (match (map-get? verified-collections (get nft-contract listing))
                collection (try! (as-contract (stx-transfer? (get royalty-fee fees) tx-sender (get royalty-recipient collection))))
                true
            )
            true
        )

        (map-set listings listing-id (merge listing { active: false }))
        (map-delete nft-to-listing { nft-contract: (get nft-contract listing), token-id: (get token-id listing) })
        (var-set total-volume (+ (var-get total-volume) (get price listing)))
        (var-set total-sales (+ (var-get total-sales) u1))
        (ok true)
    )
)

(define-public (cancel-listing (listing-id uint) (nft <nft-trait>))
    (let ((caller tx-sender)
          (listing (unwrap! (map-get? listings listing-id) ERR_LISTING_NOT_FOUND)))
        (asserts! (is-eq caller (get seller listing)) ERR_NOT_AUTHORIZED)
        (asserts! (get active listing) ERR_LISTING_NOT_FOUND)

        (try! (as-contract (contract-call? nft transfer (get token-id listing) tx-sender caller)))
        (map-set listings listing-id (merge listing { active: false }))
        (map-delete nft-to-listing { nft-contract: (get nft-contract listing), token-id: (get token-id listing) })
        (ok true)
    )
)

;; ========================================
;; Bulk Listing Functions
;; ========================================

;; Helper function for bulk listing - lists a single NFT as part of a batch operation
;; This can be called multiple times in sequence for bulk listing operations
(define-public (list-nft-batch-item
    (nft-contract principal)
    (token-id uint)
    (price uint)
    (duration uint)
    (nft <nft-trait>))
    (let ((caller tx-sender) (current-time stacks-block-time) (listing-id (+ (var-get listing-counter) u1)))
        (begin
            (asserts! (is-collection-verified nft-contract) ERR_COLLECTION_NOT_VERIFIED)
            (asserts! (> price u0) ERR_INVALID_PRICE)
            (asserts! (is-none (map-get? nft-to-listing { nft-contract: nft-contract, token-id: token-id })) ERR_ALREADY_LISTED)
            (asserts! (is-some (restrict-assets? u1 u0)) ERR_ASSET_PROTECTION_FAILED)
            (try! (contract-call? nft transfer token-id caller (as-contract tx-sender)))
            (map-set listings listing-id {
                nft-contract: nft-contract, token-id: token-id, seller: caller, price: price,
                listing-type: LISTING_FIXED_PRICE, auction-end: none, highest-bid: u0,
                highest-bidder: none, created-at: current-time, expires-at: (+ current-time duration), active: true
            })
            (map-set nft-to-listing { nft-contract: nft-contract, token-id: token-id } listing-id)
            (var-set listing-counter listing-id)
            (ok listing-id)
        )
    )
)

;; Read-only function to get multiple listing details at once
(define-read-only (get-listings-batch (listing-ids (list 20 uint)))
    (map get-listing listing-ids)
)

;; Read-only function to check if multiple NFTs are already listed
(define-read-only (check-listings-batch (nft-contract principal) (token-ids (list 20 uint)))
    (map check-single-listing token-ids)
)

(define-private (check-single-listing (token-id uint))
    (map-get? nft-to-listing { nft-contract: CONTRACT_OWNER, token-id: token-id })
)

;; ========================================
;; Royalty Read-Only Functions
;; ========================================

;; Get collection royalty settings
(define-read-only (get-collection-royalty (nft-contract principal))
    (map-get? collection-royalties { nft-contract: nft-contract })
)

;; Calculate royalty amount for a sale
(define-read-only (calculate-royalty (nft-contract principal) (sale-price uint))
    (match (get-collection-royalty nft-contract)
        royalty (if (get active royalty)
            (/ (* sale-price (get royalty-bps royalty)) u10000)
            u0)
        u0)
)

;; Get creator's claimable royalties
(define-read-only (get-creator-claimable (creator principal) (nft-contract principal))
    (default-to
        { total-claimable: u0, total-claimed: u0, last-claim-at: u0 }
        (map-get? creator-claimable-royalties { creator: creator, nft-contract: nft-contract }))
)

;; Get royalty payment details
(define-read-only (get-royalty-payment (payment-id uint))
    (map-get? royalty-payments { payment-id: payment-id })
)

;; Get NFT sale history
(define-read-only (get-nft-sale-history (nft-contract principal) (token-id uint))
    (default-to (list) (map-get? nft-sale-history { nft-contract: nft-contract, token-id: token-id }))
)

;; Get total royalties statistics
(define-read-only (get-royalty-stats (nft-contract principal))
    (match (get-collection-royalty nft-contract)
        royalty {
            creator: (get creator royalty),
            royalty-bps: (get royalty-bps royalty),
            total-earned: (get total-earned royalty),
            active: (get active royalty)
        }
        {
            creator: CONTRACT_OWNER,
            royalty-bps: u0,
            total-earned: u0,
            active: false
        })
)

;; ========================================
;; Fractional Ownership Read-Only Functions
;; ========================================

(define-read-only (get-fractional-nft (nft-contract principal) (token-id uint))
    (map-get? fractional-nfts { nft-contract: nft-contract, token-id: token-id })
)

(define-read-only (get-shareholder-balance (nft-contract principal) (token-id uint) (shareholder principal))
    (map-get? shareholder-balances { nft-contract: nft-contract, token-id: token-id, shareholder: shareholder })
)

(define-read-only (get-nft-shareholders (nft-contract principal) (token-id uint))
    (default-to (list) (map-get? nft-shareholders { nft-contract: nft-contract, token-id: token-id }))
)

(define-read-only (get-dividend-distribution (nft-contract principal) (token-id uint) (distribution-id uint))
    (map-get? dividend-distributions { nft-contract: nft-contract, token-id: token-id, distribution-id: distribution-id })
)

(define-read-only (get-dividend-claim (nft-contract principal) (token-id uint) (distribution-id uint) (shareholder principal))
    (map-get? dividend-claims { nft-contract: nft-contract, token-id: token-id, distribution-id: distribution-id, shareholder: shareholder })
)

(define-read-only (calculate-share-value (nft-contract principal) (token-id uint))
    (match (get-fractional-nft nft-contract token-id)
        fraction (if (is-eq (get shares-sold fraction) u0)
            (get share-price fraction)
            (/ (* (get buyout-price fraction) u100) (get total-shares fraction)))
        u0)
)

(define-read-only (get-shareholder-ownership-percent (nft-contract principal) (token-id uint) (shareholder principal))
    (match (get-shareholder-balance nft-contract token-id shareholder)
        balance (match (get-fractional-nft nft-contract token-id)
            fraction (/ (* (get shares balance) u10000) (get total-shares fraction))
            u0)
        u0)
)

;; ========================================
;; Offer Functions
;; ========================================

(define-public (make-offer (nft-contract principal) (token-id uint) (amount uint) (duration uint))
    (let ((caller tx-sender)
          (current-time stacks-block-time)
          (offer-id (+ (var-get offer-counter) u1)))
        (asserts! (is-collection-verified nft-contract) ERR_COLLECTION_NOT_VERIFIED)
        (asserts! (> amount u0) ERR_INVALID_PRICE)
        
        (try! (stx-transfer? amount caller (as-contract tx-sender)))
        (map-set offers offer-id {
            nft-contract: nft-contract, token-id: token-id, offerer: caller,
            amount: amount, expires-at: (+ current-time duration), active: true
        })
        (var-set offer-counter offer-id)
        (ok offer-id)
    )
)

(define-public (accept-offer (offer-id uint) (nft <nft-trait>))
    (let ((caller tx-sender)
          (offer (unwrap! (map-get? offers offer-id) ERR_OFFER_NOT_FOUND))
          (fees (calculate-fees (get nft-contract offer) (get amount offer))))
        (asserts! (get active offer) ERR_OFFER_NOT_FOUND)
        (asserts! (< stacks-block-time (get expires-at offer)) ERR_LISTING_EXPIRED)

        (asserts! (is-some (restrict-assets? u1 u0)) ERR_ASSET_PROTECTION_FAILED)
        (try! (contract-call? nft transfer (get token-id offer) caller (get offerer offer)))
        (try! (as-contract (stx-transfer? (get seller-amount fees) tx-sender caller)))
        (try! (as-contract (stx-transfer? (get platform-fee fees) tx-sender CONTRACT_OWNER)))

        (if (> (get royalty-fee fees) u0)
            (match (map-get? verified-collections (get nft-contract offer))
                collection (try! (as-contract (stx-transfer? (get royalty-fee fees) tx-sender (get royalty-recipient collection))))
                true
            )
            true
        )

        (map-set offers offer-id (merge offer { active: false }))
        (var-set total-volume (+ (var-get total-volume) (get amount offer)))
        (var-set total-sales (+ (var-get total-sales) u1))
        (ok true)
    )
)

(define-public (cancel-offer (offer-id uint))
    (let ((caller tx-sender)
          (offer (unwrap! (map-get? offers offer-id) ERR_OFFER_NOT_FOUND)))
        (asserts! (is-eq caller (get offerer offer)) ERR_NOT_AUTHORIZED)
        (asserts! (get active offer) ERR_OFFER_NOT_FOUND)

        (try! (as-contract (stx-transfer? (get amount offer) tx-sender caller)))
        (map-set offers offer-id (merge offer { active: false }))
        (ok true)
    )
)

;; ========================================
;; Bundle Functions
;; ========================================

;; Create NFT bundle listing
(define-public (create-bundle
    (nft <nft-trait>)
    (token-ids (list 10 uint))
    (total-price uint)
    (discount-bps uint)
    (duration uint))
    (let (
        (nft-contract (contract-of nft))
        (bundle-id (+ (var-get bundle-counter) u1))
        (num-items (len token-ids))
        (current-time stacks-block-time)
        )
        ;; Validations
        (asserts! (is-collection-verified nft-contract) ERR_COLLECTION_NOT_VERIFIED)
        (asserts! (> num-items u1) ERR_INVALID_BUNDLE)
        (asserts! (<= num-items MAX_BUNDLE_SIZE) ERR_BUNDLE_LIMIT_EXCEEDED)
        (asserts! (> total-price u0) ERR_INVALID_PRICE)
        (asserts! (<= discount-bps u5000) ERR_INVALID_BUNDLE) ;; Max 50% discount
        (asserts! (> duration u0) ERR_INVALID_PRICE)

        ;; Create bundle
        (map-set bundles bundle-id {
            nft-contract: nft-contract,
            token-ids: token-ids,
            seller: tx-sender,
            total-price: total-price,
            discount-bps: discount-bps,
            created-at: current-time,
            expires-at: (+ current-time duration),
            active: true
        })

        (var-set bundle-counter bundle-id)

        (print {
            event: "bundle-created",
            bundle-id: bundle-id,
            nft-contract: nft-contract,
            token-ids: token-ids,
            seller: tx-sender,
            total-price: total-price,
            discount-bps: discount-bps,
            expires-at: (+ current-time duration),
            timestamp: current-time
        })

        (ok bundle-id)
    )
)

;; Purchase NFT bundle
(define-public (buy-bundle (bundle-id uint) (nft <nft-trait>))
    (let (
        (bundle (unwrap! (map-get? bundles bundle-id) ERR_BUNDLE_NOT_FOUND))
        (nft-contract (contract-of nft))
        (current-time stacks-block-time)
        (fees (calculate-fees nft-contract (get total-price bundle)))
        )
        ;; Validations
        (asserts! (is-eq nft-contract (get nft-contract bundle)) ERR_COLLECTION_NOT_VERIFIED)
        (asserts! (get active bundle) ERR_LISTING_NOT_FOUND)
        (asserts! (< current-time (get expires-at bundle)) ERR_LISTING_EXPIRED)

        ;; Transfer payment from buyer to seller
        (try! (stx-transfer? (get seller-amount fees) tx-sender (get seller bundle)))

        ;; Pay platform fee
        (try! (stx-transfer? (get platform-fee fees) tx-sender CONTRACT_OWNER))

        ;; Pay royalty
        (if (> (get royalty-fee fees) u0)
            (match (map-get? verified-collections nft-contract)
                collection (try! (stx-transfer? (get royalty-fee fees) tx-sender (get royalty-recipient collection)))
                false
            )
            true
        )

        ;; Transfer all NFTs in bundle to buyer
        (try! (fold transfer-bundle-nft (get token-ids bundle) (ok { nft: nft, seller: (get seller bundle), buyer: tx-sender })))

        ;; Mark bundle as sold
        (map-set bundles bundle-id (merge bundle { active: false }))

        ;; Update stats
        (var-set total-volume (+ (var-get total-volume) (get total-price bundle)))
        (var-set total-sales (+ (var-get total-sales) u1))

        ;; Update collection stats
        (match (map-get? verified-collections nft-contract)
            collection (map-set verified-collections nft-contract
                (merge collection {
                    total-volume: (+ (get total-volume collection) (get total-price bundle)),
                    total-sales: (+ (get total-sales collection) u1)
                }))
            false
        )

        (print {
            event: "bundle-purchased",
            bundle-id: bundle-id,
            buyer: tx-sender,
            seller: (get seller bundle),
            price: (get total-price bundle),
            num-items: (len (get token-ids bundle)),
            discount-bps: (get discount-bps bundle),
            timestamp: current-time
        })

        (ok true)
    )
)

;; Helper function to transfer NFTs in bundle
(define-private (transfer-bundle-nft
    (token-id uint)
    (previous-result (response { nft: <nft-trait>, seller: principal, buyer: principal } uint)))
    (match previous-result
        success (let ((nft-contract (get nft success))
                     (seller (get seller success))
                     (buyer (get buyer success)))
            (try! (contract-call? nft-contract transfer token-id seller buyer))
            (ok success)
        )
        error (err error)
    )
)

;; Cancel bundle listing
(define-public (cancel-bundle (bundle-id uint))
    (let (
        (bundle (unwrap! (map-get? bundles bundle-id) ERR_BUNDLE_NOT_FOUND))
        )
        ;; Validations
        (asserts! (is-eq tx-sender (get seller bundle)) ERR_NOT_AUTHORIZED)
        (asserts! (get active bundle) ERR_LISTING_NOT_FOUND)

        ;; Mark as inactive
        (map-set bundles bundle-id (merge bundle { active: false }))

        (print {
            event: "bundle-cancelled",
            bundle-id: bundle-id,
            seller: tx-sender,
            timestamp: stacks-block-time
        })

        (ok true)
    )
)

;; ========================================
;; NFT Rental Public Functions
;; ========================================

;; Create rental listing for NFT
(define-public (create-rental
    (nft-contract principal)
    (token-id uint)
    (rental-price uint)
    (duration uint)
    (deposit-amount uint)
    (nft <nft-trait>))
    (let
        (
            (rental-id (var-get rental-counter))
            (current-time stacks-block-time)
            (nft-principal (contract-of nft))
            (owner-list (get-owner-rentals tx-sender))
        )
        ;; Validations
        (asserts! (is-eq nft-principal nft-contract) ERR_NOT_AUTHORIZED)
        (asserts! (is-collection-verified nft-contract) ERR_COLLECTION_NOT_VERIFIED)
        (asserts! (> rental-price u0) ERR_INVALID_PRICE)
        (asserts! (> duration u0) ERR_INVALID_PRICE)
        (asserts! (is-none (map-get? nft-to-rental { nft-contract: nft-contract, token-id: token-id })) ERR_ALREADY_RENTED)

        ;; Transfer NFT to contract for custody
        (try! (contract-call? nft transfer token-id tx-sender (as-contract tx-sender)))

        ;; Create rental record
        (map-set rentals
            rental-id
            {
                nft-contract: nft-contract,
                token-id: token-id,
                owner: tx-sender,
                renter: tx-sender, ;; Temporary, will be updated when rented
                rental-price: rental-price,
                start-time: current-time,
                end-time: (+ current-time duration),
                deposit-amount: deposit-amount,
                returned: false,
                rental-active: false  ;; Not active until someone rents it
            }
        )

        ;; Map NFT to rental
        (map-set nft-to-rental { nft-contract: nft-contract, token-id: token-id } rental-id)

        ;; Track owner rentals
        (map-set owner-rentals
            tx-sender
            (unwrap! (as-max-len? (append owner-list rental-id) u50) ERR_BULK_OPERATION_FAILED)
        )

        ;; Increment counter
        (var-set rental-counter (+ rental-id u1))

        ;; Emit Chainhook event
        (print {
            event: "rental-created",
            rental-id: rental-id,
            nft-contract: nft-contract,
            token-id: token-id,
            owner: tx-sender,
            rental-price: rental-price,
            duration: duration,
            deposit-amount: deposit-amount,
            timestamp: current-time
        })

        (ok rental-id)
    )
)

;; Rent an NFT
(define-public (rent-nft (rental-id uint) (nft <nft-trait>))
    (let
        (
            (rental (unwrap! (get-rental rental-id) ERR_RENTAL_NOT_FOUND))
            (current-time stacks-block-time)
            (nft-principal (contract-of nft))
            (renter-list (get-renter-rentals tx-sender))
            (total-payment (+ (get rental-price rental) (get deposit-amount rental)))
        )
        ;; Validations
        (asserts! (is-eq nft-principal (get nft-contract rental)) ERR_NOT_AUTHORIZED)
        (asserts! (not (get rental-active rental)) ERR_RENTAL_ACTIVE)
        (asserts! (not (is-eq tx-sender (get owner rental))) ERR_NOT_AUTHORIZED)

        ;; Transfer payment to owner (rental price + deposit)
        (try! (stx-transfer? total-payment tx-sender (get owner rental)))

        ;; Transfer NFT to renter
        (try! (as-contract (contract-call? nft transfer (get token-id rental) tx-sender tx-sender)))

        ;; Update rental record
        (map-set rentals
            rental-id
            (merge rental {
                renter: tx-sender,
                start-time: current-time,
                end-time: (+ current-time (- (get end-time rental) (get start-time rental))),
                rental-active: true
            })
        )

        ;; Track renter rentals
        (map-set renter-rentals
            tx-sender
            (unwrap! (as-max-len? (append renter-list rental-id) u50) ERR_BULK_OPERATION_FAILED)
        )

        ;; Emit Chainhook event
        (print {
            event: "nft-rented",
            rental-id: rental-id,
            renter: tx-sender,
            owner: (get owner rental),
            rental-price: (get rental-price rental),
            deposit: (get deposit-amount rental),
            end-time: (+ current-time (- (get end-time rental) (get start-time rental))),
            timestamp: current-time
        })

        (ok true)
    )
)

;; Return rented NFT
(define-public (return-rental (rental-id uint) (nft <nft-trait>))
    (let
        (
            (rental (unwrap! (get-rental rental-id) ERR_RENTAL_NOT_FOUND))
            (current-time stacks-block-time)
            (nft-principal (contract-of nft))
        )
        ;; Validations
        (asserts! (is-eq nft-principal (get nft-contract rental)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq tx-sender (get renter rental)) ERR_NOT_AUTHORIZED)
        (asserts! (get rental-active rental) ERR_RENTAL_NOT_FOUND)
        (asserts! (not (get returned rental)) ERR_RENTAL_NOT_FOUND)

        ;; Transfer NFT back to owner
        (try! (contract-call? nft transfer (get token-id rental) tx-sender (get owner rental)))

        ;; Return deposit to renter if returned on time
        (if (<= current-time (get end-time rental))
            (try! (as-contract (stx-transfer? (get deposit-amount rental) tx-sender (get renter rental))))
            true  ;; Deposit forfeited if late
        )

        ;; Update rental record
        (map-set rentals
            rental-id
            (merge rental {
                returned: true,
                rental-active: false
            })
        )

        ;; Remove NFT from rental mapping
        (map-delete nft-to-rental { nft-contract: (get nft-contract rental), token-id: (get token-id rental) })

        ;; Emit Chainhook event
        (print {
            event: "rental-returned",
            rental-id: rental-id,
            renter: tx-sender,
            owner: (get owner rental),
            returned-on-time: (<= current-time (get end-time rental)),
            deposit-returned: (<= current-time (get end-time rental)),
            timestamp: current-time
        })

        (ok true)
    )
)

;; Cancel rental listing (only if not active)
(define-public (cancel-rental (rental-id uint) (nft <nft-trait>))
    (let
        (
            (rental (unwrap! (get-rental rental-id) ERR_RENTAL_NOT_FOUND))
            (nft-principal (contract-of nft))
        )
        ;; Validations
        (asserts! (is-eq nft-principal (get nft-contract rental)) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq tx-sender (get owner rental)) ERR_NOT_AUTHORIZED)
        (asserts! (not (get rental-active rental)) ERR_RENTAL_ACTIVE)

        ;; Transfer NFT back to owner
        (try! (as-contract (contract-call? nft transfer (get token-id rental) tx-sender (get owner rental))))

        ;; Remove rental mapping
        (map-delete nft-to-rental { nft-contract: (get nft-contract rental), token-id: (get token-id rental) })
        (map-delete rentals rental-id)

        ;; Emit Chainhook event
        (print {
            event: "rental-cancelled",
            rental-id: rental-id,
            owner: tx-sender,
            timestamp: stacks-block-time
        })

        (ok true)
    )
)

;; ========================================
;; Creator Royalty Public Functions
;; ========================================

;; Set royalty for a collection (creator only)
(define-public (set-collection-royalty (nft-contract principal) (royalty-bps uint))
    (let
        (
            (current-time stacks-block-time)
        )
        ;; Validations
        (asserts! (is-collection-verified nft-contract) ERR_COLLECTION_NOT_VERIFIED)
        (asserts! (<= royalty-bps (var-get max-royalty-bps)) ERR_INVALID_ROYALTY)
        (asserts! (is-none (get-collection-royalty nft-contract)) ERR_ROYALTY_ALREADY_SET)

        ;; Set royalty
        (map-set collection-royalties
            { nft-contract: nft-contract }
            {
                creator: tx-sender,
                royalty-bps: royalty-bps,
                total-earned: u0,
                set-at: current-time,
                active: true
            }
        )

        ;; Initialize creator claimable tracking
        (map-set creator-claimable-royalties
            { creator: tx-sender, nft-contract: nft-contract }
            {
                total-claimable: u0,
                total-claimed: u0,
                last-claim-at: current-time
            }
        )

        ;; Emit Chainhook event
        (print {
            event: "royalty-set",
            nft-contract: nft-contract,
            creator: tx-sender,
            royalty-bps: royalty-bps,
            timestamp: current-time
        })

        (ok true)
    )
)

;; Process royalty payment (called during sales)
(define-public (process-royalty-payment
    (nft-contract principal)
    (token-id uint)
    (sale-price uint)
    (seller principal)
    (buyer principal))
    (let
        (
            (royalty-settings (unwrap! (get-collection-royalty nft-contract) ERR_ROYALTY_NOT_SET))
            (royalty-amount (calculate-royalty nft-contract sale-price))
            (payment-id (+ (var-get royalty-payment-counter) u1))
            (creator (get creator royalty-settings))
            (current-claimable (get-creator-claimable creator nft-contract))
            (existing-history (get-nft-sale-history nft-contract token-id))
            (current-time stacks-block-time)
        )
        ;; Validations
        (asserts! (get active royalty-settings) ERR_ROYALTY_NOT_SET)
        (asserts! (> royalty-amount u0) ERR_INSUFFICIENT_AMOUNT)

        ;; Record royalty payment
        (map-set royalty-payments
            { payment-id: payment-id }
            {
                nft-contract: nft-contract,
                token-id: token-id,
                sale-price: sale-price,
                royalty-amount: royalty-amount,
                creator: creator,
                paid-at: current-time,
                seller: seller,
                buyer: buyer
            }
        )

        ;; Update claimable royalties
        (map-set creator-claimable-royalties
            { creator: creator, nft-contract: nft-contract }
            (merge current-claimable {
                total-claimable: (+ (get total-claimable current-claimable) royalty-amount)
            })
        )

        ;; Update collection royalty totals
        (map-set collection-royalties
            { nft-contract: nft-contract }
            (merge royalty-settings {
                total-earned: (+ (get total-earned royalty-settings) royalty-amount)
            })
        )

        ;; Update sale history
        (match (as-max-len? (append existing-history payment-id) u20)
            new-history (map-set nft-sale-history
                { nft-contract: nft-contract, token-id: token-id }
                new-history)
            false)

        (var-set royalty-payment-counter payment-id)
        (var-set total-royalties-paid (+ (var-get total-royalties-paid) royalty-amount))

        ;; Emit Chainhook event
        (print {
            event: "royalty-processed",
            payment-id: payment-id,
            nft-contract: nft-contract,
            token-id: token-id,
            sale-price: sale-price,
            royalty-amount: royalty-amount,
            creator: creator,
            seller: seller,
            buyer: buyer,
            timestamp: current-time
        })

        (ok royalty-amount)
    )
)

;; Claim accumulated royalties
(define-public (claim-royalties (nft-contract principal))
    (let
        (
            (royalty-settings (unwrap! (get-collection-royalty nft-contract) ERR_ROYALTY_NOT_SET))
            (claimable-info (get-creator-claimable tx-sender nft-contract))
            (claimable-amount (get total-claimable claimable-info))
            (current-time stacks-block-time)
        )
        ;; Validations
        (asserts! (is-eq tx-sender (get creator royalty-settings)) ERR_NOT_AUTHORIZED)
        (asserts! (> claimable-amount u0) ERR_INSUFFICIENT_AMOUNT)

        ;; Transfer royalties to creator
        (unwrap! (stx-transfer? claimable-amount (var-get contract-principal) tx-sender) ERR_INSUFFICIENT_AMOUNT)

        ;; Update claimable tracking
        (map-set creator-claimable-royalties
            { creator: tx-sender, nft-contract: nft-contract }
            {
                total-claimable: u0,
                total-claimed: (+ (get total-claimed claimable-info) claimable-amount),
                last-claim-at: current-time
            }
        )

        ;; Emit Chainhook event
        (print {
            event: "royalties-claimed",
            nft-contract: nft-contract,
            creator: tx-sender,
            amount-claimed: claimable-amount,
            total-claimed: (+ (get total-claimed claimable-info) claimable-amount),
            timestamp: current-time
        })

        (ok claimable-amount)
    )
)

;; Update royalty settings (creator only)
(define-public (update-royalty-rate (nft-contract principal) (new-royalty-bps uint))
    (let
        (
            (royalty-settings (unwrap! (get-collection-royalty nft-contract) ERR_ROYALTY_NOT_SET))
        )
        ;; Validations
        (asserts! (is-eq tx-sender (get creator royalty-settings)) ERR_NOT_AUTHORIZED)
        (asserts! (<= new-royalty-bps (var-get max-royalty-bps)) ERR_INVALID_ROYALTY)

        ;; Update royalty rate
        (map-set collection-royalties
            { nft-contract: nft-contract }
            (merge royalty-settings {
                royalty-bps: new-royalty-bps
            })
        )

        ;; Emit Chainhook event
        (print {
            event: "royalty-updated",
            nft-contract: nft-contract,
            creator: tx-sender,
            old-royalty-bps: (get royalty-bps royalty-settings),
            new-royalty-bps: new-royalty-bps,
            timestamp: stacks-block-time
        })

        (ok true)
    )
)

;; Toggle royalty collection (creator only)
(define-public (toggle-royalty (nft-contract principal))
    (let
        (
            (royalty-settings (unwrap! (get-collection-royalty nft-contract) ERR_ROYALTY_NOT_SET))
            (new-status (not (get active royalty-settings)))
        )
        ;; Validations
        (asserts! (is-eq tx-sender (get creator royalty-settings)) ERR_NOT_AUTHORIZED)

        ;; Toggle active status
        (map-set collection-royalties
            { nft-contract: nft-contract }
            (merge royalty-settings {
                active: new-status
            })
        )

        ;; Emit Chainhook event
        (print {
            event: "royalty-toggled",
            nft-contract: nft-contract,
            creator: tx-sender,
            active: new-status,
            timestamp: stacks-block-time
        })

        (ok new-status)
    )
)

;; Admin: Set maximum royalty rate
(define-public (set-max-royalty (max-bps uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (<= max-bps u5000) ERR_INVALID_ROYALTY) ;; Max 50%

        (var-set max-royalty-bps max-bps)

        (print {
            event: "max-royalty-updated",
            max-royalty-bps: max-bps,
            timestamp: stacks-block-time
        })

        (ok true)
    )
)

;; ========================================
;; Fractional Ownership Public Functions
;; ========================================

;; Fractionalize an NFT into shares
(define-public (fractionalize-nft (nft-contract <nft-trait>) (token-id uint) (total-shares uint) (share-price uint) (lock-duration uint))
    (let
        (
            (nft-principal (contract-of nft-contract))
            (fraction-id (+ (var-get fraction-counter) u1))
            (current-time stacks-block-time)
            (lock-until (+ current-time lock-duration))
            (buyout-price (* total-shares share-price))
        )
        (asserts! (is-collection-verified nft-principal) ERR_COLLECTION_NOT_VERIFIED)
        (asserts! (is-none (get-fractional-nft nft-principal token-id)) ERR_FRACTION_EXISTS)
        (asserts! (> total-shares u1) ERR_INVALID_SHARES)
        (asserts! (<= total-shares u10000) ERR_INVALID_SHARES)
        (asserts! (> share-price u0) ERR_INVALID_PRICE)
        
        ;; Transfer NFT to contract
        (try! (contract-call? nft-contract transfer token-id tx-sender (var-get contract-principal)))
        
        ;; Create fractional NFT
        (map-set fractional-nfts
            { nft-contract: nft-principal, token-id: token-id }
            {
                total-shares: total-shares,
                share-price: share-price,
                shares-sold: u0,
                created-at: current-time,
                creator: tx-sender,
                active: true,
                locked-until: lock-until,
                buyout-price: buyout-price,
                buyout-enabled: false
            }
        )
        
        (var-set fraction-counter fraction-id)
        
        (print {
            event: "nft-fractionalized",
            nft-contract: nft-principal,
            token-id: token-id,
            total-shares: total-shares,
            share-price: share-price,
            creator: tx-sender,
            timestamp: current-time
        })
        
        (ok fraction-id)
    )
)

;; Purchase shares of fractionalized NFT
(define-public (purchase-shares (nft-contract principal) (token-id uint) (shares uint))
    (let
        (
            (fraction (unwrap! (get-fractional-nft nft-contract token-id) ERR_FRACTION_NOT_FOUND))
            (existing-balance (get-shareholder-balance nft-contract token-id tx-sender))
            (cost (* shares (get share-price fraction)))
            (new-shares-sold (+ (get shares-sold fraction) shares))
            (shareholders (get-nft-shareholders nft-contract token-id))
        )
        (asserts! (get active fraction) ERR_FRACTION_LOCKED)
        (asserts! (> shares u0) ERR_INVALID_SHARES)
        (asserts! (<= new-shares-sold (get total-shares fraction)) ERR_INVALID_SHARES)
        
        ;; Transfer payment to creator
        (try! (stx-transfer? cost tx-sender (get creator fraction)))
        
        ;; Update or create shareholder balance
        (match existing-balance
            balance (map-set shareholder-balances
                { nft-contract: nft-contract, token-id: token-id, shareholder: tx-sender }
                {
                    shares: (+ (get shares balance) shares),
                    acquired-at: (get acquired-at balance),
                    total-spent: (+ (get total-spent balance) cost)
                })
            (begin
                (map-set shareholder-balances
                    { nft-contract: nft-contract, token-id: token-id, shareholder: tx-sender }
                    {
                        shares: shares,
                        acquired-at: stacks-block-time,
                        total-spent: cost
                    })
                ;; Add to shareholders list
                (map-set nft-shareholders
                    { nft-contract: nft-contract, token-id: token-id }
                    (unwrap! (as-max-len? (append shareholders tx-sender) u100) ERR_INVALID_SHARES))
            ))
        
        ;; Update fraction
        (map-set fractional-nfts
            { nft-contract: nft-contract, token-id: token-id }
            (merge fraction { shares-sold: new-shares-sold })
        )
        
        (print {
            event: "shares-purchased",
            nft-contract: nft-contract,
            token-id: token-id,
            buyer: tx-sender,
            shares: shares,
            cost: cost,
            timestamp: stacks-block-time
        })
        
        (ok true)
    )
)

;; Distribute dividends to shareholders
(define-public (distribute-dividends (nft-contract principal) (token-id uint) (total-amount uint) (source (string-ascii 64)))
    (let
        (
            (fraction (unwrap! (get-fractional-nft nft-contract token-id) ERR_FRACTION_NOT_FOUND))
            (distribution-id (var-get distribution-counter))
            (per-share (/ total-amount (get shares-sold fraction)))
        )
        (asserts! (get active fraction) ERR_FRACTION_LOCKED)
        (asserts! (> total-amount u0) ERR_INVALID_PRICE)
        (asserts! (> (get shares-sold fraction) u0) ERR_INVALID_SHARES)
        
        ;; Transfer total amount to contract
        (try! (stx-transfer? total-amount tx-sender (var-get contract-principal)))
        
        ;; Create distribution record
        (map-set dividend-distributions
            { nft-contract: nft-contract, token-id: token-id, distribution-id: distribution-id }
            {
                total-amount: total-amount,
                per-share-amount: per-share,
                distributed-at: stacks-block-time,
                source: source
            }
        )
        
        (var-set distribution-counter (+ distribution-id u1))
        
        (print {
            event: "dividends-distributed",
            nft-contract: nft-contract,
            token-id: token-id,
            distribution-id: distribution-id,
            total-amount: total-amount,
            per-share-amount: per-share,
            timestamp: stacks-block-time
        })
        
        (ok distribution-id)
    )
)

;; Claim dividends as shareholder
(define-public (claim-dividends (nft-contract principal) (token-id uint) (distribution-id uint))
    (let
        (
            (balance (unwrap! (get-shareholder-balance nft-contract token-id tx-sender) ERR_NOT_SHAREHOLDER))
            (distribution (unwrap! (get-dividend-distribution nft-contract token-id distribution-id) ERR_LISTING_NOT_FOUND))
            (claim-amount (* (get shares balance) (get per-share-amount distribution)))
        )
        (asserts! (is-none (get-dividend-claim nft-contract token-id distribution-id tx-sender)) ERR_ALREADY_LISTED)
        (asserts! (> claim-amount u0) ERR_INVALID_PRICE)
        
        ;; Transfer dividend to shareholder
        (try! (stx-transfer? claim-amount (var-get contract-principal) tx-sender))
        
        ;; Record claim
        (map-set dividend-claims
            { nft-contract: nft-contract, token-id: token-id, distribution-id: distribution-id, shareholder: tx-sender }
            {
                amount-claimed: claim-amount,
                claimed-at: stacks-block-time
            }
        )
        
        (print {
            event: "dividends-claimed",
            nft-contract: nft-contract,
            token-id: token-id,
            distribution-id: distribution-id,
            shareholder: tx-sender,
            amount: claim-amount,
            timestamp: stacks-block-time
        })
        
        (ok claim-amount)
    )
)

;; Enable buyout option for fractionalized NFT
(define-public (enable-buyout (nft-contract principal) (token-id uint) (buyout-price uint))
    (let
        (
            (fraction (unwrap! (get-fractional-nft nft-contract token-id) ERR_FRACTION_NOT_FOUND))
        )
        (asserts! (is-eq tx-sender (get creator fraction)) ERR_NOT_AUTHORIZED)
        (asserts! (>= stacks-block-time (get locked-until fraction)) ERR_FRACTION_LOCKED)
        (asserts! (> buyout-price u0) ERR_INVALID_PRICE)
        
        (map-set fractional-nfts
            { nft-contract: nft-contract, token-id: token-id }
            (merge fraction {
                buyout-enabled: true,
                buyout-price: buyout-price
            })
        )
        
        (print {
            event: "buyout-enabled",
            nft-contract: nft-contract,
            token-id: token-id,
            buyout-price: buyout-price,
            timestamp: stacks-block-time
        })
        
        (ok true)
    )
)

;; Buyout entire fractionalized NFT
(define-public (buyout-fractional-nft (nft-contract <nft-trait>) (token-id uint))
    (let
        (
            (nft-principal (contract-of nft-contract))
            (fraction (unwrap! (get-fractional-nft nft-principal token-id) ERR_FRACTION_NOT_FOUND))
        )
        (asserts! (get buyout-enabled fraction) ERR_FRACTION_LOCKED)
        (asserts! (get active fraction) ERR_FRACTION_LOCKED)
        
        ;; Transfer buyout price to contract for distribution
        (try! (stx-transfer? (get buyout-price fraction) tx-sender (var-get contract-principal)))
        
        ;; Transfer NFT to buyer
        (try! (contract-call? nft-contract transfer token-id (var-get contract-principal) tx-sender))
        
        ;; Deactivate fraction
        (map-set fractional-nfts
            { nft-contract: nft-principal, token-id: token-id }
            (merge fraction { active: false })
        )
        
        (print {
            event: "fractional-nft-bought-out",
            nft-contract: nft-principal,
            token-id: token-id,
            buyer: tx-sender,
            buyout-price: (get buyout-price fraction),
            timestamp: stacks-block-time
        })
        
        (ok true)
    )
)

;; Claim buyout proceeds as shareholder
(define-public (claim-buyout-proceeds (nft-contract principal) (token-id uint))
    (let
        (
            (fraction (unwrap! (get-fractional-nft nft-contract token-id) ERR_FRACTION_NOT_FOUND))
            (balance (unwrap! (get-shareholder-balance nft-contract token-id tx-sender) ERR_NOT_SHAREHOLDER))
            (share-value (/ (get buyout-price fraction) (get total-shares fraction)))
            (payout (* (get shares balance) share-value))
        )
        (asserts! (not (get active fraction)) ERR_FRACTION_EXISTS)
        (asserts! (> (get shares balance) u0) ERR_INSUFFICIENT_SHARES)
        
        ;; Transfer payout to shareholder
        (try! (stx-transfer? payout (var-get contract-principal) tx-sender))
        
        ;; Zero out shares
        (map-set shareholder-balances
            { nft-contract: nft-contract, token-id: token-id, shareholder: tx-sender }
            (merge balance { shares: u0 })
        )
        
        (print {
            event: "buyout-proceeds-claimed",
            nft-contract: nft-contract,
            token-id: token-id,
            shareholder: tx-sender,
            shares: (get shares balance),
            payout: payout,
            timestamp: stacks-block-time
        })
        
        (ok payout)
    )
)

