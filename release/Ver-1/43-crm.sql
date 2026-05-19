ALTER TABLE `alpide-crm`.`crm_lead_status` 
ADD COLUMN `description` TEXT NULL AFTER `user_updated`;
ALTER TABLE `alpide-crm`.`crm_lead_stage_status` 
ADD COLUMN `description` TEXT NULL AFTER `is_active`;
ALTER TABLE `alpide-crm`.`crm_opportunity_stage_v2` 
ADD COLUMN `description` TEXT NULL AFTER `date_updated`;
ALTER TABLE `alpide-crm`.`crm_opportunity_status_v2` 
ADD COLUMN `description` TEXT NULL AFTER `date_updated`;
