
ALTER TABLE `alpide-crm`.`crm_account` 
DROP INDEX `account_code_UNIQUE` ;
;
ALTER TABLE `alpide-crm`.`crm_opportunity_v2` 
DROP INDEX `opportunity_code` ;
;
ALTER TABLE `alpide-sales`.`customer_sales_quotation_master`
  ADD COLUMN `opportunity_id`   BIGINT       NULL DEFAULT NULL,
  ADD COLUMN `opportunity_name` VARCHAR(255) NULL DEFAULT NULL,
  ADD COLUMN `crm_lead_id`      BIGINT       NULL DEFAULT NULL,
  ADD COLUMN `lead_name`        VARCHAR(255) NULL DEFAULT NULL,
  ADD COLUMN `crm_account_id`   BIGINT       NULL DEFAULT NULL;



  ALTER TABLE `alpide-crm`.`crm_scheduled_activity` 
CHANGE COLUMN `activity_type` `activity_type` VARCHAR(255) NOT NULL ;
