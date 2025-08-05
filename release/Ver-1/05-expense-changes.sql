
ALTER TABLE `alpide-users`.`approvals`
    ADD COLUMN `supplier_id` BIGINT NULL DEFAULT 0 AFTER `customer_id`,
CHANGE COLUMN `approver_deligate_to` `approver_deligate_to` BIGINT NULL DEFAULT 0 ,
CHANGE COLUMN `approver_id` `approver_id` BIGINT NULL DEFAULT 0 ,
CHANGE COLUMN `rid` `rid` BIGINT NULL DEFAULT 0 ,
CHANGE COLUMN `transaction_id` `transaction_id` BIGINT NULL DEFAULT 0 ,
CHANGE COLUMN `approval_workflow_master_id` `approval_workflow_master_id` BIGINT NULL DEFAULT 0 ,
CHANGE COLUMN `customer_id` `customer_id` BIGINT NULL DEFAULT 0 ;

ALTER TABLE `alpide-accounting`.`relationship_expense`
    ADD COLUMN `business_purpose` VARCHAR(255) NULL DEFAULT NULL AFTER `version`;

ALTER TABLE `alpide-accounting`.`relationship_coa_tx_expense`
    ADD COLUMN `expense_category_id` BIGINT NULL DEFAULT '0' AFTER `rid`;

ALTER TABLE `alpide-accounting`.`relationship_expense_category_ref`
    ADD COLUMN `expense_category_name` VARCHAR(255) NULL DEFAULT NULL AFTER `rid`;




CREATE TABLE `alpide-accounting`.`relationship_expense_payment` (
                                                                    `expense_payment_id` bigint NOT NULL AUTO_INCREMENT,
                                                                    `created_by_emp_id` bigint DEFAULT '0',
                                                                    `currency_code` varchar(255) DEFAULT NULL,
                                                                    `date_created` datetime(6) DEFAULT NULL,
                                                                    `description` varchar(255) DEFAULT NULL,
                                                                    `expense_amount` double DEFAULT NULL,
                                                                    `expense_master_id` bigint DEFAULT '0',
                                                                    `expense_number` varchar(255) DEFAULT NULL,
                                                                    `foreign_currency` varchar(255) DEFAULT NULL,
                                                                    `foreign_currency_icon` varchar(255) DEFAULT NULL,
                                                                    `fy_end_date` timestamp NULL DEFAULT NULL,
                                                                    `fy_start_date` timestamp NULL DEFAULT NULL,
                                                                    `institution_name` varchar(255) DEFAULT NULL,
                                                                    `is_active` int DEFAULT NULL,
                                                                    `is_multi_currency` int DEFAULT NULL,
                                                                    `is_xero_uploaded` int DEFAULT NULL,
                                                                    `merchant_name` varchar(255) DEFAULT NULL,
                                                                    `payment_amount` double DEFAULT NULL,
                                                                    `payment_channel` varchar(255) DEFAULT NULL,
                                                                    `payment_date` datetime(6) DEFAULT NULL,
                                                                    `payment_id` bigint DEFAULT NULL,
                                                                    `payment_mode` varchar(255) DEFAULT NULL,
                                                                    `payment_mode_detail` varchar(255) DEFAULT NULL,
                                                                    `payment_mode_name` varchar(255) DEFAULT NULL,
                                                                    `payment_number` varchar(255) DEFAULT NULL,
                                                                    `payment_source` varchar(255) DEFAULT NULL,
                                                                    `po_number` varchar(255) DEFAULT NULL,
                                                                    `project_master_id` bigint DEFAULT NULL,
                                                                    `project_name` varchar(255) DEFAULT NULL,
                                                                    `project_number` varchar(255) DEFAULT NULL,
                                                                    `reference` varchar(255) DEFAULT NULL,
                                                                    `rid` bigint DEFAULT '0',
                                                                    `relationship_name` varchar(255) DEFAULT NULL,
                                                                    `remarks` varchar(1000) DEFAULT NULL,
                                                                    `status` varchar(255) DEFAULT NULL,
                                                                    `status_color` varchar(255) DEFAULT NULL,
                                                                    `template_code` varchar(255) DEFAULT NULL,
                                                                    `transaction_id` varchar(255) DEFAULT NULL,
                                                                    `tx_number` varchar(255) DEFAULT NULL,
                                                                    `tx_type` varchar(255) DEFAULT NULL,
                                                                    `version` int NOT NULL,
                                                                    PRIMARY KEY (`expense_payment_id`)
);
CREATE TABLE `alpide-accounting`.`relationship_expense_coa_tx_payment` (
                                                                           `expense_coa_tx_payment_id` bigint NOT NULL AUTO_INCREMENT,
                                                                           `accouting_entry` varchar(255) DEFAULT NULL,
                                                                           `amount` double DEFAULT NULL,
                                                                           `bank_date` varchar(255) DEFAULT NULL,
                                                                           `created_by_user_id` bigint DEFAULT NULL,
                                                                           `date_created` datetime(6) DEFAULT NULL,
                                                                           `date_updated` datetime(6) DEFAULT NULL,
                                                                           `expense_amount` double DEFAULT NULL,
                                                                           `expense_master_id` bigint DEFAULT NULL,
                                                                           `expense_number` varchar(255) DEFAULT NULL,
                                                                           `expense_payment_id` bigint DEFAULT NULL,
                                                                           `fy_end_date` datetime(6) DEFAULT NULL,
                                                                           `fy_start_date` datetime(6) DEFAULT NULL,
                                                                           `instrument_date` datetime(6) DEFAULT NULL,
                                                                           `ledger_account_id` bigint DEFAULT NULL,
                                                                           `payment_number` varchar(255) DEFAULT NULL,
                                                                           `rid` bigint DEFAULT NULL,
                                                                           `tx_date` datetime(6) DEFAULT NULL,
                                                                           `tx_type` varchar(255) DEFAULT NULL,
                                                                           `updated_by_user_id` bigint DEFAULT NULL,
                                                                           `version` int NOT NULL,
                                                                           PRIMARY KEY (`expense_coa_tx_payment_id`)
);

