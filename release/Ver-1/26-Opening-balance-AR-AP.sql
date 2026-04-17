
-- Customer Opening Balance table
-- Tracks one OB record per customer, linked to a system-generated invoice.
-- GL: DEBIT AR (1100) / CREDIT Opening Balance Equity (3900)

CREATE TABLE IF NOT EXISTS `alpide-sales`.customer_opening_balance (
                                                                       opening_balance_id          BIGINT          NOT NULL AUTO_INCREMENT,
                                                                       version                     INT             NOT NULL DEFAULT 0,
                                                                       rid                         BIGINT          NOT NULL,
                                                                       customer_id                 BIGINT          NOT NULL,
                                                                       customer_name               VARCHAR(255),
    invoice_master_id           BIGINT,
    invoice_number              VARCHAR(100),
    outstanding_balance         DECIMAL(19, 4)  NOT NULL DEFAULT 0,
    currency_code               VARCHAR(10),
    as_of_date                  DATETIME,
    ar_ledger_account_id        BIGINT,          -- GL Account 1100 (AR Control — DEBIT)
    ob_equity_ledger_account_id BIGINT,          -- GL Account 3900 (OB Equity — CREDIT)
    status                      VARCHAR(50)     DEFAULT 'Open',
    is_system_locked            TINYINT         NOT NULL DEFAULT 1,
    remarks                     VARCHAR(500),
    fy_start_date               DATETIME,
    fy_end_date                 DATETIME,
    created_by_user_id          BIGINT,
    updated_by_user_id          BIGINT,
    date_created                DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated                DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (opening_balance_id),

    -- Enforce one OB per customer per relationship
    UNIQUE KEY uq_ob_rid_customer (rid, customer_id),

    INDEX idx_ob_rid             (rid),
    INDEX idx_ob_customer        (rid, customer_id),
    INDEX idx_ob_invoice_master  (invoice_master_id)
    );

-- Dual-ledger COA transaction entries for Customer Opening Balance
-- Two rows per OB record: DEBIT AR (1100) + CREDIT OB Equity (3900)
-- Joined to customer_opening_balance via (opening_balance_id, rid)

CREATE TABLE IF NOT EXISTS `alpide-sales`.customer_coa_tx_opening_balance (
                                                                              ob_coa_tx_id        BIGINT          NOT NULL AUTO_INCREMENT,
                                                                              version             INT             NOT NULL DEFAULT 0,
                                                                              opening_balance_id  BIGINT          NOT NULL,
                                                                              rid                 BIGINT          NOT NULL,
                                                                              customer_id         BIGINT,
                                                                              customer_name       VARCHAR(255),
    invoice_master_id   BIGINT,
    invoice_number      VARCHAR(100),
    ledger_account_id   BIGINT,
    ledger_account_name VARCHAR(255),
    amount              DECIMAL(19, 4)  NOT NULL DEFAULT 0,
    accounting_entry    VARCHAR(10),     -- DEBIT or CREDIT
    tx_type             VARCHAR(100),
    tx_date             DATETIME,
    fy_start_date       DATETIME,
    fy_end_date         DATETIME,
    currency_code       VARCHAR(10),
    exchange_rate       DECIMAL(19, 6)  DEFAULT 1,
    created_by          BIGINT,
    date_created        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (ob_coa_tx_id),

    INDEX idx_ob_coa_ob_id      (opening_balance_id),
    INDEX idx_ob_coa_rid        (rid),
    INDEX idx_ob_coa_customer   (rid, customer_id),

    CONSTRAINT fk_ob_coa_opening_balance
    FOREIGN KEY (opening_balance_id)
    REFERENCES `alpide-sales`.customer_opening_balance (opening_balance_id)
                                                                           ON DELETE CASCADE
    );

-- -----------------------------------------------------------------------------
-- 1. supplier_opening_balance
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `alpide-purchase`.supplier_opening_balance (
                                                                          opening_balance_id          BIGINT          NOT NULL AUTO_INCREMENT,
                                                                          version                     INT             NOT NULL DEFAULT 0,
                                                                          rid                         BIGINT          NOT NULL,
                                                                          supplier_id                 BIGINT          NOT NULL,
                                                                          supplier_name               VARCHAR(255)    NULL,
    purchase_invoice_master_id  BIGINT          NULL,
    invoice_number              VARCHAR(100)    NULL,
    outstanding_balance         DECIMAL(19, 4)  NOT NULL DEFAULT 0,
    currency_code               VARCHAR(10)     NULL,
    as_of_date                  DATETIME        NULL,
    ap_ledger_account_id        BIGINT          NULL,          -- GL Account 2100 (AP Control — CREDIT)
    ob_equity_ledger_account_id BIGINT          NULL,          -- GL Account 3900 (OB Equity — DEBIT)
    status                      VARCHAR(50)     DEFAULT 'Open',
    is_system_locked            TINYINT         NOT NULL DEFAULT 1,
    remarks                     VARCHAR(500)    NULL,
    fy_start_date               DATETIME        NULL,
    fy_end_date                 DATETIME        NULL,
    created_by_user_id          BIGINT          NULL,
    updated_by_user_id          BIGINT          NULL,
    date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,
    date_updated                DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (opening_balance_id),
    UNIQUE KEY uq_ob_rid_supplier (rid, supplier_id),
    INDEX idx_ob_rid      (rid),
    INDEX idx_ob_supplier (rid, supplier_id)
    );

-- -----------------------------------------------------------------------------
-- 2. supplier_coa_tx_opening_balance
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `alpide-purchase`.supplier_coa_tx_opening_balance (
                                                                                 ob_coa_tx_id                BIGINT          NOT NULL AUTO_INCREMENT,
                                                                                 version                     INT             NOT NULL DEFAULT 0,
                                                                                 opening_balance_id          BIGINT          NOT NULL,
                                                                                 rid                         BIGINT          NOT NULL,
                                                                                 supplier_id                 BIGINT          NULL,
                                                                                 supplier_name               VARCHAR(255)    NULL,
    purchase_invoice_master_id  BIGINT          NULL,
    invoice_number              VARCHAR(100)    NULL,
    ledger_account_id           BIGINT          NULL,
    ledger_account_name         VARCHAR(255)    NULL,
    amount                      DECIMAL(19, 4)  NOT NULL DEFAULT 0,
    accounting_entry            VARCHAR(10)     NULL,          -- DEBIT / CREDIT
    tx_type                     VARCHAR(100)    NULL,
    tx_date                     DATETIME        NULL,
    fy_start_date               DATETIME        NULL,
    fy_end_date                 DATETIME        NULL,
    currency_code               VARCHAR(10)     NULL,
    exchange_rate               DECIMAL(19, 6)  DEFAULT 1,
    created_by                  BIGINT          NULL,
    date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,
    date_updated                DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (ob_coa_tx_id),
    INDEX idx_coa_ob_id    (opening_balance_id),
    INDEX idx_coa_rid      (rid),
    INDEX idx_coa_supplier (rid, supplier_id),

    CONSTRAINT fk_coa_opening_balance
    FOREIGN KEY (opening_balance_id)
    REFERENCES `alpide-purchase`.supplier_opening_balance (opening_balance_id)
                                                                          ON DELETE CASCADE
    );
