ALTER TABLE `alpide-crm`.`crm_lead_task` 
CHANGE COLUMN `date_updated` `date_updated` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ;


  ALTER TABLE `alpide-crm`.crm_lead_bant
      ADD COLUMN created_by_emp_id   BIGINT       NULL AFTER score,
      ADD COLUMN created_by_emp_name VARCHAR(200) NULL AFTER created_by_emp_id,
      ADD COLUMN updated_by_emp_name VARCHAR(200) NULL AFTER updated_by_emp_id;



ALTER TABLE `alpide-crm`.`crm_lead_campaign` 
CHANGE COLUMN `date_created` `date_created` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ,
CHANGE COLUMN `date_updated` `date_updated` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ;

  ALTER TABLE `alpide-crm`.crm_lead_campaign
      ADD COLUMN updated_by_emp_id   BIGINT       NULL,
      ADD COLUMN updated_by_emp_name VARCHAR(255) NULL;