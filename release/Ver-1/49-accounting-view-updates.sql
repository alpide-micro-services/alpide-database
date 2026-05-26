USE `alpide-purchase`;
CREATE  OR REPLACE
    ALGORITHM = UNDEFINED
    SQL SECURITY DEFINER
VIEW `alpide-purchase`.`daybook_tx_vw` AS
SELECT
    `po_coa`.`po_coa_tx_id` AS `coa_tx_id`,
    0 AS `customer_id`,
    `po_coa`.`supplier_id` AS `supplier_id`,
    `po_coa`.`po_master_id` AS `tx_master_id`,
    `po_coa`.`supplier_po_number` AS `tx_number`,
    `po_coa`.`tx_type` AS `tx_type`,
    `po_coa`.`amount` AS `tx_amount`,
    `po_coa`.`tx_date` AS `tx_date`,
    `po_coa`.`date_created` AS `date_created`,
    `po_coa`.`date_updated` AS `date_updated`,
    `po_coa`.`created_by` AS `created_by`,
    `po_coa`.`updated_by` AS `updated_by`,
    `po_coa`.`exchange_rate` AS `exchange_rate`,
    `po_coa`.`rid` AS `rid`,
    `po_coa`.`accouting_entry` AS `accounting_entry`,
    `po_coa`.`tax_name` AS `tax_name`,
    `po_coa`.`ledger_account_id` AS `ledger_account_id`,
    'Purchase Order' AS `transaction_name`
FROM
    `alpide-purchase`.`supplier_coa_tx_po` `po_coa`
UNION ALL SELECT
              `pi_coa`.`invoice_coa_tx_id` AS `coa_tx_id`,
              0 AS `customer_id`,
              `pi_coa`.`supplier_id` AS `supplier_id`,
              `pi_coa`.`invoice_master_id` AS `tx_master_id`,
              `pi_coa`.`invoice_number` AS `tx_number`,
              `pi_coa`.`tx_type` AS `tx_type`,
              `pi_coa`.`amount` AS `tx_amount`,
              `pi_coa`.`tx_date` AS `tx_date`,
              `pi_coa`.`date_created` AS `date_created`,
              `pi_coa`.`date_updated` AS `date_updated`,
              `pi_coa`.`created_by` AS `created_by`,
              `pi_coa`.`updated_by` AS `updated_by`,
              `pi_coa`.`exchange_rate` AS `exchange_rate`,
              `pi_coa`.`rid` AS `rid`,
              `pi_coa`.`accouting_entry` AS `accounting_entry`,
              `pi_coa`.`tax_name` AS `tax_name`,
              `pi_coa`.`ledger_account_id` AS `ledger_account_id`,
              'Purchase Invoice' AS `transaction_name`
FROM
    `alpide-purchase`.`supplier_coa_tx_invoice` `pi_coa`
UNION ALL SELECT
              `dm_coa`.`debit_memo_coa_tx_id` AS `coa_tx_id`,
              0 AS `customer_id`,
              `dm_coa`.`supplier_id` AS `supplier_id`,
              `dm_coa`.`debit_memo_master_id` AS `tx_master_id`,
              `dm_coa`.`debit_memo_number` AS `tx_number`,
              `dm_coa`.`tx_type` AS `tx_type`,
              `dm_coa`.`amount` AS `tx_amount`,
              `dm_coa`.`tx_date` AS `tx_date`,
              `dm_coa`.`date_created` AS `date_created`,
              `dm_coa`.`date_updated` AS `date_updated`,
              `dm_coa`.`created_by` AS `created_by`,
              `dm_coa`.`updated_by` AS `updated_by`,
              0 AS `exchange_rate`,
              `dm_coa`.`rid` AS `rid`,
              `dm_coa`.`accouting_entry` AS `accounting_entry`,
              `dm_coa`.`tax_name` AS `tax_name`,
              `dm_coa`.`ledger_account_id` AS `ledger_account_id`,
              'Debit Memo' AS `transaction_name`
FROM
    `alpide-purchase`.`supplier_coa_tx_debit_memo` `dm_coa`
UNION ALL SELECT
              `pp_coa`.`supplier_coa_tx_payment_id` AS `coa_tx_id`,
              0 AS `customer_id`,
              `pp_coa`.`supplier_id` AS `supplier_id`,
              `pp_coa`.`supplier_payment_id` AS `tx_master_id`,
              `pp_coa`.`payment_number` AS `tx_number`,
              `pp_coa`.`tx_type` AS `tx_type`,
              `pp_coa`.`amount` AS `tx_amount`,
              `pp_coa`.`tx_date` AS `tx_date`,
              `pp_coa`.`date_created` AS `date_created`,
              `pp_coa`.`date_updated` AS `date_updated`,
              `pp_coa`.`created_by_user_id` AS `created_by`,
              `pp_coa`.`updated_by_user_id` AS `updated_by`,
              `pp_coa`.`exchange_rate` AS `exchange_rate`,
              `pp_coa`.`rid` AS `rid`,
              `pp_coa`.`accouting_entry` AS `accounting_entry`,
              NULL AS `tax_name`,
              `pp_coa`.`ledger_account_id` AS `ledger_account_id`,
              'Purchase Payment' AS `transaction_name`
FROM
    `alpide-purchase`.`supplier_coa_tx_payment` `pp_coa`
UNION ALL SELECT
              `adv_coa`.`advance_payment_coa_tx_id` AS `coa_tx_id`,
              0 AS `customer_id`,
              `adv_coa`.`supplier_id` AS `supplier_id`,
              `adv_coa`.`advance_payment_id` AS `tx_master_id`,
              `adv_coa`.`advance_number` AS `tx_number`,
              `adv_coa`.`tx_type` AS `tx_type`,
              `adv_coa`.`amount` AS `tx_amount`,
              `adv_coa`.`tx_date` AS `tx_date`,
              `adv_coa`.`date_created` AS `date_created`,
              `adv_coa`.`date_updated` AS `date_updated`,
              `adv_coa`.`created_by_user_id` AS `created_by`,
              `adv_coa`.`updated_by_user_id` AS `updated_by`,
              NULL AS `exchange_rate`,
              `adv_coa`.`rid` AS `rid`,
              `adv_coa`.`accouting_entry` AS `accounting_entry`,
              NULL AS `tax_name`,
              `adv_coa`.`ledger_account_id` AS `ledger_account_id`,
              'Advance Payment' AS `transaction_name`
FROM
    `alpide-purchase`.`supplier_coa_tx_advance_payment` `adv_coa`
UNION ALL SELECT
              `sr_coa`.`supplier_refund_coa_tx_id` AS `coa_tx_id`,
              0 AS `customer_id`,
              `sr_coa`.`supplier_id` AS `supplier_id`,
              `sr_coa`.`supplier_refund_id` AS `tx_master_id`,
              `sr_coa`.`refund_number` AS `tx_number`,
              `sr_coa`.`tx_type` AS `tx_type`,
              `sr_coa`.`amount` AS `tx_amount`,
              `sr_coa`.`tx_date` AS `tx_date`,
              `sr_coa`.`date_created` AS `date_created`,
              NULL AS `date_updated`,
              `sr_coa`.`created_by_user_id` AS `created_by`,
              NULL AS `updated_by`,
              0 AS `exchange_rate`,
              `sr_coa`.`rid` AS `rid`,
              `sr_coa`.`accouting_entry` AS `accounting_entry`,
              NULL AS `tax_name`,
              `sr_coa`.`ledger_account_id` AS `ledger_account_id`,
              'Supplier Refund' AS `transaction_name`
FROM
    `alpide-purchase`.`supplier_refund_coa_tx` `sr_coa`;


USE `alpide-accounting`;
  CREATE OR REPLACE
      ALGORITHM = UNDEFINED
      SQL SECURITY DEFINER
  VIEW `alpide-accounting`.`daybook_tx_vw` AS
SELECT
    `expense`.`expense_coa_tx_id` AS `coa_tx_id`,
    0 AS `customer_id`,
    0 AS `supplier_id`,
    `expense`.`expense_master_id` AS `tx_master_id`,
    `expense`.`expense_number` AS `tx_number`,
    `expense`.`tx_type` AS `tx_type`,
    `expense`.`amount` AS `tx_amount`,
    `expense`.`tx_date` AS `tx_date`,
    `expense`.`date_created` AS `date_created`,
    `expense`.`date_updated` AS `date_updated`,
    `expense`.`created_by` AS `created_by`,
    `expense`.`updated_by` AS `updated_by`,
    `expense`.`exchange_rate` AS `exchange_rate`,
    `expense`.`rid` AS `rid`,
    `expense`.`accouting_entry` AS `accounting_entry`,
    NULL AS `tax_name`,
    `l`.`ledger_account_name` AS `ledger_account_name`,
    `l`.`ledger_account_id` AS `ledger_account_id`,
    'Expense' AS `transaction_name`
