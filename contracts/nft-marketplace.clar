;; nft-marketplace.clar
(define-data-var royalty-enabled bool true)
;; Verified NFT marketplace with contract verification and safe trades
(define-data-var royalty-enabled bool true)
;; Uses Clarity 4 features: contract-hash?, restrict-assets?, stacks-block-time, to-ascii?
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)
;; Constants
(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-constant CONTRACT_OWNER tx-sender)
(define-data-var royalty-enabled bool true)
(define-constant ERR_NOT_AUTHORIZED (err u12001))
(define-data-var royalty-enabled bool true)
(define-constant ERR_LISTING_NOT_FOUND (err u12002))
(define-data-var royalty-enabled bool true)
(define-constant ERR_COLLECTION_NOT_VERIFIED (err u12003))
(define-data-var royalty-enabled bool true)
(define-constant ERR_INVALID_PRICE (err u12004))
(define-data-var royalty-enabled bool true)
(define-constant ERR_LISTING_EXPIRED (err u12005))
(define-data-var royalty-enabled bool true)
(define-constant ERR_ASSET_PROTECTION_FAILED (err u12007))
(define-data-var royalty-enabled bool true)
(define-constant ERR_ALREADY_LISTED (err u12008))
(define-data-var royalty-enabled bool true)
(define-constant ERR_OFFER_NOT_FOUND (err u12009))
(define-data-var royalty-enabled bool true)
(define-constant ERR_BULK_OPERATION_FAILED (err u12010))
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-constant LISTING_FIXED_PRICE u0)
(define-data-var royalty-enabled bool true)
(define-constant LISTING_AUCTION u1)
(define-data-var royalty-enabled bool true)
(define-constant MAX_BULK_LISTINGS u20)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)
;; Data Variables
(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-data-var listing-counter uint u0)
(define-data-var royalty-enabled bool true)
(define-data-var offer-counter uint u0)
(define-data-var royalty-enabled bool true)
(define-data-var platform-fee-bps uint u250)
(define-data-var royalty-enabled bool true)
(define-data-var total-volume uint u0)
(define-data-var royalty-enabled bool true)
(define-data-var total-sales uint u0)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)
;; Data Maps
(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-map verified-collections
(define-data-var royalty-enabled bool true)
    principal
(define-data-var royalty-enabled bool true)
    {
(define-data-var royalty-enabled bool true)
        name: (string-ascii 64),
(define-data-var royalty-enabled bool true)
        contract-hash: (buff 32),
(define-data-var royalty-enabled bool true)
        creator: principal,
(define-data-var royalty-enabled bool true)
        royalty-bps: uint,
(define-data-var royalty-enabled bool true)
        royalty-recipient: principal,
(define-data-var royalty-enabled bool true)
        verified-at: uint,
(define-data-var royalty-enabled bool true)
        total-volume: uint,
(define-data-var royalty-enabled bool true)
        total-sales: uint,
(define-data-var royalty-enabled bool true)
        active: bool
(define-data-var royalty-enabled bool true)
    }
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-map listings
(define-data-var royalty-enabled bool true)
    uint
(define-data-var royalty-enabled bool true)
    {
(define-data-var royalty-enabled bool true)
        nft-contract: principal,
(define-data-var royalty-enabled bool true)
        token-id: uint,
(define-data-var royalty-enabled bool true)
        seller: principal,
(define-data-var royalty-enabled bool true)
        price: uint,
(define-data-var royalty-enabled bool true)
        listing-type: uint,
(define-data-var royalty-enabled bool true)
        auction-end: (optional uint),
(define-data-var royalty-enabled bool true)
        highest-bid: uint,
(define-data-var royalty-enabled bool true)
        highest-bidder: (optional principal),
(define-data-var royalty-enabled bool true)
        created-at: uint,
(define-data-var royalty-enabled bool true)
        expires-at: uint,
(define-data-var royalty-enabled bool true)
        active: bool
(define-data-var royalty-enabled bool true)
    }
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-map nft-to-listing
(define-data-var royalty-enabled bool true)
    { nft-contract: principal, token-id: uint }
(define-data-var royalty-enabled bool true)
    uint
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-map offers
(define-data-var royalty-enabled bool true)
    uint
(define-data-var royalty-enabled bool true)
    {
(define-data-var royalty-enabled bool true)
        nft-contract: principal,
(define-data-var royalty-enabled bool true)
        token-id: uint,
(define-data-var royalty-enabled bool true)
        offerer: principal,
(define-data-var royalty-enabled bool true)
        amount: uint,
(define-data-var royalty-enabled bool true)
        expires-at: uint,
(define-data-var royalty-enabled bool true)
        active: bool
(define-data-var royalty-enabled bool true)
    }
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)
;; NFT Trait Import
(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(use-trait nft-trait .nft-trait.nft-trait)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)
;; Read-Only Functions
(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-read-only (get-current-time)
(define-data-var royalty-enabled bool true)
    stacks-block-time
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-read-only (get-collection (nft-contract principal))
(define-data-var royalty-enabled bool true)
    (map-get? verified-collections nft-contract)
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-read-only (is-collection-verified (nft-contract principal))
(define-data-var royalty-enabled bool true)
    (match (map-get? verified-collections nft-contract)
(define-data-var royalty-enabled bool true)
        collection (and 
(define-data-var royalty-enabled bool true)
            (get active collection)
(define-data-var royalty-enabled bool true)
            (match (contract-hash? nft-contract)
(define-data-var royalty-enabled bool true)
                current-hash (is-eq current-hash (get contract-hash collection))
(define-data-var royalty-enabled bool true)
                false
(define-data-var royalty-enabled bool true)
            )
(define-data-var royalty-enabled bool true)
        )
(define-data-var royalty-enabled bool true)
        false
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-read-only (get-listing (listing-id uint))
(define-data-var royalty-enabled bool true)
    (map-get? listings listing-id)
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-read-only (get-offer (offer-id uint))
(define-data-var royalty-enabled bool true)
    (map-get? offers offer-id)
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-read-only (is-listing-active (listing-id uint))
(define-data-var royalty-enabled bool true)
    (match (map-get? listings listing-id)
(define-data-var royalty-enabled bool true)
        listing (and (get active listing) (< stacks-block-time (get expires-at listing)))
(define-data-var royalty-enabled bool true)
        false
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-read-only (generate-listing-message (listing-id uint))
(define-data-var royalty-enabled bool true)
    (match (map-get? listings listing-id)
(define-data-var royalty-enabled bool true)
        listing (let
(define-data-var royalty-enabled bool true)
            (
(define-data-var royalty-enabled bool true)
                (id-str (unwrap-panic (to-ascii? listing-id)))
(define-data-var royalty-enabled bool true)
                (price-str (unwrap-panic (to-ascii? (get price listing))))
(define-data-var royalty-enabled bool true)
                (token-str (unwrap-panic (to-ascii? (get token-id listing))))
(define-data-var royalty-enabled bool true)
            )
(define-data-var royalty-enabled bool true)
            (concat (concat (concat "Listing #" id-str) (concat " | Token #" token-str)) (concat " | Price: " price-str))
(define-data-var royalty-enabled bool true)
        )
(define-data-var royalty-enabled bool true)
        "Listing not found"
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-read-only (generate-provenance-certificate (nft-contract principal) (token-id uint))
(define-data-var royalty-enabled bool true)
    (match (map-get? verified-collections nft-contract)
(define-data-var royalty-enabled bool true)
        collection (let
(define-data-var royalty-enabled bool true)
            (
(define-data-var royalty-enabled bool true)
                (token-str (unwrap-panic (to-ascii? token-id)))
(define-data-var royalty-enabled bool true)
                (verified-str (unwrap-panic (to-ascii? (get verified-at collection))))
(define-data-var royalty-enabled bool true)
            )
(define-data-var royalty-enabled bool true)
            (concat (concat (concat "CERTIFICATE | " (get name collection)) (concat " #" token-str)) (concat " | Verified: " verified-str))
(define-data-var royalty-enabled bool true)
        )
(define-data-var royalty-enabled bool true)
        "Unverified"
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-read-only (calculate-fees (nft-contract principal) (sale-price uint))
(define-data-var royalty-enabled bool true)
    (let ((platform-fee (/ (* sale-price (var-get platform-fee-bps)) u10000))
(define-data-var royalty-enabled bool true)
          (royalty-fee (match (map-get? verified-collections nft-contract)
(define-data-var royalty-enabled bool true)
              collection (/ (* sale-price (get royalty-bps collection)) u10000)
(define-data-var royalty-enabled bool true)
              u0
(define-data-var royalty-enabled bool true)
          )))
(define-data-var royalty-enabled bool true)
        { platform-fee: platform-fee, royalty-fee: royalty-fee, seller-amount: (- sale-price (+ platform-fee royalty-fee)) }
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-read-only (get-platform-stats)
(define-data-var royalty-enabled bool true)
    {
(define-data-var royalty-enabled bool true)
        total-listings: (var-get listing-counter),
(define-data-var royalty-enabled bool true)
        total-offers: (var-get offer-counter),
(define-data-var royalty-enabled bool true)
        total-volume: (var-get total-volume),
(define-data-var royalty-enabled bool true)
        total-sales: (var-get total-sales),
(define-data-var royalty-enabled bool true)
        platform-fee-bps: (var-get platform-fee-bps)
(define-data-var royalty-enabled bool true)
    }
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)
;; Admin Functions
(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-public (verify-collection (nft-contract principal) (name (string-ascii 64)) (creator principal) (royalty-bps uint) (royalty-recipient principal))
(define-data-var royalty-enabled bool true)
    (let ((contract-hash (unwrap! (contract-hash? nft-contract) ERR_COLLECTION_NOT_VERIFIED))
(define-data-var royalty-enabled bool true)
          (current-time stacks-block-time))
(define-data-var royalty-enabled bool true)
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
(define-data-var royalty-enabled bool true)
        (asserts! (<= royalty-bps u1000) ERR_INVALID_PRICE)
(define-data-var royalty-enabled bool true)
        
(define-data-var royalty-enabled bool true)
        (map-set verified-collections nft-contract {
(define-data-var royalty-enabled bool true)
            name: name, contract-hash: contract-hash, creator: creator,
(define-data-var royalty-enabled bool true)
            royalty-bps: royalty-bps, royalty-recipient: royalty-recipient,
(define-data-var royalty-enabled bool true)
            verified-at: current-time, total-volume: u0, total-sales: u0, active: true
(define-data-var royalty-enabled bool true)
        })
(define-data-var royalty-enabled bool true)
        (ok true)
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-public (revoke-collection (nft-contract principal))
(define-data-var royalty-enabled bool true)
    (let ((collection (unwrap! (map-get? verified-collections nft-contract) ERR_COLLECTION_NOT_VERIFIED)))
(define-data-var royalty-enabled bool true)
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
(define-data-var royalty-enabled bool true)
        (map-set verified-collections nft-contract (merge collection { active: false }))
(define-data-var royalty-enabled bool true)
        (ok true)
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-public (set-platform-fee (new-fee-bps uint))
(define-data-var royalty-enabled bool true)
    (begin
(define-data-var royalty-enabled bool true)
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
(define-data-var royalty-enabled bool true)
        (asserts! (<= new-fee-bps u500) ERR_INVALID_PRICE)
(define-data-var royalty-enabled bool true)
        (var-set platform-fee-bps new-fee-bps)
(define-data-var royalty-enabled bool true)
        (ok true)
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)
;; Listing Functions
(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-public (list-nft (nft-contract principal) (token-id uint) (price uint) (duration uint) (nft <nft-trait>))
(define-data-var royalty-enabled bool true)
    (let ((caller tx-sender) (current-time stacks-block-time) (listing-id (+ (var-get listing-counter) u1)))
(define-data-var royalty-enabled bool true)
        (begin
(define-data-var royalty-enabled bool true)
            (asserts! (is-collection-verified nft-contract) ERR_COLLECTION_NOT_VERIFIED)
(define-data-var royalty-enabled bool true)
            (asserts! (> price u0) ERR_INVALID_PRICE)
(define-data-var royalty-enabled bool true)
            (asserts! (is-none (map-get? nft-to-listing { nft-contract: nft-contract, token-id: token-id })) ERR_ALREADY_LISTED)
(define-data-var royalty-enabled bool true)
            (asserts! (is-some (restrict-assets? u1 u0)) ERR_ASSET_PROTECTION_FAILED)
(define-data-var royalty-enabled bool true)
            (try! (contract-call? nft transfer token-id caller (as-contract tx-sender)))
(define-data-var royalty-enabled bool true)
            (map-set listings listing-id {
(define-data-var royalty-enabled bool true)
                nft-contract: nft-contract, token-id: token-id, seller: caller, price: price,
(define-data-var royalty-enabled bool true)
                listing-type: LISTING_FIXED_PRICE, auction-end: none, highest-bid: u0,
(define-data-var royalty-enabled bool true)
                highest-bidder: none, created-at: current-time, expires-at: (+ current-time duration), active: true
(define-data-var royalty-enabled bool true)
            })
(define-data-var royalty-enabled bool true)
            (map-set nft-to-listing { nft-contract: nft-contract, token-id: token-id } listing-id)
(define-data-var royalty-enabled bool true)
            (var-set listing-counter listing-id)
(define-data-var royalty-enabled bool true)
            (print (generate-listing-message listing-id))
(define-data-var royalty-enabled bool true)
            (ok listing-id)
(define-data-var royalty-enabled bool true)
        )
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-public (buy-nft (listing-id uint) (nft <nft-trait>))
(define-data-var royalty-enabled bool true)
    (let ((caller tx-sender)
(define-data-var royalty-enabled bool true)
          (listing (unwrap! (map-get? listings listing-id) ERR_LISTING_NOT_FOUND))
(define-data-var royalty-enabled bool true)
          (fees (calculate-fees (get nft-contract listing) (get price listing))))
(define-data-var royalty-enabled bool true)
        (asserts! (get active listing) ERR_LISTING_NOT_FOUND)
(define-data-var royalty-enabled bool true)
        (asserts! (< stacks-block-time (get expires-at listing)) ERR_LISTING_EXPIRED)
(define-data-var royalty-enabled bool true)
        
(define-data-var royalty-enabled bool true)
        (try! (stx-transfer? (get price listing) caller (as-contract tx-sender)))
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
        (asserts! (is-some (restrict-assets? u1 u0)) ERR_ASSET_PROTECTION_FAILED)
(define-data-var royalty-enabled bool true)
        (try! (as-contract (contract-call? nft transfer (get token-id listing) tx-sender caller)))
(define-data-var royalty-enabled bool true)
        (try! (as-contract (stx-transfer? (get seller-amount fees) tx-sender (get seller listing))))
(define-data-var royalty-enabled bool true)
        (try! (as-contract (stx-transfer? (get platform-fee fees) tx-sender CONTRACT_OWNER)))
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
        (if (> (get royalty-fee fees) u0)
(define-data-var royalty-enabled bool true)
            (match (map-get? verified-collections (get nft-contract listing))
(define-data-var royalty-enabled bool true)
                collection (try! (as-contract (stx-transfer? (get royalty-fee fees) tx-sender (get royalty-recipient collection))))
(define-data-var royalty-enabled bool true)
                true
(define-data-var royalty-enabled bool true)
            )
(define-data-var royalty-enabled bool true)
            true
(define-data-var royalty-enabled bool true)
        )
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
        (map-set listings listing-id (merge listing { active: false }))
(define-data-var royalty-enabled bool true)
        (map-delete nft-to-listing { nft-contract: (get nft-contract listing), token-id: (get token-id listing) })
(define-data-var royalty-enabled bool true)
        (var-set total-volume (+ (var-get total-volume) (get price listing)))
(define-data-var royalty-enabled bool true)
        (var-set total-sales (+ (var-get total-sales) u1))
(define-data-var royalty-enabled bool true)
        (ok true)
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-public (cancel-listing (listing-id uint) (nft <nft-trait>))
(define-data-var royalty-enabled bool true)
    (let ((caller tx-sender)
(define-data-var royalty-enabled bool true)
          (listing (unwrap! (map-get? listings listing-id) ERR_LISTING_NOT_FOUND)))
(define-data-var royalty-enabled bool true)
        (asserts! (is-eq caller (get seller listing)) ERR_NOT_AUTHORIZED)
(define-data-var royalty-enabled bool true)
        (asserts! (get active listing) ERR_LISTING_NOT_FOUND)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
        (try! (as-contract (contract-call? nft transfer (get token-id listing) tx-sender caller)))
(define-data-var royalty-enabled bool true)
        (map-set listings listing-id (merge listing { active: false }))
(define-data-var royalty-enabled bool true)
        (map-delete nft-to-listing { nft-contract: (get nft-contract listing), token-id: (get token-id listing) })
(define-data-var royalty-enabled bool true)
        (ok true)
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)
;; Bulk Listing Functions
(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; Helper function for bulk listing - lists a single NFT as part of a batch operation
(define-data-var royalty-enabled bool true)
;; This can be called multiple times in sequence for bulk listing operations
(define-data-var royalty-enabled bool true)
(define-public (list-nft-batch-item
(define-data-var royalty-enabled bool true)
    (nft-contract principal)
(define-data-var royalty-enabled bool true)
    (token-id uint)
(define-data-var royalty-enabled bool true)
    (price uint)
(define-data-var royalty-enabled bool true)
    (duration uint)
(define-data-var royalty-enabled bool true)
    (nft <nft-trait>))
(define-data-var royalty-enabled bool true)
    (let ((caller tx-sender) (current-time stacks-block-time) (listing-id (+ (var-get listing-counter) u1)))
(define-data-var royalty-enabled bool true)
        (begin
(define-data-var royalty-enabled bool true)
            (asserts! (is-collection-verified nft-contract) ERR_COLLECTION_NOT_VERIFIED)
(define-data-var royalty-enabled bool true)
            (asserts! (> price u0) ERR_INVALID_PRICE)
(define-data-var royalty-enabled bool true)
            (asserts! (is-none (map-get? nft-to-listing { nft-contract: nft-contract, token-id: token-id })) ERR_ALREADY_LISTED)
(define-data-var royalty-enabled bool true)
            (asserts! (is-some (restrict-assets? u1 u0)) ERR_ASSET_PROTECTION_FAILED)
(define-data-var royalty-enabled bool true)
            (try! (contract-call? nft transfer token-id caller (as-contract tx-sender)))
(define-data-var royalty-enabled bool true)
            (map-set listings listing-id {
(define-data-var royalty-enabled bool true)
                nft-contract: nft-contract, token-id: token-id, seller: caller, price: price,
(define-data-var royalty-enabled bool true)
                listing-type: LISTING_FIXED_PRICE, auction-end: none, highest-bid: u0,
(define-data-var royalty-enabled bool true)
                highest-bidder: none, created-at: current-time, expires-at: (+ current-time duration), active: true
(define-data-var royalty-enabled bool true)
            })
(define-data-var royalty-enabled bool true)
            (map-set nft-to-listing { nft-contract: nft-contract, token-id: token-id } listing-id)
(define-data-var royalty-enabled bool true)
            (var-set listing-counter listing-id)
(define-data-var royalty-enabled bool true)
            (ok listing-id)
(define-data-var royalty-enabled bool true)
        )
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; Read-only function to get multiple listing details at once
(define-data-var royalty-enabled bool true)
(define-read-only (get-listings-batch (listing-ids (list 20 uint)))
(define-data-var royalty-enabled bool true)
    (map get-listing listing-ids)
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; Read-only function to check if multiple NFTs are already listed
(define-data-var royalty-enabled bool true)
(define-read-only (check-listings-batch (nft-contract principal) (token-ids (list 20 uint)))
(define-data-var royalty-enabled bool true)
    (map check-single-listing token-ids)
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-private (check-single-listing (token-id uint))
(define-data-var royalty-enabled bool true)
    (map-get? nft-to-listing { nft-contract: CONTRACT_OWNER, token-id: token-id })
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)
;; Offer Functions
(define-data-var royalty-enabled bool true)
;; ========================================
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-public (make-offer (nft-contract principal) (token-id uint) (amount uint) (duration uint))
(define-data-var royalty-enabled bool true)
    (let ((caller tx-sender)
(define-data-var royalty-enabled bool true)
          (current-time stacks-block-time)
(define-data-var royalty-enabled bool true)
          (offer-id (+ (var-get offer-counter) u1)))
(define-data-var royalty-enabled bool true)
        (asserts! (is-collection-verified nft-contract) ERR_COLLECTION_NOT_VERIFIED)
(define-data-var royalty-enabled bool true)
        (asserts! (> amount u0) ERR_INVALID_PRICE)
(define-data-var royalty-enabled bool true)
        
(define-data-var royalty-enabled bool true)
        (try! (stx-transfer? amount caller (as-contract tx-sender)))
(define-data-var royalty-enabled bool true)
        (map-set offers offer-id {
(define-data-var royalty-enabled bool true)
            nft-contract: nft-contract, token-id: token-id, offerer: caller,
(define-data-var royalty-enabled bool true)
            amount: amount, expires-at: (+ current-time duration), active: true
(define-data-var royalty-enabled bool true)
        })
(define-data-var royalty-enabled bool true)
        (var-set offer-counter offer-id)
(define-data-var royalty-enabled bool true)
        (ok offer-id)
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-public (accept-offer (offer-id uint) (nft <nft-trait>))
(define-data-var royalty-enabled bool true)
    (let ((caller tx-sender)
(define-data-var royalty-enabled bool true)
          (offer (unwrap! (map-get? offers offer-id) ERR_OFFER_NOT_FOUND))
(define-data-var royalty-enabled bool true)
          (fees (calculate-fees (get nft-contract offer) (get amount offer))))
(define-data-var royalty-enabled bool true)
        (asserts! (get active offer) ERR_OFFER_NOT_FOUND)
(define-data-var royalty-enabled bool true)
        (asserts! (< stacks-block-time (get expires-at offer)) ERR_LISTING_EXPIRED)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
        (asserts! (is-some (restrict-assets? u1 u0)) ERR_ASSET_PROTECTION_FAILED)
(define-data-var royalty-enabled bool true)
        (try! (contract-call? nft transfer (get token-id offer) caller (get offerer offer)))
(define-data-var royalty-enabled bool true)
        (try! (as-contract (stx-transfer? (get seller-amount fees) tx-sender caller)))
(define-data-var royalty-enabled bool true)
        (try! (as-contract (stx-transfer? (get platform-fee fees) tx-sender CONTRACT_OWNER)))
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
        (if (> (get royalty-fee fees) u0)
(define-data-var royalty-enabled bool true)
            (match (map-get? verified-collections (get nft-contract offer))
(define-data-var royalty-enabled bool true)
                collection (try! (as-contract (stx-transfer? (get royalty-fee fees) tx-sender (get royalty-recipient collection))))
(define-data-var royalty-enabled bool true)
                true
(define-data-var royalty-enabled bool true)
            )
(define-data-var royalty-enabled bool true)
            true
(define-data-var royalty-enabled bool true)
        )
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
        (map-set offers offer-id (merge offer { active: false }))
(define-data-var royalty-enabled bool true)
        (var-set total-volume (+ (var-get total-volume) (get amount offer)))
(define-data-var royalty-enabled bool true)
        (var-set total-sales (+ (var-get total-sales) u1))
(define-data-var royalty-enabled bool true)
        (ok true)
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)

(define-data-var royalty-enabled bool true)
(define-public (cancel-offer (offer-id uint))
(define-data-var royalty-enabled bool true)
    (let ((caller tx-sender)
(define-data-var royalty-enabled bool true)
          (offer (unwrap! (map-get? offers offer-id) ERR_OFFER_NOT_FOUND)))
(define-data-var royalty-enabled bool true)
        (asserts! (is-eq caller (get offerer offer)) ERR_NOT_AUTHORIZED)
(define-data-var royalty-enabled bool true)
        (asserts! (get active offer) ERR_OFFER_NOT_FOUND)
(define-data-var royalty-enabled bool true)
        
(define-data-var royalty-enabled bool true)
        (try! (as-contract (stx-transfer? (get amount offer) tx-sender caller)))
(define-data-var royalty-enabled bool true)
        (map-set offers offer-id (merge offer { active: false }))
(define-data-var royalty-enabled bool true)
        (ok true)
(define-data-var royalty-enabled bool true)
    )
(define-data-var royalty-enabled bool true)
)
(define-data-var royalty-enabled bool true)
