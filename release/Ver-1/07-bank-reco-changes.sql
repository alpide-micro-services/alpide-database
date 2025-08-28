ALTER TABLE `alpide-accounting`.`journals_entry_details`
    ADD COLUMN `date_created` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP AFTER `version`;

ALTER TABLE `alpide-accounting`.`relationship_expense`
    CHANGE COLUMN `date_created` `date_created` TIMESTAMP NULL DEFAULT NULL,
    CHANGE COLUMN `date_updated` `date_updated` TIMESTAMP NULL DEFAULT NULL,
    CHANGE COLUMN `expense_date` `expense_date` TIMESTAMP NULL DEFAULT NULL,
    CHANGE COLUMN `fy_end_date` `fy_end_date` TIMESTAMP NULL DEFAULT NULL,
    CHANGE COLUMN `fy_start_date` `fy_start_date` TIMESTAMP NULL DEFAULT NULL;

ALTER TABLE `alpide-users`.relationship_bank_details
    ADD COLUMN account_type VARCHAR(50) DEFAULT null,
  ADD COLUMN currency CHAR(3) DEFAULT NULL,
  ADD COLUMN ledger_account_id BIGINT DEFAULT '0',
  ADD COLUMN ledger_account_name VARCHAR(255) DEFAULT null,
  ADD COLUMN ledger_account_number INT DEFAULT '0';


ALTER TABLE `alpide-purchase`.`supplier_payments`
    ADD COLUMN is_recon BOOLEAN DEFAULT FALSE;


ALTER TABLE `alpide-sales`.`customer_payment`
    ADD COLUMN is_recon BOOLEAN DEFAULT FALSE;

ALTER TABLE `alpide-accounting`.`relationship_expense_payment`
    ADD COLUMN is_recon BOOLEAN DEFAULT FALSE;

ALTER TABLE `alpide-accounting`.`relationship_expense_payment`
    ADD COLUMN `transaction_id` VARCHAR(100) NULL DEFAULT NULL,
ADD COLUMN `institution_name` VARCHAR(150) NULL DEFAULT NULL AFTER `transaction_id`,
ADD COLUMN `payment_channel` VARCHAR(150) NULL DEFAULT NULL AFTER `institution_name`,
ADD COLUMN `merchant_name` VARCHAR(150) NULL DEFAULT NULL AFTER `payment_channel`;


ALTER TABLE `alpide-accounting`.`journals_entry_master`
    ADD COLUMN `transaction_id` VARCHAR(100) NULL DEFAULT NULL,
ADD COLUMN `institution_name` VARCHAR(150) NULL DEFAULT NULL AFTER `transaction_id`,
ADD COLUMN `payment_channel` VARCHAR(150) NULL DEFAULT NULL AFTER `institution_name`,
ADD COLUMN `merchant_name` VARCHAR(150) NULL DEFAULT NULL AFTER `payment_channel`,
ADD COLUMN `is_recon` BOOLEAN DEFAULT FALSE AFTER `merchant_name`;

ALTER TABLE `alpide-purchase`.`supplier_payments`
    CHANGE COLUMN `is_recon` `is_recon` BIT (1) NULL DEFAULT false;


ALTER TABLE `alpide-sales`.`customer_payment`
    CHANGE COLUMN `is_recon` `is_recon` BIT (1) NULL DEFAULT false;

ALTER TABLE `alpide-purchase`.`supplier_payments`
    ADD COLUMN bank_detail_id BIGINT DEFAULT '0';

ALTER TABLE `alpide-sales`.`customer_payment`
    ADD COLUMN bank_detail_id BIGINT DEFAULT '0';

ALTER TABLE `alpide-accounting`.`relationship_expense_payment`
    ADD COLUMN bank_detail_id BIGINT DEFAULT '0';

ALTER TABLE `alpide-accounting`.`journals_entry_master`
    ADD COLUMN bank_detail_id BIGINT DEFAULT '0';
