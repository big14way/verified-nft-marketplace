;; provenance-registry.clar
;; On-chain provenance tracking for NFTs
;; Uses Clarity 4 features: to-ascii?, stacks-block-time, contract-hash?

;; ========================================
;; Constants
;; ========================================

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u13001))
(define-constant ERR_NOT_FOUND (err u13002))
(define-constant ERR_ALREADY_EXISTS (err u13003))

;; ========================================
;; Data Variables
;; ========================================

(define-data-var record-counter uint u0)

;; ========================================
;; Data Maps
;; ========================================

;; Provenance records for each NFT
(define-map provenance-records
    { nft-contract: principal, token-id: uint, record-index: uint }
    {
        event-type: (string-ascii 32),
        from-address: (optional principal),
        to-address: (optional principal),
        price: (optional uint),
        timestamp: uint,
        tx-id: (optional (buff 32)),
        notes: (optional (string-ascii 256))
    }
)

;; Count of records per NFT
(define-map nft-record-count
    { nft-contract: principal, token-id: uint }
    uint
)

;; Collection provenance info
(define-map collection-provenance
    principal
    {
        original-creator: principal,
        creation-date: uint,
        total-minted: uint,
        contract-hash: (buff 32),
        verified: bool
    }
)

;; ========================================
;; Read-Only Functions
;; ========================================

;; Get provenance record
(define-read-only (get-record (nft-contract principal) (token-id uint) (record-index uint))
    (map-get? provenance-records { nft-contract: nft-contract, token-id: token-id, record-index: record-index })
)

;; Get record count for NFT
(define-read-only (get-record-count (nft-contract principal) (token-id uint))
    (default-to u0 (map-get? nft-record-count { nft-contract: nft-contract, token-id: token-id }))
)

;; Get collection provenance
(define-read-only (get-collection-provenance (nft-contract principal))
    (map-get? collection-provenance nft-contract)
)

;; Generate provenance summary using to-ascii?
(define-read-only (generate-provenance-summary (nft-contract principal) (token-id uint))
    (let ((record-count (get-record-count nft-contract token-id)) (count-str (unwrap-panic (to-ascii? record-count))) (token-str (unwrap-panic (to-ascii? token-id))))
        (concat 
            (concat (concat "NFT #" token-str) " | Total Records: ")
            count-str
        )
    )
)

;; Generate full certificate using to-ascii?
(define-read-only (generate-certificate (nft-contract principal) (token-id uint))
    (match (map-get? collection-provenance nft-contract)
        collection (let
            (
                (token-str (unwrap-panic (to-ascii? token-id)))
                (created-str (unwrap-panic (to-ascii? (get creation-date collection))))
                (minted-str (unwrap-panic (to-ascii? (get total-minted collection))))
                (record-count (get-record-count nft-contract token-id))
                (records-str (unwrap-panic (to-ascii? record-count)))
            )
            (concat 
                (concat "=== PROVENANCE CERTIFICATE ===" " | Token: #")
                (concat token-str 
                    (concat " | Created: " 
                        (concat created-str 
                            (concat " | Collection Size: " 
                                (concat minted-str 
                                    (concat " | Transfer Records: " records-str)
                                )
                            )
                        )
                    )
                )
            )
        )
        "Collection not registered"
    )
)

;; Verify collection integrity using contract-hash?
(define-read-only (verify-collection-integrity (nft-contract principal))
    (match (map-get? collection-provenance nft-contract)
        collection
            (is-eq (unwrap-panic (contract-hash? nft-contract)) (get contract-hash collection))
        false
    )
)

;; ========================================
;; Admin Functions
;; ========================================

;; Register collection provenance
(define-public (register-collection 
    (nft-contract principal)
    (original-creator principal)
    (total-minted uint))
    (let ((contract-hash (unwrap! (contract-hash? nft-contract) ERR_NOT_FOUND)) (current-time stacks-block-time))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (is-none (map-get? collection-provenance nft-contract)) ERR_ALREADY_EXISTS)
        
        (map-set collection-provenance nft-contract {
            original-creator: original-creator,
            creation-date: current-time,
            total-minted: total-minted,
            contract-hash: contract-hash,
            verified: true
        })
        
        (ok true)
    )
)

