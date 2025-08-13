(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_EXISTS (err u102))
(define-constant ERR_INVALID_STAGE (err u103))
(define-constant ERR_INVALID_STATUS (err u104))

(define-data-var material-counter uint u0)
(define-data-var transfer-counter uint u0)

(define-map participants principal 
    {
        role: (string-ascii 20),
        company-name: (string-ascii 100),
        location: (string-ascii 100),
        verified: bool
    }
)

(define-map materials uint
    {
        material-type: (string-ascii 20),
        origin-mine: (string-ascii 100),
        quantity: uint,
        current-owner: principal,
        current-stage: (string-ascii 20),
        status: (string-ascii 20),
        created-at: uint,
        gps-latitude: (string-ascii 20),
        gps-longitude: (string-ascii 20),
        iot-sensor-id: (string-ascii 50),
        ethical-certificate: bool
    }
)

(define-map transfers uint
    {
        material-id: uint,
        from-participant: principal,
        to-participant: principal,
        from-stage: (string-ascii 20),
        to-stage: (string-ascii 20),
        transfer-date: uint,
        gps-latitude: (string-ascii 20),
        gps-longitude: (string-ascii 20),
        verification-hash: (string-ascii 64),
        verified: bool
    }
)

(define-map material-history uint (list 50 uint))

(define-public (register-participant 
    (participant principal)
    (role (string-ascii 20))
    (company-name (string-ascii 100))
    (location (string-ascii 100)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (map-set participants participant
            {
                role: role,
                company-name: company-name,
                location: location,
                verified: true
            }
        )
        (ok true)
    )
)

(define-public (register-material
    (material-type (string-ascii 20))
    (origin-mine (string-ascii 100))
    (quantity uint)
    (gps-latitude (string-ascii 20))
    (gps-longitude (string-ascii 20))
    (iot-sensor-id (string-ascii 50)))
    (let 
        (
            (participant-info (map-get? participants tx-sender))
            (material-id (+ (var-get material-counter) u1))
        )
        (asserts! (is-some participant-info) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get role (unwrap-panic participant-info)) "mine") ERR_UNAUTHORIZED)
        (map-set materials material-id
            {
                material-type: material-type,
                origin-mine: origin-mine,
                quantity: quantity,
                current-owner: tx-sender,
                current-stage: "mine",
                status: "registered",
                created-at: stacks-block-height,
                gps-latitude: gps-latitude,
                gps-longitude: gps-longitude,
                iot-sensor-id: iot-sensor-id,
                ethical-certificate: false
            }
        )
        (map-set material-history material-id (list))
        (var-set material-counter material-id)
        (ok material-id)
    )
)

(define-public (transfer-material
    (material-id uint)
    (to-participant principal)
    (new-stage (string-ascii 20))
    (gps-latitude (string-ascii 20))
    (gps-longitude (string-ascii 20))
    (verification-hash (string-ascii 64)))
    (let
        (
            (material (unwrap! (map-get? materials material-id) ERR_NOT_FOUND))
            (from-participant-info (unwrap! (map-get? participants tx-sender) ERR_UNAUTHORIZED))
            (to-participant-info (unwrap! (map-get? participants to-participant) ERR_UNAUTHORIZED))
            (transfer-id (+ (var-get transfer-counter) u1))
            (current-history (default-to (list) (map-get? material-history material-id)))
        )
        (asserts! (is-eq (get current-owner material) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (get verified from-participant-info) ERR_UNAUTHORIZED)
        (asserts! (get verified to-participant-info) ERR_UNAUTHORIZED)
        (asserts! (is-valid-stage-transition (get current-stage material) new-stage) ERR_INVALID_STAGE)
        
        (map-set transfers transfer-id
            {
                material-id: material-id,
                from-participant: tx-sender,
                to-participant: to-participant,
                from-stage: (get current-stage material),
                to-stage: new-stage,
                transfer-date: stacks-block-height,
                gps-latitude: gps-latitude,
                gps-longitude: gps-longitude,
                verification-hash: verification-hash,
                verified: true
            }
        )
        
        (map-set materials material-id
            (merge material
                {
                    current-owner: to-participant,
                    current-stage: new-stage,
                    status: "in-transit",
                    gps-latitude: gps-latitude,
                    gps-longitude: gps-longitude
                }
            )
        )
        
        (map-set material-history material-id 
            (unwrap-panic (as-max-len? (append current-history transfer-id) u50))
        )
        
        (var-set transfer-counter transfer-id)
        (ok transfer-id)
    )
)

(define-public (confirm-receipt 
    (material-id uint)
    (gps-latitude (string-ascii 20))
    (gps-longitude (string-ascii 20)))
    (let
        (
            (material (unwrap! (map-get? materials material-id) ERR_NOT_FOUND))
        )
        (asserts! (is-eq (get current-owner material) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status material) "in-transit") ERR_INVALID_STATUS)
        
        (map-set materials material-id
            (merge material
                {
                    status: "received",
                    gps-latitude: gps-latitude,
                    gps-longitude: gps-longitude
                }
            )
        )
        (ok true)
    )
)

(define-public (issue-ethical-certificate (material-id uint))
    (let
        (
            (material (unwrap! (map-get? materials material-id) ERR_NOT_FOUND))
        )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get current-stage material) "export") ERR_INVALID_STAGE)
        (asserts! (is-eq (get status material) "received") ERR_INVALID_STATUS)
        
        (map-set materials material-id
            (merge material { ethical-certificate: true, status: "certified" })
        )
        (ok true)
    )
)

(define-private (is-valid-stage-transition (from-stage (string-ascii 20)) (to-stage (string-ascii 20)))
    (or
        (and (is-eq from-stage "mine") (is-eq to-stage "transport"))
        (and (is-eq from-stage "transport") (is-eq to-stage "refinery"))
        (and (is-eq from-stage "refinery") (is-eq to-stage "export"))
    )
)

(define-read-only (get-material (material-id uint))
    (map-get? materials material-id)
)

(define-read-only (get-participant (participant principal))
    (map-get? participants participant)
)

(define-read-only (get-transfer (transfer-id uint))
    (map-get? transfers transfer-id)
)

(define-read-only (get-material-history (material-id uint))
    (map-get? material-history material-id)
)

(define-read-only (get-material-certificate (material-id uint))
    (match (map-get? materials material-id)
        material (get ethical-certificate material)
        false
    )
)

(define-read-only (get-current-material-count)
    (var-get material-counter)
)

(define-read-only (get-current-transfer-count)
    (var-get transfer-counter)
)

(define-read-only (verify-supply-chain (material-id uint))
    (match (map-get? materials material-id)
        material
        (let
            (
                (history (default-to (list) (map-get? material-history material-id)))
            )
            (and
                (get ethical-certificate material)
                (is-eq (get status material) "certified")
                (> (len history) u0)
            )
        )
        false
    )
)
