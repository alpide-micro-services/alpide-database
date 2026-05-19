-- ============================================================
-- Supplier Advance Payment DDL
-- ============================================================

USE `alpide-purchase`;

-- ============================================================
-- 1. supplier_advance_payment
-- ============================================================
CREATE TABLE IF NOT EXISTS `alpide-purchase`.supplier_advance_payment (
                                                                          advance_payment_id          BIGINT          NOT NULL AUTO_INCREMENT,
                                                                          version                     INT             NOT NULL DEFAULT 0,
                                                                          rid                         BIGINT          NOT NULL,
                                                                          supplier_id                 BIGINT          NULL,
                                                                          supplier_name               VARCHAR(255)    NULL,
    advance_amount              DECIMAL(19,4)   NOT NULL DEFAULT 0,
    utilized_amount             DECIMAL(19,4)   NOT NULL DEFAULT 0,
    balance_amount              DECIMAL(19,4)   NOT NULL DEFAULT 0,
    payment_date                DATETIME        NULL,
    payment_mode_id             BIGINT          NULL,
    payment_mode_name           VARCHAR(100)    NULL,
    payment_mode_detail         VARCHAR(500)    NULL,
    advance_number              VARCHAR(100)    NULL,
    reference_no                VARCHAR(100)    NULL,
    description                 VARCHAR(1000)   NULL,
    remarks                     VARCHAR(1000)   NULL,
    status                      VARCHAR(50)     NULL,       -- OPEN, PARTIALLY_UTILIZED, FULLY_UTILIZED, CANCELLED
    currency_code               VARCHAR(20)     NULL,
    foreign_currency            VARCHAR(20)     NULL,
    foreign_currency_icon       VARCHAR(20)     NULL,
    is_multi_currency           INT             DEFAULT 0,
    transaction_id              VARCHAR(255)    NULL,
    payment_source              VARCHAR(100)    NULL,
    cash_ledger_account_id      BIGINT          NULL,
    advance_ledger_account_id   BIGINT          NULL,
    fy_start_date               DATETIME        NULL,
    fy_end_date                 DATETIME        NULL,
    created_by_user_id          BIGINT          NULL,
    updated_by_user_id          BIGINT          NULL,
    date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,
    date_updated                DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (advance_payment_id),
    INDEX idx_sap_rid               (rid),
    INDEX idx_sap_supplier          (rid, supplier_id),
    INDEX idx_sap_status            (rid, status),
    INDEX idx_sap_payment_date      (rid, payment_date)
    );

-- ============================================================
-- 2. supplier_coa_tx_advance_payment (GL journal entries)
-- ============================================================
CREATE TABLE IF NOT EXISTS `alpide-purchase`.supplier_coa_tx_advance_payment (
                                                                                 advance_payment_coa_tx_id   BIGINT          NOT NULL AUTO_INCREMENT,
                                                                                 version                     INT             NOT NULL DEFAULT 0,
                                                                                 advance_payment_id          BIGINT          NOT NULL,
                                                                                 rid                         BIGINT          NOT NULL,
                                                                                 supplier_id                 BIGINT          NULL,
                                                                                 supplier_name               VARCHAR(255)    NULL,
    tx_type                     VARCHAR(100)    NULL,
    tx_date                     DATETIME        NULL,
    advance_number              VARCHAR(100)    NULL,
    ledger_account_id           BIGINT          NULL,
    amount                      DECIMAL(19,4)   NULL,
    accouting_entry             VARCHAR(10)     NULL,       -- DEBIT or CREDIT
    payment_mode                VARCHAR(100)    NULL,
    payment_mode_id             BIGINT          NULL,
    payment_mode_detail         VARCHAR(500)    NULL,
    instrument_no               VARCHAR(100)    NULL,
    instrument_date             DATETIME        NULL,
    bank_date                   DATETIME        NULL,
    remarks                     VARCHAR(1000)   NULL,
    fy_start_date               DATETIME        NULL,
    fy_end_date                 DATETIME        NULL,
    created_by_user_id          BIGINT          NULL,
    updated_by_user_id          BIGINT          NULL,
    date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,
    date_updated                DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (advance_payment_coa_tx_id),
    INDEX idx_scta_advance          (advance_payment_id, rid),

    CONSTRAINT fk_scta_advance_payment
    FOREIGN KEY (advance_payment_id)
    REFERENCES `alpide-purchase`.supplier_advance_payment (advance_payment_id)
                                                                          ON DELETE CASCADE
    );

-- ============================================================
-- 3. supplier_advance_utilization
-- ============================================================
CREATE TABLE IF NOT EXISTS `alpide-purchase`.supplier_advance_utilization (
                                                                              utilization_id              BIGINT          NOT NULL AUTO_INCREMENT,
                                                                              version                     INT             NOT NULL DEFAULT 0,
                                                                              advance_payment_id          BIGINT          NOT NULL,
                                                                              rid                         BIGINT          NOT NULL,
                                                                              supplier_id                 BIGINT          NULL,
                                                                              invoice_master_id           BIGINT          NULL,
                                                                              invoice_number              VARCHAR(100)    NULL,
    applied_amount              DECIMAL(19,4)   NOT NULL DEFAULT 0,
    application_date            DATETIME        NULL,
    supplier_payment_id         BIGINT          NULL,
    advance_number              VARCHAR(100)    NULL,
    created_by_user_id          BIGINT          NULL,
    supplier_refund_id          BIGINT          NULL,
    refund_number               VARCHAR(100)    NULL,
    date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (utilization_id),
    INDEX idx_sau_advance           (advance_payment_id, rid),
    INDEX idx_sau_invoice           (rid, invoice_master_id),

    CONSTRAINT fk_sau_advance_payment
    FOREIGN KEY (advance_payment_id)
    REFERENCES `alpide-purchase`.supplier_advance_payment (advance_payment_id)
    ON DELETE CASCADE
    );



USE `alpide-purchase`;

  CREATE OR REPLACE ALGORITHM = UNDEFINED SQL SECURITY DEFINER
  VIEW `alpide-purchase`.`daybook_tx_vw` AS

SELECT
    `po_coa`.`po_coa_tx_id`          AS `coa_tx_id`,
    0                                 AS `customer_id`,
    `po_coa`.`supplier_id`            AS `supplier_id`,
    `po_coa`.`po_master_id`           AS `tx_master_id`,
    `po_coa`.`supplier_po_number`     AS `tx_number`,
    `po_coa`.`tx_type`                AS `tx_type`,
    `po_coa`.`amount`                 AS `tx_amount`,
    `po_coa`.`tx_date`                AS `tx_date`,
    `po_coa`.`date_created`           AS `date_created`,
    `po_coa`.`date_updated`           AS `date_updated`,
    `po_coa`.`created_by`             AS `created_by`,
    `po_coa`.`updated_by`             AS `updated_by`,
    `po_coa`.`exchange_rate`          AS `exchange_rate`,
    `po_coa`.`rid`                    AS `rid`,
    `po_coa`.`accouting_entry`        AS `accounting_entry`,
    `po_coa`.`tax_name`               AS `tax_name`,
    `po_coa`.`ledger_account_id`      AS `ledger_account_id`,
    'Purchase Order'                  AS `transaction_name`
FROM `alpide-purchase`.`supplier_coa_tx_po` `po_coa`

UNION ALL

SELECT
    `pi_coa`.`invoice_coa_tx_id`      AS `coa_tx_id`,
    0                                 AS `customer_id`,
    `pi_coa`.`supplier_id`            AS `supplier_id`,
    `pi_coa`.`invoice_master_id`      AS `tx_master_id`,
    `pi_coa`.`invoice_number`         AS `tx_number`,
    `pi_coa`.`tx_type`                AS `tx_type`,
    `pi_coa`.`amount`                 AS `tx_amount`,
    `pi_coa`.`tx_date`                AS `tx_date`,
    `pi_coa`.`date_created`           AS `date_created`,
    `pi_coa`.`date_updated`           AS `date_updated`,
    `pi_coa`.`created_by`             AS `created_by`,
    `pi_coa`.`updated_by`             AS `updated_by`,
    `pi_coa`.`exchange_rate`          AS `exchange_rate`,
    `pi_coa`.`rid`                    AS `rid`,
    `pi_coa`.`accouting_entry`        AS `accounting_entry`,
    `pi_coa`.`tax_name`               AS `tax_name`,
    `pi_coa`.`ledger_account_id`      AS `ledger_account_id`,
    'Purchase Invoice'                AS `transaction_name`
FROM `alpide-purchase`.`supplier_coa_tx_invoice` `pi_coa`

UNION ALL

SELECT
    `dm_coa`.`debit_memo_coa_tx_id`   AS `coa_tx_id`,
    0                                 AS `customer_id`,
    `dm_coa`.`supplier_id`            AS `supplier_id`,
    `dm_coa`.`debit_memo_master_id`   AS `tx_master_id`,
    `dm_coa`.`debit_memo_number`      AS `tx_number`,
    `dm_coa`.`tx_type`                AS `tx_type`,
    `dm_coa`.`amount`                 AS `tx_amount`,
    `dm_coa`.`tx_date`                AS `tx_date`,
    `dm_coa`.`date_created`           AS `date_created`,
    `dm_coa`.`date_updated`           AS `date_updated`,
    `dm_coa`.`created_by`             AS `created_by`,
    `dm_coa`.`updated_by`             AS `updated_by`,
    0                                 AS `exchange_rate`,
    `dm_coa`.`rid`                    AS `rid`,
    `dm_coa`.`accouting_entry`        AS `accounting_entry`,
    `dm_coa`.`tax_name`               AS `tax_name`,
    `dm_coa`.`ledger_account_id`      AS `ledger_account_id`,
    'Debit Memo'                      AS `transaction_name`
FROM `alpide-purchase`.`supplier_coa_tx_debit_memo` `dm_coa`

UNION ALL

SELECT
    `pp_coa`.`supplier_coa_tx_payment_id` AS `coa_tx_id`,
    0                                     AS `customer_id`,
    `pp_coa`.`supplier_id`                AS `supplier_id`,
    `pp_coa`.`supplier_payment_id`        AS `tx_master_id`,
    `pp_coa`.`payment_number`             AS `tx_number`,
    `pp_coa`.`tx_type`                    AS `tx_type`,
    `pp_coa`.`amount`                     AS `tx_amount`,
    `pp_coa`.`tx_date`                    AS `tx_date`,
    `pp_coa`.`date_created`               AS `date_created`,
    `pp_coa`.`date_updated`               AS `date_updated`,
    `pp_coa`.`created_by_user_id`         AS `created_by`,
    `pp_coa`.`updated_by_user_id`         AS `updated_by`,
    `pp_coa`.`exchange_rate`              AS `exchange_rate`,
    `pp_coa`.`rid`                        AS `rid`,
    `pp_coa`.`accouting_entry`            AS `accounting_entry`,
    NULL                                  AS `tax_name`,
    `pp_coa`.`ledger_account_id`          AS `ledger_account_id`,
    'Purchase Payment'                    AS `transaction_name`
FROM `alpide-purchase`.`supplier_coa_tx_payment` `pp_coa`

UNION ALL

SELECT
    `adv_coa`.`advance_payment_coa_tx_id` AS `coa_tx_id`,
    0                                     AS `customer_id`,
    `adv_coa`.`supplier_id`               AS `supplier_id`,
    `adv_coa`.`advance_payment_id`        AS `tx_master_id`,
    `adv_coa`.`advance_number`            AS `tx_number`,
    `adv_coa`.`tx_type`                   AS `tx_type`,
    `adv_coa`.`amount`                    AS `tx_amount`,
    `adv_coa`.`tx_date`                   AS `tx_date`,
    `adv_coa`.`date_created`              AS `date_created`,
    `adv_coa`.`date_updated`              AS `date_updated`,
    `adv_coa`.`created_by_user_id`        AS `created_by`,
    `adv_coa`.`updated_by_user_id`        AS `updated_by`,
    NULL                                  AS `exchange_rate`,
    `adv_coa`.`rid`                       AS `rid`,
    `adv_coa`.`accouting_entry`           AS `accounting_entry`,
    NULL                                  AS `tax_name`,
    `adv_coa`.`ledger_account_id`         AS `ledger_account_id`,
    'Advance Payment'                     AS `transaction_name`
FROM `alpide-purchase`.`supplier_coa_tx_advance_payment` `adv_coa`

UNION ALL

SELECT
    `sr_coa`.`supplier_refund_coa_tx_id` AS `coa_tx_id`,
    0                                    AS `customer_id`,
    `sr_coa`.`supplier_id`               AS `supplier_id`,
    `sr_coa`.`supplier_refund_id`        AS `tx_master_id`,
    `sr_coa`.`refund_number`             AS `tx_number`,
    `sr_coa`.`tx_type`                   AS `tx_type`,
    `sr_coa`.`amount`                    AS `tx_amount`,
    `sr_coa`.`tx_date`                   AS `tx_date`,
    `sr_coa`.`date_created`              AS `date_created`,
    NULL                                 AS `date_updated`,
    `sr_coa`.`created_by_user_id`        AS `created_by`,
    NULL                                 AS `updated_by`,
    0                                    AS `exchange_rate`,
    `sr_coa`.`rid`                       AS `rid`,
    `sr_coa`.`accouting_entry`           AS `accounting_entry`,
    NULL                                 AS `tax_name`,
    `sr_coa`.`ledger_account_id`         AS `ledger_account_id`,
    'Supplier Refund'                    AS `transaction_name`
FROM `alpide-purchase`.`supplier_refund_coa_tx` `sr_coa`;