;; Update collection minted count
(define-public (update-minted-count (nft-contract principal) (new-count uint))
    (let ((collection (unwrap! (map-get? collection-provenance nft-contract) ERR_NOT_FOUND)))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        
        (map-set collection-provenance nft-contract (merge collection {
            total-minted: new-count
        }))
        
        (ok true)
    )
)

;; ========================================
;; Provenance Recording Functions
;; ========================================

;; Record mint event
(define-public (record-mint 
    (nft-contract principal)
    (token-id uint)
    (minter principal))
    (let ((current-time stacks-block-time) (record-index u0))
        ;; Only authorized recorders (in production, would be the NFT contract)
        (asserts! (or 
            (is-eq tx-sender CONTRACT_OWNER)
            (is-eq tx-sender nft-contract)
        ) ERR_NOT_AUTHORIZED)
        
        (map-set provenance-records 
            { nft-contract: nft-contract, token-id: token-id, record-index: record-index }
            {
                event-type: "MINT",
                from-address: none,
                to-address: (some minter),
                price: none,
                timestamp: current-time,
                tx-id: none,
                notes: none
            }
        )
        
        (map-set nft-record-count { nft-contract: nft-contract, token-id: token-id } u1)
        
        (ok record-index)
    )
)

;; Record transfer event
(define-public (record-transfer
    (nft-contract principal)
    (token-id uint)
    (from-addr principal)
    (to-addr principal)
    (price (optional uint)))
    (let ((current-time stacks-block-time) (current-count (get-record-count nft-contract token-id)))
        ;; Only authorized recorders
        (asserts! (or 
            (is-eq tx-sender CONTRACT_OWNER)
            (is-eq tx-sender nft-contract)
        ) ERR_NOT_AUTHORIZED)
        
        (map-set provenance-records 
            { nft-contract: nft-contract, token-id: token-id, record-index: current-count }
            {
                event-type: "TRANSFER",
                from-address: (some from-addr),
                to-address: (some to-addr),
                price: price,
                timestamp: current-time,
                tx-id: none,
                notes: none
            }
        )
        
        (map-set nft-record-count { nft-contract: nft-contract, token-id: token-id } (+ current-count u1))
        
        (ok current-count)
    )
)

;; Record sale event
(define-public (record-sale
    (nft-contract principal)
    (token-id uint)
    (seller principal)
    (buyer principal)
    (sale-price uint))
    (let ((current-time stacks-block-time) (current-count (get-record-count nft-contract token-id)) (price-str (unwrap-panic (to-ascii? sale-price))))
        ;; Only authorized recorders
        (asserts! (or 
            (is-eq tx-sender CONTRACT_OWNER)
            (is-eq tx-sender nft-contract)
        ) ERR_NOT_AUTHORIZED)
        
        (map-set provenance-records 
            { nft-contract: nft-contract, token-id: token-id, record-index: current-count }
            {
                event-type: "SALE",
                from-address: (some seller),
                to-address: (some buyer),
                price: (some sale-price),
                timestamp: current-time,
                tx-id: none,
                notes: (some (concat "Sale price: " price-str))
            }
        )
        
        (map-set nft-record-count { nft-contract: nft-contract, token-id: token-id } (+ current-count u1))
        
        ;; Print certificate
        (print (generate-certificate nft-contract token-id))
        
        (ok current-count)
    )
)

;; Add custom note to provenance
(define-public (add-provenance-note
    (nft-contract principal)
    (token-id uint)
    (note (string-ascii 256)))
    (let ((current-time stacks-block-time) (current-count (get-record-count nft-contract token-id)))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        
        (map-set provenance-records 
            { nft-contract: nft-contract, token-id: token-id, record-index: current-count }
            {
                event-type: "NOTE",
                from-address: none,
                to-address: none,
                price: none,
                timestamp: current-time,
                tx-id: none,
                notes: (some note)
            }
        )
        
        (map-set nft-record-count { nft-contract: nft-contract, token-id: token-id } (+ current-count u1))
        
        (ok current-count)
    )
)

