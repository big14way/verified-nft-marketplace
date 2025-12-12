;; SIP-009 NFT Trait
(define-trait nft-trait
  (
    ;; Last token ID
    (get-last-token-id () (response uint uint))
    
    ;; Get token URI
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
    
    ;; Get token owner
    (get-owner (uint) (response (optional principal) uint))
    
    ;; Transfer token
    (transfer (uint principal principal) (response bool uint))
  )
)
