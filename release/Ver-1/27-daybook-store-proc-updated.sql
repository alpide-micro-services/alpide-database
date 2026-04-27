USE `alpide-sales`;
CREATE OR REPLACE ALGORITHM = UNDEFINED SQL SECURITY DEFINER
VIEW `daybook_tx_vw` AS

SELECT
    `inv_coa`.`invoice_coa_tx_id`   AS `coa_tx_id`,
    `inv_coa`.`customer_id`         AS `customer_id`,
    0                               AS `supplier_id`,
    `inv_coa`.`invoice_master_id`   AS `tx_master_id`,
    `inv_coa`.`invoice_number`      AS `tx_number`,
    `inv_coa`.`tx_type`             AS `tx_type`,
    `inv_coa`.`amount`              AS `tx_amount`,
    `inv_coa`.`tx_date`             AS `tx_date`,
    `inv_coa`.`date_created`        AS `date_created`,
    `inv_coa`.`date_updated`        AS `date_updated`,
    `inv_coa`.`created_by`          AS `created_by`,
    `inv_coa`.`updated_by`          AS `updated_by`,
    `inv_coa`.`exchange_rate`       AS `exchange_rate`,
    `inv_coa`.`rid`                 AS `rid`,
    `inv_coa`.`accouting_entry`     AS `accounting_entry`,
    `inv_coa`.`tax_name`            AS `tax_name`,
    `inv_coa`.`ledger_account_id`   AS `ledger_account_id`,
    'Sales Invoice'                 AS `transaction_name`
FROM `customer_coa_tx_invoice` `inv_coa`
WHERE (`inv_coa`.`is_inactive` = 0)

UNION ALL

SELECT
    `so_coa`.`sales_order_coa_tx_id`    AS `coa_tx_id`,
    `so_coa`.`customer_id`              AS `customer_id`,
    0                                   AS `supplier_id`,
    `so_coa`.`sales_order_master_id`    AS `tx_master_id`,
    `so_coa`.`so_number`                AS `tx_number`,
    `so_coa`.`tx_type`                  AS `tx_type`,
    `so_coa`.`amount`                   AS `tx_amount`,
    `so_coa`.`tx_date`                  AS `tx_date`,
    `so_coa`.`date_created`             AS `date_created`,
    `so_coa`.`date_updated`             AS `date_updated`,
    `so_coa`.`created_by_user_id`       AS `created_by`,
    `so_coa`.`updated_by_user_id`       AS `updated_by`,
    `so_coa`.`exchange_rate`            AS `exchange_rate`,
    `so_coa`.`rid`                      AS `rid`,
    `so_coa`.`accounting_entry`         AS `accounting_entry`,
    `so_coa`.`tax_name`                 AS `tax_name`,
    `so_coa`.`ledger_account_id`        AS `ledger_account_id`,
    'Sales Order'                       AS `transaction_name`
FROM `customer_coa_tx_sales_order` `so_coa`

UNION ALL

SELECT
    `cp_coa`.`payment_coa_tx_id`    AS `coa_tx_id`,
    `cp_coa`.`customer_id`          AS `customer_id`,
    0                               AS `supplier_id`,
    `cp_coa`.`customer_payment_id`  AS `tx_master_id`,
    `cp_coa`.`payment_number`       AS `tx_number`,
    `cp_coa`.`tx_type`              AS `tx_type`,
    `cp_coa`.`amount`               AS `tx_amount`,
    `cp_coa`.`tx_date`              AS `tx_date`,
    `cp_coa`.`date_created`         AS `date_created`,
    `cp_coa`.`date_updated`         AS `date_updated`,
    `cp_coa`.`created_by_user_id`   AS `created_by`,
    `cp_coa`.`updated_by_user_id`   AS `updated_by`,
    `cp_coa`.`exchange_rate`        AS `exchange_rate`,
    `cp_coa`.`rid`                  AS `rid`,
    `cp_coa`.`accouting_entry`      AS `accounting_entry`,
    NULL                            AS `tax_name`,
    `cp_coa`.`ledger_account_id`    AS `ledger_account_id`,
    'Sales Payment'                 AS `transaction_name`
