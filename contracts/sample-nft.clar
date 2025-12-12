;; Sample NFT Collection for Testing
(impl-trait .nft-trait.nft-trait)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_MINTED (err u102))
(define-constant COLLECTION_LIMIT u10000)

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var base-uri (string-ascii 200) "https://example.com/nft/")

;; NFT definition
(define-non-fungible-token sample-nft uint)

;; Token metadata
(define-map token-uris
  { token-id: uint }
  { uri: (string-ascii 256) }
)

;; SIP-009 Functions

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (get uri (map-get? token-uris { token-id: token-id })))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? sample-nft token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_NOT_AUTHORIZED)
    (nft-transfer? sample-nft token-id sender recipient)
  )
)

;; Mint function
(define-public (mint (recipient principal))
  (let (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (<= token-id COLLECTION_LIMIT) ERR_ALREADY_MINTED)
    
    (try! (nft-mint? sample-nft token-id recipient))
    
    ;; Set token URI
    (map-set token-uris
      { token-id: token-id }
      { uri: "https://example.com/nft/metadata.json" }
    )
    
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

;; Batch mint
(define-public (batch-mint (recipient principal) (count uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (<= count u10) ERR_NOT_AUTHORIZED) ;; Max 10 per batch
    
    (fold mint-one (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) 
      { recipient: recipient, count: count, minted: u0 })
    
    (ok true)
  )
)

;; Helper for batch mint
(define-private (mint-one (idx uint) (state { recipient: principal, count: uint, minted: uint }))
  (if (< (get minted state) (get count state))
    (begin
      (unwrap-panic (mint (get recipient state)))
      { recipient: (get recipient state), count: (get count state), minted: (+ (get minted state) u1) }
    )
    state
  )
)

;; Set base URI (admin)
(define-public (set-base-uri (new-uri (string-ascii 200)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (var-set base-uri new-uri)
    (ok true)
  )
)
