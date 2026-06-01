-- ─────────────────────────────────────────────────────────────────────────────
-- CRM Address Table
-- Mirrors bo_location fields; owned by the CRM service.
-- Links to leads, opportunities, and accounts via nullable FK columns.
-- Run once on the alpide-crm schema (ddl-auto: none — manual migration).
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `alpide-crm`.`crm_address` (
    `address_id`        BIGINT          NOT NULL AUTO_INCREMENT,
    `rid`               BIGINT          NOT NULL COMMENT 'relationshipId (multi-tenancy key)',

    -- Parent references (at most one should be set per row)
    `lead_id`           BIGINT          NULL,
    `opportunity_id`    BIGINT          NULL,
    `account_id`        BIGINT          NULL,

    -- Address fields (mirrors bo_location)
    `location_name`     VARCHAR(255)    NULL,
    `location_type`     VARCHAR(100)    NULL,
    `street_address_1`  VARCHAR(255)    NULL,
    `street_address_2`  VARCHAR(255)    NULL,
    `city_name`         VARCHAR(100)    NULL,
    `state_name`        VARCHAR(100)    NULL,
    `zip_code`          VARCHAR(20)     NULL,
    `country_id`        BIGINT          NULL,
    `country_name`      VARCHAR(100)    NULL,
    `is_default`        TINYINT         NOT NULL DEFAULT 0,
    `additional_values` JSON            NULL,
    `bo_contact_id`     BIGINT          NULL,

    -- Audit
    `created_by`        VARCHAR(150)    NULL,
    `updated_by`        VARCHAR(150)    NULL,
    `date_created`      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `date_updated`      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`address_id`),
    INDEX `idx_addr_rid`     (`rid`),
    INDEX `idx_addr_lead`    (`lead_id`),
    INDEX `idx_addr_opp`     (`opportunity_id`),
    INDEX `idx_addr_account` (`account_id`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='CRM addresses for leads, opportunities, and accounts — mirrors bo_location fields';


  ALTER TABLE `alpide-crm`.crm_lead_status
      ADD COLUMN color_for_ui VARCHAR(55) DEFAULT NULL;
      
      
        ALTER TABLE `alpide-crm`.crm_lead_stage_status
      ADD COLUMN color_for_ui VARCHAR(55) DEFAULT NULL;