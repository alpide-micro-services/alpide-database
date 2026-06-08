
   ALTER TABLE `alpide-crm`.`crm_config`
       ADD COLUMN `excluded_lead_status_ids` TEXT        NULL
           COMMENT 'Comma-separated leadStatusIds excluded from the Active Leads count'
           AFTER `stale_days_for_lead`,
       ADD COLUMN  `default_lead_stage_id`    BIGINT      NULL
           COMMENT 'leadStatusId of the default stage for new leads'
           AFTER `excluded_lead_status_ids`,
       ADD COLUMN  `default_lead_status_id`   BIGINT      NULL
          COMMENT 'leadStatusId of the default sub-status for new leads'
           AFTER `default_lead_stage_id`,
       ADD COLUMN  `default_opp_stage_id`     BIGINT      NULL
           COMMENT 'opportunityStageId of the default stage for new opportunities'
           AFTER `default_lead_status_id`,
       ADD COLUMN  `default_opp_status_id`    BIGINT      NULL
           COMMENT 'opportunityStatusId of the default status for new opportunities'
           AFTER `default_opp_stage_id`;

                        ALTER TABLE `alpide-crm`.`crm_workflow_master`
      ADD COLUMN  `source_id`   INT          NOT NULL DEFAULT 0,
      ADD COLUMN  `source_name` VARCHAR(255) NULL;

              ALTER TABLE `alpide-crm`.crm_manual_communication_log
       ADD COLUMN date_updated TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP;