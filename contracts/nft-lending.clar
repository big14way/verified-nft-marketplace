;; nft-lending.clar
;; NFT-backed lending and borrowing system with Chainhook integration
;; Uses Clarity 4 epoch 3.3

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u70001))
(define-constant ERR_INVALID_LOAN (err u70002))
(define-constant ERR_LOAN_ACTIVE (err u70003))
(define-constant ERR_LOAN_EXPIRED (err u70004))
(define-constant ERR_INSUFFICIENT_COLLATERAL (err u70005))

(define-data-var loan-counter uint u0)
(define-data-var total-loans-issued uint u0)
(define-data-var total-volume uint u0)

(define-map loan-offers
    uint
    {
        lender: principal,
        nft-contract: principal,
        nft-id: uint,
        loan-amount: uint,
        interest-rate: uint,
        duration: uint,
        borrower: (optional principal),
        created-at: uint,
        expires-at: uint,
        repaid: bool,
        defaulted: bool
    }
)

(define-public (create-loan-offer
    (nft-contract principal)
    (nft-id uint)
    (loan-amount uint)
    (interest-rate uint)
    (duration uint))
    (let
        (
            (loan-id (+ (var-get loan-counter) u1))
        )
        (map-set loan-offers loan-id {
            lender: tx-sender,
            nft-contract: nft-contract,
            nft-id: nft-id,
            loan-amount: loan-amount,
            interest-rate: interest-rate,
            duration: duration,
            borrower: none,
            created-at: stacks-block-time,
            expires-at: (+ stacks-block-time duration),
            repaid: false,
            defaulted: false
        })
        (var-set loan-counter loan-id)
        (print {
            event: "loan-offer-created",
            loan-id: loan-id,
            lender: tx-sender,
            loan-amount: loan-amount,
            interest-rate: interest-rate,
            timestamp: stacks-block-time
        })
        (ok loan-id)
    )
)

(define-public (accept-loan (loan-id uint))
    (let
        (
            (loan (unwrap! (map-get? loan-offers loan-id) ERR_INVALID_LOAN))
        )
        (asserts! (is-none (get borrower loan)) ERR_LOAN_ACTIVE)
        (map-set loan-offers loan-id
            (merge loan {
                borrower: (some tx-sender)
            }))
        (var-set total-loans-issued (+ (var-get total-loans-issued) u1))
        (var-set total-volume (+ (var-get total-volume) (get loan-amount loan)))
        (print {
            event: "loan-accepted",
            loan-id: loan-id,
            borrower: tx-sender,
            amount: (get loan-amount loan),
            timestamp: stacks-block-time
        })
        (ok true)
    )
)

(define-read-only (get-loan (loan-id uint))
    (map-get? loan-offers loan-id)
)
