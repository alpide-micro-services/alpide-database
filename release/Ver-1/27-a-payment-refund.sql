-- Customer Refund master table
CREATE TABLE IF NOT EXISTS `alpide-sales`.customer_refund (
                                                              customer_refund_id          BIGINT          NOT NULL AUTO_INCREMENT,
                                                              version                     INT             NOT NULL DEFAULT 0,
                                                              rid                         BIGINT          NOT NULL,
                                                              customer_id                 BIGINT          NOT NULL,
                                                              customer_name               VARCHAR(255),
    refund_date                 DATETIME,
    amount                      DECIMAL(19, 4),
    refund_source               VARCHAR(50),
    credit_memo_id              BIGINT,
    advance_payment_id          BIGINT,
    payment_mode_id             BIGINT,
    payment_mode_name           VARCHAR(100),
    payment_mode_details        VARCHAR(255),
    chart_of_account_details_id BIGINT,
    ledger_account_name         VARCHAR(255),
    refund_number               VARCHAR(100),
    reference_no                VARCHAR(100),
    remarks                     TEXT,
    status                      VARCHAR(50)     DEFAULT 'OPEN',
    fy_start_date               DATETIME,
    fy_end_date                 DATETIME,
    created_by_user_id          BIGINT,
    date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (customer_refund_id),
    INDEX idx_cr_rid             (rid),
    INDEX idx_cr_customer        (rid, customer_id)
    );

-- GL journal entries for each refund
CREATE TABLE IF NOT EXISTS `alpide-sales`.customer_refund_coa_tx (
                                                                     customer_refund_coa_tx_id   BIGINT          NOT NULL AUTO_INCREMENT,
                                                                     version                     INT             NOT NULL DEFAULT 0,
                                                                     customer_refund_id          BIGINT          NOT NULL,
                                                                     rid                         BIGINT          NOT NULL,
                                                                     customer_id                 BIGINT,
                                                                     ledger_account_id           BIGINT,
                                                                     ledger_account_name         VARCHAR(255),
    amount                      DECIMAL(19, 4),
    tx_type                     VARCHAR(100),
    accouting_entry             VARCHAR(10),
    payment_mode                VARCHAR(100),
    payment_mode_id             BIGINT,
    tx_date                     DATETIME,
    refund_number               VARCHAR(100),
    fy_start_date               DATETIME,
    fy_end_date                 DATETIME,
    created_by_user_id          BIGINT,
    date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (customer_refund_coa_tx_id),
    INDEX idx_rcoa_rid           (rid),
    INDEX idx_rcoa_refund        (customer_refund_id),

    CONSTRAINT fk_refund_coa_tx
    FOREIGN KEY (customer_refund_id)
    REFERENCES `alpide-sales`.customer_refund (customer_refund_id)
    ON DELETE CASCADE
    );

-- Add refund reference columns to existing source document tables
ALTER TABLE `alpide-sales`.customer_credit_memo_applied
    ADD COLUMN customer_refund_id BIGINT      NULL,
    ADD COLUMN refund_number      VARCHAR(100) NULL;

ALTER TABLE `alpide-sales`.customer_advance_utilization
    ADD COLUMN customer_refund_id BIGINT      NULL,
    ADD COLUMN refund_number      VARCHAR(100) NULL;


-- ============================================================
-- Supplier Refund DDL
-- ============================================================

USE `alpide-purchase`;

-- ============================================================
-- 1. supplier_refund
-- ============================================================
CREATE TABLE IF NOT EXISTS `alpide-purchase`.supplier_refund (
                                                                 supplier_refund_id          BIGINT          NOT NULL AUTO_INCREMENT,
                                                                 version                     INT             NOT NULL DEFAULT 0,
                                                                 rid                         BIGINT          NOT NULL,
                                                                 supplier_id                 BIGINT          NULL,
                                                                 supplier_name               VARCHAR(255)    NULL,
    refund_date                 DATETIME        NULL,
    amount                      DECIMAL(19,4)   NULL,
    refund_source               VARCHAR(50)     NULL,       -- 'debitMemo' or 'advancePayment'
    debit_memo_id               BIGINT          NULL,
    advance_payment_id          BIGINT          NULL,
    payment_mode_id             BIGINT          NULL,
    payment_mode_name           VARCHAR(100)    NULL,
    payment_mode_details        VARCHAR(500)    NULL,
    chart_of_account_details_id BIGINT          NULL,
    ledger_account_name         VARCHAR(255)    NULL,
    refund_number               VARCHAR(100)    NULL,
    reference_no                VARCHAR(100)    NULL,
    remarks                     VARCHAR(1000)   NULL,
    status                      VARCHAR(50)     NULL,       -- 'open', 'cancelled'
    fy_start_date               DATETIME        NULL,
    fy_end_date                 DATETIME        NULL,
    created_by_user_id          BIGINT          NULL,
    date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (supplier_refund_id),
    INDEX idx_sr_rid            (rid),
    INDEX idx_sr_supplier       (rid, supplier_id),
    INDEX idx_sr_debit_memo     (rid, debit_memo_id)
    );

-- ============================================================
-- 2. supplier_refund_coa_tx  (GL journal entries)
-- ============================================================
CREATE TABLE IF NOT EXISTS `alpide-purchase`.supplier_refund_coa_tx (
                                                                        supplier_refund_coa_tx_id   BIGINT          NOT NULL AUTO_INCREMENT,
                                                                        version                     INT             NOT NULL DEFAULT 0,
                                                                        supplier_refund_id          BIGINT          NOT NULL,
                                                                        rid                         BIGINT          NOT NULL,
                                                                        supplier_id                 BIGINT          NULL,
                                                                        ledger_account_id           BIGINT          NULL,
                                                                        ledger_account_name         VARCHAR(255)    NULL,
    amount                      DECIMAL(19,4)   NULL,
    tx_type                     VARCHAR(100)    NULL,
    accouting_entry             VARCHAR(10)     NULL,       -- 'DEBIT' or 'CREDIT' (intentional typo matches codebase)
    payment_mode                VARCHAR(100)    NULL,
    payment_mode_id             BIGINT          NULL,
    tx_date                     DATETIME        NULL,
    refund_number               VARCHAR(100)    NULL,
    fy_start_date               DATETIME        NULL,
    fy_end_date                 DATETIME        NULL,
    created_by_user_id          BIGINT          NULL,
    date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (supplier_refund_coa_tx_id),
    INDEX idx_srct_refund_id    (supplier_refund_id),
    INDEX idx_srct_rid          (rid),

    CONSTRAINT fk_srct_supplier_refund
    FOREIGN KEY (supplier_refund_id)
    REFERENCES `alpide-purchase`.supplier_refund (supplier_refund_id)
    ON DELETE CASCADE
    );

-- ============================================================
-- 3. Extend supplier_debit_memo_applied to track refund usage.
--    supplier_refund_id / refund_number are NULL for normal
--    invoice-payment applications and populated only when the
--    row is created by a supplier refund.
-- ============================================================
ALTER TABLE `alpide-purchase`.supplier_debit_memo_applied
    ADD COLUMN supplier_refund_id  BIGINT       NULL AFTER created_by_emp_id,
    ADD COLUMN refund_number       VARCHAR(100) NULL AFTER supplier_refund_id,
    ADD INDEX idx_sdma_refund (supplier_refund_id);

-- If columns already exist but were created NOT NULL, fix them:
ALTER TABLE `alpide-purchase`.supplier_debit_memo_applied
    MODIFY COLUMN supplier_refund_id  BIGINT       NULL,
    MODIFY COLUMN refund_number       VARCHAR(100) NULL;
