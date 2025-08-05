ALTER TABLE `alpide-accounting`.`finance_opening_balance_coa_tx`
ADD COLUMN `import_batch_id` VARCHAR(45) NULL DEFAULT NULL AFTER `version`;

ALTER TABLE `alpide-accounting`.`finance_opening_balance_coa_tx`
ADD COLUMN `source_system` VARCHAR(45) NULL DEFAULT NULL AFTER `import_batch_id`;


ALTER TABLE `alpide-accounting`.`financial_year`
ADD COLUMN `closed_by_emp_id` INT NULL DEFAULT '0' AFTER `version`,
ADD COLUMN  fy_closed_date TIMESTAMP DEFAULT NULL,
ADD COLUMN  is_fy_closed int DEFAULT '0',
 ADD COLUMN  closed_by_emp_name VARCHAR(255) DEFAULT NULL;


ALTER TABLE `alpide-accounting`.`relationship_expense`
CHANGE COLUMN `cost_center_id` `cost_center_id` BIGINT NULL DEFAULT '0' ,
CHANGE COLUMN `created_by_user_id` `created_by_user_id` BIGINT NULL DEFAULT '0' ,
CHANGE COLUMN `date_created` `date_created` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
CHANGE COLUMN `date_updated` `date_updated` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP ,
CHANGE COLUMN `expense_date` `expense_date` TIMESTAMP NULL DEFAULT NULL ,
CHANGE COLUMN `total_amount` `total_amount` DOUBLE NULL DEFAULT '0' ,
CHANGE COLUMN `fy_end_date` `fy_end_date` TIMESTAMP NULL DEFAULT NULL ,
CHANGE COLUMN `fy_start_date` `fy_start_date` TIMESTAMP NULL DEFAULT NULL ,
CHANGE COLUMN `ledger_account_details_id` `ledger_account_details_id` BIGINT NULL DEFAULT '0' ,
CHANGE COLUMN `payment_mode_id` `payment_mode_id` BIGINT NULL DEFAULT '0' ,
CHANGE COLUMN `rid` `rid` BIGINT NULL DEFAULT '0' ,
CHANGE COLUMN `updated_by_user_id` `updated_by_user_id` BIGINT NULL DEFAULT '0' ,
CHANGE COLUMN `project_master_id` `project_master_id` INT NULL DEFAULT '0' ;


ALTER TABLE `alpide-accounting`.`relationship_expense_details`
CHANGE COLUMN `date_created` `date_created` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ,
CHANGE COLUMN `date_updated` `date_updated` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP  ;

ALTER TABLE `alpide-accounting`.`relationship_expense_details`
CHANGE COLUMN `coa_ledger_account_id` `coa_ledger_account_id` BIGINT NULL DEFAULT '0' ,
CHANGE COLUMN `created_by_user_id` `created_by_user_id` BIGINT NULL DEFAULT '0' ,
CHANGE COLUMN `expense_desc` `expense_desc` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `expense_type_id` `expense_type_id` BIGINT NULL DEFAULT '0' ,
CHANGE COLUMN `updated_by_user_id` `updated_by_user_id` BIGINT NULL DEFAULT '0' ;


ALTER TABLE `alpide-inventory`.`wms_storage_bin`
DROP COLUMN `is_barcode_genrated`;

ALTER TABLE `alpide-inventory`.`wms_storage_bin`
ADD COLUMN `is_barcode_genrated` TINYINT NULL DEFAULT 0 AFTER `warehouse_name`;
