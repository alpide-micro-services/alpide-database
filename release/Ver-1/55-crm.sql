   
    ALTER TABLE `alpide-crm`.`crm_workflow_trigger_one`
       ADD COLUMN  `email_template_id`   BIGINT       NULL    COMMENT 'FK → crm_email_template.crm_email_template_id',
       ADD COLUMN  `email_template_name` VARCHAR(255) NULL    COMMENT 'Denormalised template name for display',
       ADD COLUMN `calendar_connected`  TINYINT      NOT NULL DEFAULT 0 COMMENT '1 = Google Calendar connected for meetingLinkStage';
  
   -- ── crm_workflow_master: add CRM-standard audit columns ─────────────────────
  
   ALTER TABLE `alpide-crm`.`crm_workflow_master`
       ADD COLUMN  `created_by_user_id` BIGINT    NULL,
       ADD COLUMN  `updated_by_user_id` BIGINT    NULL,
       ADD COLUMN  `date_created`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       ADD COLUMN  `date_updated`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
