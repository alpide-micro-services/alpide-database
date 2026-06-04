   ALTER TABLE `alpide-crm`.`crm_lead_source`
       ADD COLUMN  `icon_name` TEXT;

        CREATE TABLE IF NOT EXISTS `alpide-crm`.`account_type_master` (
      `account_type_id`   BIGINT          NOT NULL AUTO_INCREMENT,
      `account_type_name` VARCHAR(255)    NOT NULL,
      `description`       VARCHAR(500)    NULL,
      `rid`               INT             NOT NULL COMMENT 'relationshipId (multi-tenancy key)',
      `in_built`          TINYINT         NOT NULL DEFAULT 0,
      `date_created`      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `date_updated`      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      `user_created`      VARCHAR(150)    NULL,
      `user_updated`      VARCHAR(150)    NULL,
      `deleted_by`        VARCHAR(150)    NULL,
      `is_deleted`        TINYINT         NOT NULL DEFAULT 0,

      PRIMARY KEY (`account_type_id`),
      INDEX `idx_account_type_rid` (`rid`),
      INDEX `idx_account_type_deleted` (`is_deleted`)

  );