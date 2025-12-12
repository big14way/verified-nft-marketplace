;; verified-nft.clar
;; Sample verified NFT collection implementing SIP-009
;; Uses Clarity 4 features: stacks-block-time, to-ascii?

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; ========================================
;; Constants
;; ========================================

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u14001))
(define-constant ERR_NOT_FOUND (err u14002))
(define-constant ERR_ALREADY_MINTED (err u14003))
(define-constant ERR_MINT_LIMIT (err u14004))

(define-constant COLLECTION_NAME "Verified Collection")
(define-constant COLLECTION_SYMBOL "VNFT")
(define-constant MAX_SUPPLY u10000)

;; ========================================
;; NFT Definition
;; ========================================

(define-non-fungible-token verified-nft uint)

;; ========================================
;; Data Variables
;; ========================================

(define-data-var last-token-id uint u0)
(define-data-var base-uri (string-ascii 200) "https://api.verified-nft.example/metadata/")
(define-data-var mint-enabled bool true)
(define-data-var mint-price uint u50000000) ;; 50 STX

;; ========================================
;; Data Maps
;; ========================================

;; Token metadata
(define-map token-metadata
    uint
    {
        minted-at: uint,
        minted-by: principal,
        metadata-uri: (string-ascii 240)
    }
)

;; Whitelist for minting
(define-map whitelist
    principal
    uint
)

;; ========================================
;; Read-Only Functions
;; ========================================

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (let ((id-str (unwrap-panic (to-ascii? token-id))))
        (ok (some (concat (var-get base-uri) id-str)))
    )
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? verified-nft token-id))
)

(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

;; Generate token info message using to-ascii?
(define-read-only (get-token-info-message (token-id uint))
    (match (map-get? token-metadata token-id)
        metadata (let
            (
                (id-str (unwrap-panic (to-ascii? token-id)))
                (minted-str (unwrap-panic (to-ascii? (get minted-at metadata))))
            )
            (concat 
                (concat (concat COLLECTION_NAME " #") id-str)
                (concat " | Minted: " minted-str)
            )
        )
        "Token not found"
    )
)

;; Get collection stats
(define-read-only (get-collection-stats)
    {
        name: COLLECTION_NAME,
        symbol: COLLECTION_SYMBOL,
        total-supply: (var-get last-token-id),
        max-supply: MAX_SUPPLY,
        mint-price: (var-get mint-price),
        mint-enabled: (var-get mint-enabled),
        current-time: stacks-block-time
    }
)

;; Check whitelist allocation
(define-read-only (get-whitelist-allocation (user principal))
    (default-to u0 (map-get? whitelist user))
)

;; ========================================
;; Public Functions (SIP-009)
;; ========================================

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR_NOT_AUTHORIZED)
        (nft-transfer? verified-nft token-id sender recipient)
    )
)

;; ========================================
;; Minting Functions
;; ========================================

;; Public mint
(define-public (mint)
    (let ((caller tx-sender) (token-id (+ (var-get last-token-id) u1)) (current-time stacks-block-time))
        ;; Check mint enabled
        (asserts! (var-get mint-enabled) ERR_NOT_AUTHORIZED)
        
        ;; Check supply
        (asserts! (<= token-id MAX_SUPPLY) ERR_MINT_LIMIT)
        
        ;; Collect mint price
        (try! (stx-transfer? (var-get mint-price) caller CONTRACT_OWNER))
        
        ;; Mint NFT
        (try! (nft-mint? verified-nft token-id caller))
        
        ;; Store metadata
        (map-set token-metadata token-id {
            minted-at: current-time,
            minted-by: caller,
            metadata-uri: (unwrap-panic (unwrap-panic (get-token-uri token-id)))
        })
        
        ;; Update counter
        (var-set last-token-id token-id)
        
        ;; Print token info
        (print (get-token-info-message token-id))
        
        (ok token-id)
    )
)

;; Whitelist mint
(define-public (whitelist-mint)
    (let ((caller tx-sender) (allocation (get-whitelist-allocation caller)) (token-id (+ (var-get last-token-id) u1)) (current-time stacks-block-time))
        ;; Check whitelist
        (asserts! (> allocation u0) ERR_NOT_AUTHORIZED)
        
        ;; Check supply
        (asserts! (<= token-id MAX_SUPPLY) ERR_MINT_LIMIT)
        
        ;; Mint NFT (free for whitelist)
        (try! (nft-mint? verified-nft token-id caller))
        
        ;; Store metadata
        (map-set token-metadata token-id {
            minted-at: current-time,
            minted-by: caller,
            metadata-uri: (unwrap-panic (unwrap-panic (get-token-uri token-id)))
        })
        
        ;; Update whitelist allocation
        (map-set whitelist caller (- allocation u1))
        
        ;; Update counter
        (var-set last-token-id token-id)
        
        (ok token-id)
    )
)

;; ========================================
;; Admin Functions
;; ========================================

;; Add to whitelist
(define-public (add-to-whitelist (user principal) (allocation uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (map-set whitelist user allocation)
        (ok true)
    )
)

;; Batch add to whitelist
(define-public (batch-whitelist (users (list 100 principal)) (allocation uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (map add-single-whitelist users)
        (ok true)
    )
)

(define-private (add-single-whitelist (user principal))
    (map-set whitelist user u1)
)

;; Update mint price
(define-public (set-mint-price (new-price uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (var-set mint-price new-price)
        (ok true)
    )
)

;; Toggle minting
(define-public (set-mint-enabled (enabled bool))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (var-set mint-enabled enabled)
        (ok true)
    )
)

;; Update base URI
(define-public (set-base-uri (new-uri (string-ascii 200)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (var-set base-uri new-uri)
        (ok true)
    )
)

;; Admin mint (for giveaways, etc)
(define-public (admin-mint (recipient principal))
    (let ((token-id (+ (var-get last-token-id) u1)) (current-time stacks-block-time))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (<= token-id MAX_SUPPLY) ERR_MINT_LIMIT)
        
        (try! (nft-mint? verified-nft token-id recipient))
        
        (map-set token-metadata token-id {
            minted-at: current-time,
            minted-by: CONTRACT_OWNER,
            metadata-uri: (unwrap-panic (unwrap-panic (get-token-uri token-id)))
        })
        
        (var-set last-token-id token-id)
        
        (ok token-id)
    )
)