FROM `customer_coa_tx_payment` `cp_coa`

UNION ALL

SELECT
    `cm_coa`.`credit_memo_coa_tx_id`    AS `coa_tx_id`,
    `cm_coa`.`customer_id`              AS `customer_id`,
    0                                   AS `supplier_id`,
    `cm_coa`.`credit_memo_master_id`    AS `tx_master_id`,
    `cm_coa`.`credit_memo_number`       AS `tx_number`,
    `cm_coa`.`tx_type`                  AS `tx_type`,
    `cm_coa`.`amount`                   AS `tx_amount`,
    `cm_coa`.`tx_date`                  AS `tx_date`,
    `cm_coa`.`date_created`             AS `date_created`,
    `cm_coa`.`date_updated`             AS `date_updated`,
    `cm_coa`.`created_by`               AS `created_by`,
    `cm_coa`.`updated_by`               AS `updated_by`,
    `cm_coa`.`exchange_rate`            AS `exchange_rate`,
    `cm_coa`.`rid`                      AS `rid`,
    `cm_coa`.`accouting_entry`          AS `accounting_entry`,
    `cm_coa`.`tax_name`                 AS `tax_name`,
    `cm_coa`.`ledger_account_id`        AS `ledger_account_id`,
    'Credit Memo'                       AS `transaction_name`
FROM `customer_coa_tx_credit_memo` `cm_coa`

UNION ALL

-- Advance Payment GL entries (Step 1: Debit Cash/Bank, Credit Customer Advances)
SELECT
    `adv_coa`.`advance_payment_coa_tx_id`   AS `coa_tx_id`,
    `adv_coa`.`customer_id`                 AS `customer_id`,
    0                                       AS `supplier_id`,
    `adv_coa`.`advance_payment_id`          AS `tx_master_id`,
    `adv_coa`.`advance_number`              AS `tx_number`,
    `adv_coa`.`tx_type`                     AS `tx_type`,
    `adv_coa`.`amount`                      AS `tx_amount`,
    `adv_coa`.`tx_date`                     AS `tx_date`,
    `adv_coa`.`date_created`                AS `date_created`,
    `adv_coa`.`date_updated`                AS `date_updated`,
    `adv_coa`.`created_by_user_id`          AS `created_by`,
    `adv_coa`.`updated_by_user_id`          AS `updated_by`,
    NULL                                    AS `exchange_rate`,
    `adv_coa`.`rid`                         AS `rid`,
    `adv_coa`.`accouting_entry`             AS `accounting_entry`,
    NULL                                    AS `tax_name`,
    `adv_coa`.`ledger_account_id`           AS `ledger_account_id`,
    'Advance Payment'                       AS `transaction_name`
FROM `customer_coa_tx_advance_payment` `adv_coa`

UNION ALL

-- Refund GL entries
SELECT
    `ref_coa`.`customer_refund_coa_tx_id`   AS `coa_tx_id`,
    `ref_coa`.`customer_id`                 AS `customer_id`,
    0                                       AS `supplier_id`,
    `ref_coa`.`customer_refund_id`          AS `tx_master_id`,
    `ref_coa`.`refund_number`               AS `tx_number`,
    `ref_coa`.`tx_type`                     AS `tx_type`,
    `ref_coa`.`amount`                      AS `tx_amount`,
    `ref_coa`.`tx_date`                     AS `tx_date`,
    `ref_coa`.`date_created`                AS `date_created`,
    NULL                                    AS `date_updated`,
    `ref_coa`.`created_by_user_id`          AS `created_by`,
    NULL                                    AS `updated_by`,
    NULL                                    AS `exchange_rate`,
    `ref_coa`.`rid`                         AS `rid`,
    `ref_coa`.`accouting_entry`             AS `accounting_entry`,
    NULL                                    AS `tax_name`,
    `ref_coa`.`ledger_account_id`           AS `ledger_account_id`,
    'Customer Refund'                       AS `transaction_name`
FROM `customer_refund_coa_tx` `ref_coa`;




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
