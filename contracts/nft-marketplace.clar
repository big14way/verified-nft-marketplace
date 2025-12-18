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

(define-constant LISTING_FIXED_PRICE u0)
(define-constant LISTING_AUCTION u1)
(define-constant MAX_BULK_LISTINGS u20)

;; ========================================
;; Data Variables
;; ========================================

(define-data-var listing-counter uint u0)
(define-data-var offer-counter uint u0)
(define-data-var platform-fee-bps uint u250)
(define-data-var total-volume uint u0)
(define-data-var total-sales uint u0)

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
        platform-fee-bps: (var-get platform-fee-bps)
    }
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
