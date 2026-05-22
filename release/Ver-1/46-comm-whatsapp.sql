
  CREATE TABLE IF NOT EXISTS whatsapp_setting (
      whatsapp_setting_id   BIGINT         AUTO_INCREMENT PRIMARY KEY,
      rid                   BIGINT         NOT NULL,
      provider              VARCHAR(50)    DEFAULT 'META',
      display_name          VARCHAR(255),
      phone_number_id       VARCHAR(255),
      access_token          TEXT,
      business_account_id   VARCHAR(255),
      webhook_verify_token  VARCHAR(255),
      api_version           VARCHAR(20)    DEFAULT 'v19.0',
      from_phone_number     VARCHAR(50),
      is_active             TINYINT(1)     DEFAULT 1,
      created_by_user_id    BIGINT,
      updated_by_user_id    BIGINT,
      date_created          TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
      date_updated          TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_wa_setting_rid (rid),
      INDEX idx_wa_setting_rid_provider (rid, provider)
  );

  CREATE TABLE IF NOT EXISTS whatsapp_communication_log (
      whatsapp_communication_log_id  BIGINT        AUTO_INCREMENT PRIMARY KEY,
      rid                            BIGINT        NOT NULL,
      module_type                    VARCHAR(50)   NOT NULL,
      module_id                      BIGINT,
      provider                       VARCHAR(50)   NOT NULL DEFAULT 'META',
      from_number                    VARCHAR(50),
      to_number                      VARCHAR(255)  NOT NULL,
      message_type                   VARCHAR(50)   NOT NULL DEFAULT 'TEXT',
      message_content                MEDIUMTEXT,
      media_url                      TEXT,
      media_type                     VARCHAR(50),
      media_caption                  TEXT,
      media_filename                 VARCHAR(255),
      whatsapp_message_id            VARCHAR(255),
      status                         VARCHAR(50)   NOT NULL DEFAULT 'SENT',
      error_message                  TEXT,
      sent_by_user_id                BIGINT,
      date_created                   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
      date_updated                   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_wa_log_rid (rid),
      INDEX idx_wa_log_module (module_type, module_id),
      INDEX idx_wa_log_to_number (to_number(20)),
      INDEX idx_wa_log_status (status)
  );


ALTER TABLE `alpide-crm`.`crm_lead` 
CHANGE COLUMN `date_created` `date_created` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ;
ALTER TABLE `alpide-crm`.`crm_scheduled_activity` 
CHANGE COLUMN `status` `status` VARCHAR(255) NOT NULL DEFAULT 'SCHEDULED' ,
CHANGE COLUMN `priority` `priority` VARCHAR(255) NOT NULL DEFAULT 'MEDIUM' ;
  use `alpide-crm`;
  
  -- ─────────────────────────────────────────────────────────────────────────────
  -- 1. crm_lead_task
  --    has: user_Created (emp id), user_created_name, date_created, date_updated
  --    missing: updated_by_emp_id, updated_by_emp_name
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_task
    ADD COLUMN updated_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL;
  
  -- ─────────────────────────────────────────────────────────────────────────────
  -- 2. crm_lead_notes
  --    has: created_by_emp_id, created_by_emp, updated_by_emp_id, date_created
  --    missing: updated_by_emp_name, date_updated
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_notes
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN date_updated        TIMESTAMP    NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

  -- ─────────────────────────────────────────────────────────────────────────────
  -- 3. crm_reminder
  --    has: created_by_emp_id, created_by_emp_name, date_created, date_updated
  --    missing: updated_by_emp_id, updated_by_emp_name
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_reminder
    ADD COLUMN updated_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL;

  -- ─────────────────────────────────────────────────────────────────────────────
  -- 4. crm_scheduled_activity
  --    has: created_by_emp_id, created_by_emp_name, updated_by_emp_id,
  --         date_created, date_updated
  --    missing: updated_by_emp_name
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_scheduled_activity
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL;

  -- ─────────────────────────────────────────────────────────────────────────────
  -- 5. crm_lead_status
  --    has: created_by_user_id, updated_by_user_id, date_created, date_updated
  --    missing: created_by_name, updated_by_name
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_status
    ADD COLUMN created_by_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN updated_by_name VARCHAR(255) DEFAULT NULL;
  
  -- ─────────────────────────────────────────────────────────────────────────────
  -- 6. crm_lead_stage_status
  --    has: created_by_user_id, updated_by_user_id, date_created, date_updated
  --    missing: created_by_name, updated_by_name
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_stage_status
    ADD COLUMN created_by_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN updated_by_name VARCHAR(255) DEFAULT NULL;

  -- ─────────────────────────────────────────────────────────────────────────────
  -- 7. crm_activity  (old activity table)
  --    has: user_created, user_updated (name strings only), date_created, date_updated
  --    missing: created_by_emp_id, created_by_emp_name, updated_by_emp_id, updated_by_emp_name
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_activity
    ADD COLUMN created_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN created_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN updated_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL;
  
  -- ─────────────────────────────────────────────────────────────────────────────
  -- 8. crm_campaign  
  --    has: user_created, user_updated (name strings only), date_created, date_updated
  --    missing: created_by_emp_id, created_by_emp_name, updated_by_emp_id, updated_by_emp_name
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_campaign
    ADD COLUMN created_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN created_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN updated_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL;

  -- ─────────────────────────────────────────────────────────────────────────────
  -- 9. crm_lead_call_logs
  --    has: created_by_user_id, created_by_user (name), date_created
  --    missing: updated_by_emp_id, updated_by_emp_name, date_updated
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_call_logs
    ADD COLUMN updated_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN date_updated        TIMESTAMP    NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

  -- ─────────────────────────────────────────────────────────────────────────────
  -- 10. crm_lead_status_history
  --     has: changed_by_emp_id, changed_by_emp_name, changed_at, date_created
  --     missing: date_updated
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_status_history
    ADD COLUMN date_updated TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

  -- ─────────────────────────────────────────────────────────────────────────────
  -- 11. crm_lead_bant
  --     has: updated_by_emp_id, date_created, date_updated
  --     missing: created_by_emp_id, created_by_emp_name, updated_by_emp_name
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_bant
    ADD COLUMN created_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN created_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL;

  -- ─────────────────────────────────────────────────────────────────────────────
  -- 12. crm_lead_detail
  --     has: date_created, date_updated  —  missing all created/updated by
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_detail
    ADD COLUMN created_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN created_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN updated_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL;
  
  -- ─────────────────────────────────────────────────────────────────────────────
  -- 13. crm_lead_emp_assigned  —  missing all 4
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_emp_assigned
    ADD COLUMN created_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN created_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN updated_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN date_updated        TIMESTAMP    NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

  -- ─────────────────────────────────────────────────────────────────────────────
  -- 14. crm_lead_team_assigned  —  missing all 4
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_team_assigned
    ADD COLUMN created_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN created_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN date_updated        TIMESTAMP    NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

  -- ─────────────────────────────────────────────────────────────────────────────
  -- 15. crm_lead_source
  --     has: date_created, date_updated  —  missing created/updated by
  -- ─────────────────────────────────────────────────────────────────────────────
  ALTER TABLE `alpide-crm`.crm_lead_source
    ADD COLUMN created_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN created_by_emp_name VARCHAR(255) DEFAULT NULL,
    ADD COLUMN updated_by_emp_id   BIGINT       DEFAULT NULL,
    ADD COLUMN updated_by_emp_name VARCHAR(255) DEFAULT NULL;
