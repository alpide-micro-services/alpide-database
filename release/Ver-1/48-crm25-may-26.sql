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




       CREATE TABLE IF NOT EXISTS `alpide-crm`.`crm_pulse360_template` (
      `pulse360_template_id`    BIGINT          NOT NULL AUTO_INCREMENT,
      `rid`                     BIGINT          NOT NULL COMMENT 'relationshipId (multi-tenancy key)',

      `template_name`           VARCHAR(255)    NOT NULL,
      `status`                  VARCHAR(20)     NOT NULL DEFAULT 'draft' COMMENT 'active | draft',
  
      -- KPI selection (JSON array of string keys)
      `kpi_ids`                 TEXT            NULL     COMMENT '["total_leads","hot_leads",...]',

      -- Lead stage selection
      `lead_stage_ids`          TEXT            NULL     COMMENT '[leadStatusId, ...]',
      `lead_stages`             TEXT            NULL     COMMENT '[{leadStatusId, statusName}, ...]',

      -- Opportunity stage selection
      `opp_stage_ids`           TEXT            NULL     COMMENT '[opportunityStageId, ...]',
      `opp_stages`              TEXT            NULL     COMMENT '[{opportunityStageId, stageName}, ...]',

      -- Delivery channels (JSON array: ["WA","SMS","Email"])
      `channels`                VARCHAR(100)    NULL,
  
      -- Scheduling
      `trigger_type`            VARCHAR(20)     NULL     COMMENT 'submission | scheduled',
      `schedule_time`           VARCHAR(10)     NULL     COMMENT 'HH:mm — only relevant when trigger_type=scheduled',

      -- Recipients
      `recipient_employee_ids`  TEXT            NULL     COMMENT '[relationshipEmployeeId, ...]',
      `employee_recipients`     TEXT            NULL     COMMENT '[{relationshipEmployeeId, fullName, emailAddress}, ...]',
      `custom_recipients`       TEXT            NULL     COMMENT '[{name, email}, ...]',

      -- Audit
      `created_by_user_id`      BIGINT          NULL,
      `updated_by_user_id`      BIGINT          NULL,
      `date_created`            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `date_updated`            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

      PRIMARY KEY (`pulse360_template_id`),
      INDEX `idx_p360_rid`     (`rid`),
      INDEX `idx_p360_status`  (`status`),
      INDEX `idx_p360_trigger` (`trigger_type`, `schedule_time`)

  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    COMMENT='Pulse360 daily report templates — one row per template per relationship';