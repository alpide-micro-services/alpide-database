INSERT INTO `alpide-accounting`.`coa_ledger_account_group` ( `rid`, `ledger_account_group_name`, `coa_category_id`, `coa_category_group_id`, `date_created`, `updated_by_user_id`, `in_built`, `exchange_rate`, `version`, `country_id`) VALUES ( '0', 'Cost of Goods Sold', '8', '3', '2026-04-24 11:12:24', '0', '1', '0', '0', '0');
INSERT INTO `alpide-accounting`.`coa_ledger_account_group` ( `rid`, `ledger_account_group_name`, `coa_category_id`, `coa_category_group_id`, `date_created`, `updated_by_user_id`, `in_built`, `exchange_rate`, `version`, `country_id`) VALUES ( '0', 'Cost of Goods Sold', '28', '8', '2026-04-24 11:12:24', '0', '1', '0', '0', '103');


-- use prev generate gruop ids bellow. also adjust available account number


INSERT INTO `alpide-accounting`.`coa_ledger_account`
( `account_number`, `accounting_entry`, `coa_category_group_id`, `coa_category_id`, `in_built`, `is_ledger_taxable`, `ledger_account_group_id`, `ledger_account_name`, `rid`, `tax_single_rate_id`, `tax_single_rate_percent`, `updated_by_user_id`, `version`, `is_active`, `ref_ledger_number`, `exchange_rate`, `country_id`)
VALUES
    ( 4015, 'Debit', 1, 5, 1, 0, 7, 'Inventory', 0, 0, 0, 0, 0, NULL, NULL, 0, 0),
    ( 6005, 'Debit', 3, 8, 1, 0, 89, 'Cost of Goods Sold', 0, 0, 0, 0, 0, NULL, NULL, 0, 0),
    ( 4015, 'Debit', 5, 25, 1, 0, 57, 'Inventory', 0, 0, 0, 0, 0, NULL, NULL, 0, 103),
    ( 6005, 'Debit', 8, 28, 1, 0, 90, 'Cost of Goods Sold', 0, 0, 0, 0, 0, NULL, NULL, 0, 103);