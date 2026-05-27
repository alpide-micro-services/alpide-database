
  CREATE TABLE IF NOT EXISTS `alpide-crm`.`crm_email_template` (
      `crm_email_template_id`  BIGINT          NOT NULL AUTO_INCREMENT,
      `rid`                    BIGINT          NOT NULL COMMENT 'relationshipId (multi-tenancy key)',

      `template_name`          VARCHAR(255)    NOT NULL,
      `template_type`          VARCHAR(20)     NOT NULL DEFAULT 'Email' COMMENT 'Email | SMS | WhatsApp',
      `subject`                VARCHAR(512)    NULL     COMMENT 'Only for Email type',
      `body`                   TEXT            NOT NULL,
      `description`            TEXT            NULL     COMMENT 'Internal notes',
      `is_active`              TINYINT         NOT NULL DEFAULT 1 COMMENT '1=Active, 0=Inactive',

      -- Recipients
      `send_to_lead`           TINYINT         NOT NULL DEFAULT 1 COMMENT '1=Yes, 0=No',
      `send_to_employees`      TINYINT         NOT NULL DEFAULT 0 COMMENT '1=Yes, 0=No',
      `send_to_custom`         TINYINT         NOT NULL DEFAULT 0 COMMENT '1=Yes, 0=No',

      -- JSON arrays stored as TEXT
      `send_to_employee_list`  TEXT            NULL COMMENT '[{relEmpId, fullName, email}, ...]',
      `custom_recipients`      TEXT            NULL COMMENT 'Comma-separated email addresses',
      `cc_employee_list`       TEXT            NULL COMMENT '[{relEmpId, fullName, email}, ...]',

      -- Audit
      `created_by_user_id`     BIGINT          NULL,
      `updated_by_user_id`     BIGINT          NULL,
      `date_created`           TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `date_updated`           TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

      PRIMARY KEY (`crm_email_template_id`),
      INDEX `idx_cet_rid`      (`rid`),
      INDEX `idx_cet_type`     (`template_type`),
      INDEX `idx_cet_active`   (`is_active`)

  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    COMMENT='CRM email/SMS/WhatsApp templates used by lead workflows';