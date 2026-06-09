
ALTER TABLE `alpide-crm`.crm_google_calendar_connection
ADD COLUMN relationship_impl_id BIGINT NULL;
ALTER TABLE `alpide-crm`.crm_meeting 
ADD COLUMN relationship_impl_id BIGINT NULL;

ALTER TABLE `alpide-crm`.crm_google_calendar_settings 
ADD COLUMN relationship_impl_id BIGINT NULL;



ALTER TABLE `alpide-crm`.crm_google_calendar_settings
ADD UNIQUE KEY UK_rel_impl (relationship_id, relationship_impl_id);

ALTER TABLE `alpide-crm`.`crm_google_calendar_settings` 
DROP INDEX `uq_relationship_id` ;
;
ALTER TABLE `alpide-crm`.crm_meeting ADD COLUMN reminder_sent_1hour TINYINT(1) DEFAULT 0;

ALTER TABLE `alpide-crm`.`crm_google_calendar_connection` 
DROP INDEX `uq_relationship_id` ;
;