USE `alpide-accounting`;
CREATE  OR REPLACE
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
    'Business Expense' AS `transaction_name`
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
        JOIN `alpide-accounting`.`coa_ledger_account` `l` ON ((`ep_coa`.`ledger_account_id` = `l`.`ledger_account_id`)));



USE `alpide-accounting`;
DROP function IF EXISTS `current_tx_id`;

USE `alpide-accounting`;
DROP function IF EXISTS `alpide-accounting`.`current_tx_id`;
;

DELIMITER $$
USE `alpide-accounting`$$
CREATE FUNCTION `current_tx_id`(tx_name CHAR(20), rid int(11)) RETURNS int
    DETERMINISTIC
BEGIN

    	DECLARE tx_id_local int;

select count(*) into tx_id_local from alpide_sequence a where a.tx_name = tx_name and a.rid = rid;

if tx_id_local < 1 then
 				INSERT INTO alpide_sequence (`tx_id`, `rid`, `tx_name`) VALUES ('0', rid, tx_name);
END IF;

select a.tx_id into tx_id_local from alpide_sequence a where a.tx_name = tx_name and a.rid = rid;
update alpide_sequence a set a.tx_id = tx_id_local + 1 where a.tx_name = tx_name and a.rid = rid;

select a.tx_id into tx_id_local from alpide_sequence a where a.tx_name = tx_name and a.rid = rid;

RETURN tx_id_local;
END$$

DELIMITER ;
;

CREATE TABLE `alpide-accounting`.`alpide_sequence` (
                                                       `alpide_sequence_id` bigint NOT NULL AUTO_INCREMENT,
                                                       `tx_id` bigint DEFAULT NULL,
                                                       `rid` bigint DEFAULT NULL,
                                                       `tx_name` varchar(45) DEFAULT NULL,
                                                       `version` int NOT NULL DEFAULT '0',
                                                       `tx_name_prefix` varchar(20) DEFAULT NULL,
                                                       PRIMARY KEY (`alpide_sequence_id`)
);

ALTER TABLE `alpide-accounting`.`alpide_sequence`
    CHANGE COLUMN `alpide_sequence_id` `alpide_sequence_id` BIGINT NOT NULL AUTO_INCREMENT ,
    CHANGE COLUMN `version` `version` INT NOT NULL ,
    ADD PRIMARY KEY (`alpide_sequence_id`);
;
ALTER TABLE `alpide-accounting`.`alpide_sequence`
    CHANGE COLUMN `version` `version` INT NOT NULL DEFAULT '0' ;

ALTER TABLE `alpide-accounting`.`expense_category`
    ADD COLUMN `date_created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN `date_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;