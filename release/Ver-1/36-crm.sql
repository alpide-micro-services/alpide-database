ALTER TABLE `alpide-crm`.`crm_opportunity_v2` 
CHANGE COLUMN `stage_id` `stage_id` INT NULL DEFAULT '1' COMMENT 'FK to opportunity_stage_master' ,
CHANGE COLUMN `status_id` `status_id` INT NULL COMMENT 'FK to opportunity_status_master' ,
CHANGE COLUMN `probability` `probability` TINYINT NULL DEFAULT '30' ,
CHANGE COLUMN `is_closed` `is_closed` TINYINT(1) NULL DEFAULT '0' ,
CHANGE COLUMN `closed_won` `closed_won` TINYINT(1) NULL DEFAULT '0' ;