FROM
    (`alpide-accounting`.`relationship_coa_tx_expense` `expense`
        JOIN `alpide-accounting`.`coa_ledger_account` `l` ON ((`expense`.`ledger_account_id` = `l`.`ledger_account_id`)))
UNION ALL SELECT
              `journal`.`journal_coa_tx_id` AS `coa_tx_id`,
              0 AS `customer_id`,
              0 AS `supplier_id`,
              `journal`.`journals_entry_master_id` AS `tx_master_id`,
              `journal`.`journal_number` AS `tx_number`,
              `journal`.`tx_type` AS `tx_type`,
              `journal`.`amount` AS `tx_amount`,
              `journal`.`tx_date` AS `tx_date`,
              `journal`.`date_created` AS `date_created`,
              `journal`.`date_updated` AS `date_updated`,
              `journal`.`created_by_user_id` AS `created_by`,
              `journal`.`updated_by_user_id` AS `updated_by`,
              0 AS `exchange_rate`,
              `journal`.`rid` AS `rid`,
              `journal`.`accounting_entry` AS `accounting_entry`,
              NULL AS `tax_name`,
              `l`.`ledger_account_name` AS `ledger_account_name`,
              `l`.`ledger_account_id` AS `ledger_account_id`,
              'Journal' AS `transaction_name`
FROM
    (`alpide-accounting`.`journal_coa_tx` `journal`
        JOIN `alpide-accounting`.`coa_ledger_account` `l` ON ((`journal`.`ledger_account_id` = `l`.`ledger_account_id`)))
UNION ALL SELECT
              `ep_coa`.`expense_coa_tx_payment_id` AS `coa_tx_id`,
              0 AS `customer_id`,
              0 AS `supplier_id`,
              `ep_coa`.`expense_payment_id` AS `tx_master_id`,
              `ep_coa`.`payment_number` AS `tx_number`,
              `ep_coa`.`tx_type` AS `tx_type`,
              `ep_coa`.`amount` AS `tx_amount`,
              `ep_coa`.`tx_date` AS `tx_date`,
              `ep_coa`.`tx_date` AS `date_created`,
              `ep_coa`.`date_updated` AS `date_updated`,
              `ep_coa`.`created_by_user_id` AS `created_by`,
              `ep_coa`.`updated_by_user_id` AS `updated_by`,
              0 AS `exchange_rate`,
              `ep_coa`.`rid` AS `rid`,
              `ep_coa`.`accouting_entry` AS `accounting_entry`,
              NULL AS `tax_name`,
              `l`.`ledger_account_name` AS `ledger_account_name`,
              `l`.`ledger_account_id` AS `ledger_account_id`,
              'Expense Payment' AS `transaction_name`
FROM
    (`alpide-accounting`.`relationship_expense_coa_tx_payment` `ep_coa`
        JOIN `alpide-accounting`.`coa_ledger_account` `l` ON ((`ep_coa`.`ledger_account_id` = `l`.`ledger_account_id`)))
UNION ALL SELECT
              `ob`.`opening_balance_id_coa_tx_id` AS `coa_tx_id`,
              0 AS `customer_id`,
              0 AS `supplier_id`,
              `ob`.`opening_balance_id` AS `tx_master_id`,
              `ob`.`opening_balance_number` AS `tx_number`,
              `ob`.`tx_type` AS `tx_type`,
              `ob`.`amount` AS `tx_amount`,
              `ob`.`tx_date` AS `tx_date`,
              `ob`.`date_created` AS `date_created`,
              `ob`.`date_updated` AS `date_updated`,
              `ob`.`created_by_user_id` AS `created_by`,
              `ob`.`updated_by_user_id` AS `updated_by`,
              0 AS `exchange_rate`,
              `ob`.`rid` AS `rid`,
              `ob`.`accounting_entry` AS `accounting_entry`,
              NULL AS `tax_name`,
              `l`.`ledger_account_name` AS `ledger_account_name`,
              `l`.`ledger_account_id` AS `ledger_account_id`,
              'Opening Balance' AS `transaction_name`
FROM
    (`alpide-accounting`.`finance_opening_balance_coa_tx` `ob`
        JOIN `alpide-accounting`.`coa_ledger_account` `l` ON ((`ob`.`ledger_account_id` = `l`.`ledger_account_id`)));