-- ============================================================
-- Alpide CRM - V2 Migration
-- New tables: BANT, Activities (scheduled), Notes, Reminders,
--             Audit Trail, Lead Conversion, Account, Contact,
--             Opportunity enrichments
-- ============================================================

-- ─────────────────────────────────────────────
-- 1. LEAD BANT  (1-to-1 with crm_lead)
-- ─────────────────────────────────────────────
use `alpide-crm`;
CREATE TABLE  crm_lead_bant (
    bant_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid             BIGINT          NOT NULL  COMMENT 'tenant / relationship ID',
    crm_lead_id     BIGINT          NOT NULL  UNIQUE,
    budget          VARCHAR(200)    NULL      COMMENT 'Confirmed or expected budget e.g. AED 80,000',
    authority       VARCHAR(200)    NULL      COMMENT 'Decision maker name & title',
    need            TEXT            NULL      COMMENT 'JSON array of product/module IDs from inventory service',
    timeline        VARCHAR(100)    NULL      COMMENT 'Expected go-live e.g. Q2 2026',
    urgency         TEXT            NULL      COMMENT 'Why now? What happens if delayed?',
    score           TINYINT         NOT NULL  DEFAULT 0 COMMENT 'Auto-calculated 0-5. 5 triggers Qualified',
    updated_by_emp_id BIGINT        NULL,
    date_created    TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    date_updated    TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_lead_bant_lead FOREIGN KEY (crm_lead_id) REFERENCES crm_lead(crm_lead_id)
) ENGINE=InnoDB COMMENT='BANT qualification fields per lead';

CREATE INDEX idx_lead_bant_lead ON crm_lead_bant(crm_lead_id);
CREATE INDEX idx_lead_bant_rid  ON crm_lead_bant(rid);

-- ─────────────────────────────────────────────
-- 2. BANT NEED LINE ITEMS  (products from inventory)
-- ─────────────────────────────────────────────
CREATE TABLE  crm_lead_bant_need_item (
    need_item_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    bant_id             BIGINT          NOT NULL,
    crm_lead_id         BIGINT          NOT NULL,
    rid                 BIGINT          NOT NULL,
    inventory_product_id BIGINT         NOT NULL  COMMENT 'FK to inventory service product',
    product_code        VARCHAR(100)    NULL,
    product_name        VARCHAR(255)    NOT NULL,
    quantity            DECIMAL(10,2)   NULL,
    estimated_value     DECIMAL(18,2)   NULL,
    currency            VARCHAR(10)     NULL      DEFAULT 'AED',
    notes               TEXT            NULL,
    date_created        TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bant_need_bant FOREIGN KEY (bant_id) REFERENCES crm_lead_bant(bant_id),
    CONSTRAINT fk_bant_need_lead FOREIGN KEY (crm_lead_id) REFERENCES crm_lead(crm_lead_id)
) ENGINE=InnoDB COMMENT='Individual product/module needs linked to BANT';

CREATE INDEX idx_bant_need_bant ON crm_lead_bant_need_item(bant_id);
CREATE INDEX idx_bant_need_rid  ON crm_lead_bant_need_item(rid);

-- ─────────────────────────────────────────────
-- 3. LEAD SCORE  (Hot / Warm / Cold)
-- ─────────────────────────────────────────────
ALTER TABLE crm_lead
    ADD COLUMN  lead_score      ENUM('Hot','Warm','Cold') NOT NULL DEFAULT 'Cold'
        COMMENT 'Manual score set by rep',
    ADD COLUMN  competitor      VARCHAR(255) NULL,
    ADD COLUMN  whatsapp        VARCHAR(30)  NULL,
    ADD COLUMN  is_converted    TINYINT(1)   NOT NULL DEFAULT 0,
    ADD COLUMN  converted_at    TIMESTAMP    NULL;

-- ─────────────────────────────────────────────
-- 4. SCHEDULED ACTIVITIES  (universal — Lead / Account / Contact / Opportunity)
-- ─────────────────────────────────────────────
CREATE TABLE  crm_scheduled_activity (
    scheduled_activity_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid                     BIGINT          NOT NULL,
    entity_type             ENUM('LEAD','ACCOUNT','CONTACT','OPPORTUNITY') NOT NULL,
    entity_id               BIGINT          NOT NULL  COMMENT 'ID in respective entity table',
    activity_type           ENUM('CALL','EMAIL','MEETING','DEMO','FOLLOW_UP','WHATSAPP','TASK','OTHER') NOT NULL,
    title                   VARCHAR(255)    NOT NULL,
    description             TEXT            NULL,
    scheduled_at            DATETIME        NOT NULL  COMMENT 'When the activity is scheduled',
    duration_minutes        INT             NULL      DEFAULT 30,
    location                VARCHAR(255)    NULL,
    status                  ENUM('SCHEDULED','COMPLETED','CANCELLED','NO_SHOW','RESCHEDULED')
                                            NOT NULL  DEFAULT 'SCHEDULED',
    priority                ENUM('LOW','MEDIUM','HIGH') NOT NULL DEFAULT 'MEDIUM',
    assigned_to_emp_id      BIGINT          NOT NULL  COMMENT 'Employee who owns this activity',
    assigned_to_emp_name    VARCHAR(255)    NULL,
    completed_at            DATETIME        NULL,
    completion_notes        TEXT            NULL,
    outcome                 VARCHAR(255)    NULL      COMMENT 'Brief outcome after completion',
    reminder_minutes_before INT             NULL      DEFAULT 15 COMMENT 'Notify N minutes before',
    is_reminder_sent        TINYINT(1)      NOT NULL  DEFAULT 0,
    created_by_emp_id       BIGINT          NOT NULL,
    created_by_emp_name     VARCHAR(255)    NULL,
    updated_by_emp_id       BIGINT          NULL,
    date_created            TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    date_updated            TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Scheduled activities for all CRM entities';

CREATE INDEX idx_sched_act_entity   ON crm_scheduled_activity(entity_type, entity_id);
CREATE INDEX idx_sched_act_rid      ON crm_scheduled_activity(rid);
CREATE INDEX idx_sched_act_assigned ON crm_scheduled_activity(assigned_to_emp_id);
CREATE INDEX idx_sched_act_date     ON crm_scheduled_activity(scheduled_at);
CREATE INDEX idx_sched_act_status   ON crm_scheduled_activity(status);

-- ─────────────────────────────────────────────
-- 5. NOTES  (universal — Lead / Account / Contact / Opportunity)
-- ─────────────────────────────────────────────
CREATE TABLE  crm_note (
    note_id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid                 BIGINT          NOT NULL,
    entity_type         ENUM('LEAD','ACCOUNT','CONTACT','OPPORTUNITY') NOT NULL,
    entity_id           BIGINT          NOT NULL,
    content             TEXT            NOT NULL,
    is_pinned           TINYINT(1)      NOT NULL  DEFAULT 0,
    created_by_emp_id   BIGINT          NOT NULL,
    created_by_emp_name VARCHAR(255)    NULL,
    updated_by_emp_id   BIGINT          NULL,
    date_created        TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    date_updated        TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Notes for all CRM entities (Lead, Account, Contact, Opportunity)';

CREATE INDEX idx_note_entity ON crm_note(entity_type, entity_id);
CREATE INDEX idx_note_rid    ON crm_note(rid);

-- ─────────────────────────────────────────────
-- 6. REMINDERS  (universal)
-- ─────────────────────────────────────────────
CREATE TABLE  crm_reminder (
    reminder_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid                 BIGINT          NOT NULL,
    entity_type         ENUM('LEAD','ACCOUNT','CONTACT','OPPORTUNITY') NOT NULL,
    entity_id           BIGINT          NOT NULL,
    title               VARCHAR(255)    NOT NULL,
    description         TEXT            NULL,
    remind_at           DATETIME        NOT NULL,
    is_sent             TINYINT(1)      NOT NULL  DEFAULT 0,
    sent_at             DATETIME        NULL,
    created_by_emp_id   BIGINT          NOT NULL,
    created_by_emp_name VARCHAR(255)    NULL,
    date_created        TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    date_updated        TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Reminders for all CRM entities';

CREATE INDEX idx_reminder_entity  ON crm_reminder(entity_type, entity_id);
CREATE INDEX idx_reminder_rid     ON crm_reminder(rid);
CREATE INDEX idx_reminder_time    ON crm_reminder(remind_at);

-- ─────────────────────────────────────────────
-- 7. AUDIT TRAIL  (universal — every field change logged)
-- ─────────────────────────────────────────────
CREATE TABLE  crm_audit_trail (
    audit_id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid                 BIGINT          NOT NULL,
    entity_type         ENUM('LEAD','ACCOUNT','CONTACT','OPPORTUNITY','BANT','NOTE','ACTIVITY','REMINDER') NOT NULL,
    entity_id           BIGINT          NOT NULL,
    action              ENUM('CREATE','UPDATE','DELETE','STATUS_CHANGE','STAGE_CHANGE',
                             'CONVERT','ASSIGN','NOTE_ADDED','ACTIVITY_LOGGED',
                             'REMINDER_SET','BANT_UPDATED') NOT NULL,
    field_name          VARCHAR(100)    NULL      COMMENT 'Which field changed (null for full-object events)',
    old_value           TEXT            NULL,
    new_value           TEXT            NULL,
    description         TEXT            NULL      COMMENT 'Human-readable change summary',
    changed_by_emp_id   BIGINT          NOT NULL,
    changed_by_emp_name VARCHAR(255)    NULL,
    ip_address          VARCHAR(45)     NULL,
    user_agent          VARCHAR(512)    NULL,
    changed_at          TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_entity  (entity_type, entity_id),
    INDEX idx_audit_rid     (rid),
    INDEX idx_audit_time    (changed_at),
    INDEX idx_audit_actor   (changed_by_emp_id)
) ENGINE=InnoDB COMMENT='Immutable audit trail for all CRM entities';

-- ─────────────────────────────────────────────
-- 8. LEAD CONVERSION  (1 row per conversion event)
-- ─────────────────────────────────────────────
CREATE TABLE  crm_lead_conversion (
    conversion_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid                 BIGINT          NOT NULL,
    crm_lead_id         BIGINT          NOT NULL,
    account_id          BIGINT          NOT NULL,
    contact_id          BIGINT          NOT NULL,
    opportunity_id      BIGINT          NULL      COMMENT 'NULL if rep skipped opp creation',
    converted_by_emp_id BIGINT          NOT NULL,
    converted_by_name   VARCHAR(255)    NULL,
    converted_at        TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    account_name        VARCHAR(255)    NULL,
    contact_name        VARCHAR(255)    NULL,
    opportunity_name    VARCHAR(255)    NULL,
    notes               TEXT            NULL,
    CONSTRAINT fk_conv_lead FOREIGN KEY (crm_lead_id) REFERENCES crm_lead(crm_lead_id)
) ENGINE=InnoDB COMMENT='Conversion audit: lead -> account + contact + opportunity';

CREATE INDEX idx_conv_lead    ON crm_lead_conversion(crm_lead_id);
CREATE INDEX idx_conv_account ON crm_lead_conversion(account_id);

-- ─────────────────────────────────────────────
-- 9. ACCOUNT  (new normalized table replacing crm_account_parent for new flows)
-- ─────────────────────────────────────────────
CREATE TABLE  crm_account (
    account_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid                 BIGINT          NOT NULL,
    account_code        VARCHAR(20)     NOT NULL  UNIQUE COMMENT 'Auto-generated e.g. ACC-0011',
    account_name        VARCHAR(255)    NOT NULL,
    account_type        ENUM('Prospect','Customer','Partner','Former Customer','Competitor','Other')
                                        NOT NULL  DEFAULT 'Prospect',
    custom_type_label   VARCHAR(100)    NULL      COMMENT 'User-defined label if type not in enum',
    industry            VARCHAR(100)    NULL,
    website             VARCHAR(255)    NULL,
    phone               VARCHAR(30)     NULL,
    email               VARCHAR(150)    NULL,
    whatsapp            VARCHAR(30)     NULL,
    address             TEXT            NULL,
    tax_reg_no          VARCHAR(50)     NULL,
    currency            VARCHAR(10)     NULL      DEFAULT 'AED',
    payment_terms       VARCHAR(50)     NULL,
    credit_limit        DECIMAL(18,2)   NULL,
    outstanding_balance DECIMAL(18,2)   NULL,
    employees           VARCHAR(20)     NULL      COMMENT '1-10,11-50,51-200,201-500,500+',
    annual_revenue      DECIMAL(18,2)   NULL,
    owner_id            BIGINT          NOT NULL,
    owner_name          VARCHAR(255)    NULL,
    territory           VARCHAR(100)    NULL,
    team                VARCHAR(100)    NULL,
    erp_sync_status     ENUM('None','Pending','Synced') NOT NULL DEFAULT 'None',
    erp_customer_id     VARCHAR(100)    NULL,
    competitor          VARCHAR(255)    NULL,
    source              VARCHAR(100)    NULL,
    description         TEXT            NULL,
    -- traceability
    converted_from_lead_id BIGINT       NULL,
    created_by_emp_id   BIGINT          NOT NULL,
    created_by_emp_name VARCHAR(255)    NULL,
    updated_by_emp_id   BIGINT          NULL,
    date_created        TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    date_updated        TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Normalized account master';

CREATE INDEX idx_account_type   ON crm_account(account_type);
CREATE INDEX idx_account_owner  ON crm_account(owner_id);
CREATE INDEX idx_account_rid    ON crm_account(rid);
CREATE INDEX idx_account_erp    ON crm_account(erp_sync_status);

-- ─────────────────────────────────────────────
-- 10. CONTACT  (linked to account, optionally to lead)
-- ─────────────────────────────────────────────
CREATE TABLE  crm_contact (
    contact_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid                 BIGINT          NOT NULL,
    account_id          BIGINT          NOT NULL,
    lead_id             BIGINT          NULL      COMMENT 'Originating lead if converted',
    first_name          VARCHAR(100)    NOT NULL,
    last_name           VARCHAR(100)    NOT NULL,
    job_title           VARCHAR(150)    NOT NULL,
    buying_role         ENUM('Decision Maker','Influencer','Champion','User','Blocker') NOT NULL,
    email               VARCHAR(150)    NOT NULL,
    phone               VARCHAR(30)     NULL,
    whatsapp            VARCHAR(30)     NULL,
    source              VARCHAR(100)    NULL,
    status              ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
    created_by_emp_id   BIGINT          NOT NULL,
    created_by_emp_name VARCHAR(255)    NULL,
    updated_by_emp_id   BIGINT          NULL,
    date_created        TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    date_updated        TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_contact_account FOREIGN KEY (account_id) REFERENCES crm_account(account_id)
) ENGINE=InnoDB COMMENT='Contacts linked to accounts';

CREATE INDEX idx_contact_account ON crm_contact(account_id);
CREATE INDEX idx_contact_rid     ON crm_contact(rid);
CREATE UNIQUE INDEX uq_contact_email_rid ON crm_contact(rid, email);

-- ─────────────────────────────────────────────
-- 11. OPPORTUNITY  (new normalized, replaces crm_opportunity for new flows)
-- ─────────────────────────────────────────────
CREATE TABLE  crm_opportunity_v2 (
    opportunity_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid                     BIGINT          NOT NULL,
    opportunity_code        VARCHAR(20)     NOT NULL  UNIQUE COMMENT 'e.g. OPP-001',
    opportunity_name        VARCHAR(255)    NOT NULL,
    account_id              BIGINT          NOT NULL,
    primary_contact_id      BIGINT          NULL,
    lead_id                 BIGINT          NULL      COMMENT 'Originating lead',
    -- Stage / Status (FK to master tables)
    stage_id                INT             NOT NULL  DEFAULT 1 COMMENT 'FK to opportunity_stage_master',
    status_id               INT             NOT NULL  COMMENT 'FK to opportunity_status_master',
    probability             TINYINT         NOT NULL  DEFAULT 30,
    -- Financials
    amount                  DECIMAL(18,2)   NULL,
    currency                VARCHAR(10)     NULL      DEFAULT 'AED',
    weighted_amount         DECIMAL(18,2)   NULL      COMMENT 'Calculated by service: amount * probability / 100. Updated on save.',
    -- Dates
    expected_close_date     DATE            NULL,
    actual_close_date       DATE            NULL,
    -- Metadata
    source                  VARCHAR(100)    NULL,
    competitor              VARCHAR(255)    NULL,
    modules_of_interest     VARCHAR(500)    NULL      COMMENT 'JSON array e.g. ["MRP","WMS"]',
    description             TEXT            NULL,
    reason_for_loss         TEXT            NULL,
    reason_for_win          TEXT            NULL,
    owner_id                BIGINT          NOT NULL,
    owner_name              VARCHAR(255)    NULL,
    -- Outcome
    is_closed               TINYINT(1)      NOT NULL  DEFAULT 0,
    closed_won              TINYINT(1)      NOT NULL  DEFAULT 0,
    -- Traceability
    created_by_emp_id       BIGINT          NOT NULL,
    created_by_emp_name     VARCHAR(255)    NULL,
    updated_by_emp_id       BIGINT          NULL,
    date_created            TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    date_updated            TIMESTAMP       NOT NULL  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_opp_account  FOREIGN KEY (account_id)         REFERENCES crm_account(account_id),
    CONSTRAINT fk_opp_contact  FOREIGN KEY (primary_contact_id) REFERENCES crm_contact(contact_id)
) ENGINE=InnoDB COMMENT='Opportunities - new normalized model';

CREATE INDEX idx_opp_account  ON crm_opportunity_v2(account_id);
CREATE INDEX idx_opp_stage    ON crm_opportunity_v2(stage_id);
CREATE INDEX idx_opp_owner    ON crm_opportunity_v2(owner_id);
CREATE INDEX idx_opp_rid      ON crm_opportunity_v2(rid);
CREATE INDEX idx_opp_close    ON crm_opportunity_v2(expected_close_date);

-- ─────────────────────────────────────────────
-- 12. OPPORTUNITY ↔ CONTACT  (bridge - multiple contacts per opportunity)
-- ─────────────────────────────────────────────
CREATE TABLE  crm_opportunity_contact (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    opportunity_id  BIGINT NOT NULL,
    contact_id      BIGINT NOT NULL,
    is_primary      TINYINT(1) NOT NULL DEFAULT 0,
    UNIQUE KEY uq_opp_contact (opportunity_id, contact_id),
    CONSTRAINT fk_oppcon_opp     FOREIGN KEY (opportunity_id) REFERENCES crm_opportunity_v2(opportunity_id),
    CONSTRAINT fk_oppcon_contact FOREIGN KEY (contact_id)     REFERENCES crm_contact(contact_id)
) ENGINE=InnoDB COMMENT='Bridge: opportunities to contacts';

-- ─────────────────────────────────────────────
-- 13. OPPORTUNITY STAGE HISTORY
-- ─────────────────────────────────────────────
CREATE TABLE  crm_opportunity_stage_history (
    history_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid                 BIGINT          NOT NULL,
    opportunity_id      BIGINT          NOT NULL,
    from_stage_id       INT             NULL,
    from_stage_name     VARCHAR(100)    NULL,
    from_status_id      INT             NULL,
    from_status_name    VARCHAR(100)    NULL,
    to_stage_id         INT             NOT NULL,
    to_stage_name       VARCHAR(100)    NOT NULL,
    to_status_id        INT             NOT NULL,
    to_status_name      VARCHAR(100)    NOT NULL,
    reason              TEXT            NULL,
    is_reason_mandatory TINYINT(1)      NOT NULL DEFAULT 0,
    changed_by_emp_id   BIGINT          NOT NULL,
    changed_by_emp_name VARCHAR(255)    NULL,
    changed_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_created        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Every opportunity stage/status change';

CREATE INDEX idx_opp_hist_opp  ON crm_opportunity_stage_history(opportunity_id);
CREATE INDEX idx_opp_hist_time ON crm_opportunity_stage_history(changed_at);

-- ─────────────────────────────────────────────
-- 14. LEAD STAGE HISTORY (extend existing crm_lead_status_history)
-- ─────────────────────────────────────────────
ALTER TABLE crm_lead_status_history
    ADD COLUMN  from_stage_id      INT  NULL,
    ADD COLUMN from_stage_name    VARCHAR(100) NULL,
    ADD COLUMN  to_stage_id        INT  NULL,
    ADD COLUMN  to_stage_name      VARCHAR(100) NULL,
    ADD COLUMN  reason             TEXT NULL,
    ADD COLUMN  is_reason_mandatory TINYINT(1) NOT NULL DEFAULT 0;

-- ─────────────────────────────────────────────
-- REFERENCE DATA SEED
-- ─────────────────────────────────────────────

-- Lead Stage Master
CREATE TABLE  lead_stage_master (
    stage_id    INT PRIMARY KEY,
    stage_name  VARCHAR(50) NOT NULL,
    sort_order  TINYINT     NOT NULL
) ENGINE=InnoDB;

INSERT IGNORE INTO lead_stage_master (stage_id, stage_name, sort_order) VALUES
(1, 'Lead Uploaded', 1),
(2, 'Qualification',  2);

-- Lead Status Master
CREATE TABLE  lead_status_master (
    status_id       INT PRIMARY KEY,
    stage_id        INT NOT NULL,
    status_name     VARCHAR(100) NOT NULL,
    is_cross_stage  TINYINT(1)   NOT NULL DEFAULT 0,
    FOREIGN KEY (stage_id) REFERENCES lead_stage_master(stage_id)
) ENGINE=InnoDB;

INSERT IGNORE INTO lead_status_master (status_id, stage_id, status_name, is_cross_stage) VALUES
(1,  1, 'New',                    0),
(2,  1, 'Assigned',               0),
(3,  1, 'Duplicate Check Pending',0),
(4,  2, 'Attempting Contact',     0),
(5,  2, 'Connected',              0),
(6,  2, 'Not Reachable',          0),
(7,  2, 'Disqualified',           0),
(8,  2, 'Nurture',                0),
(9,  2, 'Qualified',              0),
(10, 1, 'Ghosted',                1),
(11, 1, 'Re-engaged',             1),
(12, 1, 'On Hold',                1);

-- Opportunity Stage Master
CREATE TABLE  opportunity_stage_master (
    stage_id            INT PRIMARY KEY,
    stage_name          VARCHAR(50) NOT NULL,
    default_probability TINYINT     NOT NULL,
    sort_order          TINYINT     NOT NULL
) ENGINE=InnoDB;

INSERT IGNORE INTO opportunity_stage_master (stage_id, stage_name, default_probability, sort_order) VALUES
(1, 'Discovery / Demo', 30,  1),
(2, 'Proposal Sent',    50,  2),
(3, 'Negotiation',      75,  3),
(4, 'Closed Won',       100, 4),
(5, 'Closed Lost',      0,   5);

-- Opportunity Status Master
CREATE TABLE  opportunity_status_master (
    status_id       INT PRIMARY KEY,
    stage_id        INT NOT NULL,
    status_name     VARCHAR(100) NOT NULL,
    is_cross_stage  TINYINT(1)   NOT NULL DEFAULT 0,
    FOREIGN KEY (stage_id) REFERENCES opportunity_stage_master(stage_id)
) ENGINE=InnoDB;

INSERT IGNORE INTO opportunity_status_master (status_id, stage_id, status_name, is_cross_stage) VALUES
(1,  1, 'Demo Scheduled',             0),
(2,  1, 'Demo Completed',             0),
(3,  1, 'No Show',                    0),
(4,  1, 'Follow-up Pending',          0),
(5,  1, 'Re-schedule Requested',      0),
(6,  2, 'Awaiting Response',          0),
(7,  2, 'Viewed / Opened',            0),
(8,  2, 'Follow-up Due',              0),
(9,  2, 'Revision Requested',         0),
(10, 2, 'In Review',                  0),
(11, 2, 'On Hold',                    0),
(12, 3, 'Discussion in Progress',     0),
(13, 3, 'Discount Approval Pending',  0),
(14, 3, 'Decision Pending',           0),
(15, 3, 'Stakeholder Alignment',      0),
(16, 3, 'On Hold',                    0),
(17, 4, 'Contract Sent',              0),
(18, 4, 'Contract Signed',            0),
(19, 4, 'Handover to Onboarding',     0),
(20, 5, 'Budget Constraint',          0),
(21, 5, 'Chose Competitor',           0),
(22, 5, 'No Decision',                0),
(23, 5, 'Timing Not Right',           0),
(24, 5, 'Unresponsive',               0),
(25, 1, 'Ghosted',                    1),
(26, 1, 'Re-engaged',                 1),
(27, 1, 'On Hold (Cross)',            1);
ALTER TABLE `alpide-crm`.`crm_lead_bant_need_item` 
DROP FOREIGN KEY `fk_bant_need_bant`;
ALTER TABLE `alpide-crm`.`crm_lead_bant_need_item` 
CHANGE COLUMN `bant_id` `bant_id` BIGINT NULL ;
ALTER TABLE `alpide-crm`.`crm_lead_bant_need_item` 
ADD CONSTRAINT `fk_bant_need_bant`
  FOREIGN KEY (`bant_id`)
  REFERENCES `alpide-crm`.`crm_lead_bant` (`bant_id`);
  
ALTER TABLE `alpide-crm`.`crm_contact` 
CHANGE COLUMN `buying_role` `buying_role` VARCHAR(255) NULL DEFAULT NULL ;

ALTER TABLE `alpide-crm`.`crm_opportunity_v2` 
ADD COLUMN `stage_name` VARCHAR(255) NULL DEFAULT 'null' AFTER `date_updated`;
ALTER TABLE `alpide-crm`.`crm_opportunity_v2` 
ADD COLUMN `status_name` VARCHAR(255) NULL DEFAULT 'null' AFTER `date_updated`;

ALTER TABLE `alpide-crm`.`crm_lead` 
CHANGE COLUMN `lead_score` `lead_score` VARCHAR(255) NOT NULL DEFAULT 'Cold' COMMENT 'Manual score set by rep' ;

ALTER TABLE `alpide-crm`.`crm_lead` 
CHANGE COLUMN `is_converted` `is_converted` TINYINT(1) NULL DEFAULT '0' ;

-- ============================================================
-- Opportunity Stage & Status V2 tables
-- Mirrors the lead stage/status pattern exactly
-- ============================================================

-- 1. Stage master
use `alpide-crm`;
CREATE TABLE IF NOT EXISTS crm_opportunity_stage_v2 (
    opportunity_stage_id   BIGINT        AUTO_INCREMENT PRIMARY KEY,
    rid                    BIGINT        NOT NULL,
    stage_name             VARCHAR(255)  NOT NULL,
    default_probability    INT           NOT NULL DEFAULT 30,
    sort_order             INT           NOT NULL DEFAULT 0,
    color_for_ui           VARCHAR(20)   NULL,
    in_built               TINYINT       NOT NULL DEFAULT 0  COMMENT '1 = system-defined, cannot delete',
    is_active              TINYINT       NOT NULL DEFAULT 1,
    created_by_user_id     BIGINT        NOT NULL DEFAULT 0,
    updated_by_user_id     BIGINT        NOT NULL DEFAULT 0,
    date_created           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_stage_rid (rid)
) ENGINE=InnoDB COMMENT='Opportunity stage master per tenant';

-- 2. Status master
CREATE TABLE IF NOT EXISTS crm_opportunity_status_v2 (
    opportunity_status_id  BIGINT        AUTO_INCREMENT PRIMARY KEY,
    rid                    BIGINT        NOT NULL,
    status_name            VARCHAR(255)  NOT NULL,
    color_for_ui           VARCHAR(20)   NULL,
    is_cross_stage         TINYINT       NOT NULL DEFAULT 0  COMMENT '1 = applies at any stage',
    is_reason_mandatory    TINYINT       NOT NULL DEFAULT 0  COMMENT '1 = rep must give a reason',
    in_built               TINYINT       NOT NULL DEFAULT 0,
    is_active              TINYINT       NOT NULL DEFAULT 1,
    created_by_user_id     BIGINT        NOT NULL DEFAULT 0,
    updated_by_user_id     BIGINT        NOT NULL DEFAULT 0,
    date_created           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status_rid        (rid),
    INDEX idx_status_cross      (rid, is_cross_stage)
) ENGINE=InnoDB COMMENT='Opportunity status master per tenant';

-- 3. Bridge: status → stage mappings
CREATE TABLE IF NOT EXISTS crm_opportunity_status_stage_map (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid         BIGINT NOT NULL,
    status_id   BIGINT NOT NULL,
    stage_id    BIGINT NOT NULL,
    INDEX idx_osm_stage  (rid, stage_id),
    INDEX idx_osm_status (rid, status_id)
) ENGINE=InnoDB COMMENT='Maps opportunity statuses to their parent stages';

-- ── Seed data (in_built stages, rid=0 = global defaults copied per tenant on setup) ──

-- Stages (sort_order defines pipeline sequence; in_built=1 means UI cannot delete)
INSERT IGNORE INTO crm_opportunity_stage_v2
    (opportunity_stage_id, rid, stage_name, default_probability, sort_order, color_for_ui, in_built)
VALUES
    (1, 0, 'Discovery / Demo', 30,  1, '#3B82F6', 1),
    (2, 0, 'Proposal Sent',    50,  2, '#F59E0B', 1),
    (3, 0, 'Negotiation',      75,  3, '#8B5CF6', 1),
    (4, 0, 'Closed Won',       100, 4, '#10B981', 1),
    (5, 0, 'Closed Lost',      0,   5, '#EF4444', 1);

-- Statuses
INSERT IGNORE INTO crm_opportunity_status_v2
    (opportunity_status_id, rid, status_name, is_cross_stage, is_reason_mandatory, in_built)
VALUES
    -- Discovery / Demo
    (1,  0, 'Demo Scheduled',            0, 0, 1),
    (2,  0, 'Demo Completed',            0, 0, 1),
    (3,  0, 'No Show',                   0, 0, 1),
    (4,  0, 'Follow-up Pending',         0, 0, 1),
    (5,  0, 'Re-schedule Requested',     0, 0, 1),
    -- Proposal Sent
    (6,  0, 'Awaiting Response',         0, 0, 1),
    (7,  0, 'Viewed / Opened',           0, 0, 1),
    (8,  0, 'Follow-up Due',             0, 0, 1),
    (9,  0, 'Revision Requested',        0, 0, 1),
    (10, 0, 'In Review',                 0, 0, 1),
    -- Negotiation
    (11, 0, 'Discussion in Progress',    0, 0, 1),
    (12, 0, 'Discount Approval Pending', 0, 0, 1),
    (13, 0, 'Decision Pending',          0, 0, 1),
    (14, 0, 'Stakeholder Alignment',     0, 0, 1),
    -- Closed Won
    (15, 0, 'Contract Sent',             0, 0, 1),
    (16, 0, 'Contract Signed',           0, 0, 1),
    (17, 0, 'Handover to Onboarding',    0, 0, 1),
    -- Closed Lost
    (18, 0, 'Budget Constraint',         0, 1, 1),
    (19, 0, 'Chose Competitor',          0, 1, 1),
    (20, 0, 'No Decision',               0, 1, 1),
    (21, 0, 'Timing Not Right',          0, 1, 1),
    (22, 0, 'Unresponsive',              0, 1, 1),
    -- Cross-stage (apply at any stage)
    (23, 0, 'Ghosted',                   1, 0, 1),
    (24, 0, 'Re-engaged',                1, 0, 1),
    (25, 0, 'On Hold',                   1, 1, 1);

-- Bridge: map statuses to stages
INSERT IGNORE INTO crm_opportunity_status_stage_map (rid, status_id, stage_id) VALUES
    -- Discovery / Demo (stage 1)
    (0,  1, 1), (0,  2, 1), (0,  3, 1), (0,  4, 1), (0,  5, 1),
    -- Proposal Sent (stage 2)
    (0,  6, 2), (0,  7, 2), (0,  8, 2), (0,  9, 2), (0, 10, 2),
    -- Negotiation (stage 3)
    (0, 11, 3), (0, 12, 3), (0, 13, 3), (0, 14, 3),
    -- Closed Won (stage 4)
    (0, 15, 4), (0, 16, 4), (0, 17, 4),
    -- Closed Lost (stage 5)
    (0, 18, 5), (0, 19, 5), (0, 20, 5), (0, 21, 5), (0, 22, 5);
    -- Cross-stage statuses (23,24,25) have no bridge rows — is_cross_stage flag handles them
    
   



    USE `alpide-crm`;
DROP procedure IF EXISTS `get_crm_leads_list`;

USE `alpide-crm`;
DROP procedure IF EXISTS `alpide-crm`.`get_crm_leads_list`;
;

DELIMITER $$
USE `alpide-crm`$$
CREATE  PROCEDURE `get_crm_leads_list`(
    IN p_rid INT,
    IN searchedStr VARCHAR(45),
    IN projectName VARCHAR(45),
    IN crmLeadFormSettingId INT,
    IN leadAssignTo VARCHAR(255),
    IN sourceName VARCHAR(45),
    IN statusName VARCHAR(45),
    IN startDate TIMESTAMP,
    IN endDate TIMESTAMP,
    IN reminderType VARCHAR(45),
    IN pageNumber INT,
    IN pageSize INT, 
    IN isActive INT,
    IN stageStatusName VARCHAR(100),
    IN startUpdateDate TIMESTAMP,
    IN endUpdateDate TIMESTAMP
)
BEGIN
    DECLARE whereClause TEXT;
    DECLARE idList VARCHAR(255);

    SET whereClause = CONCAT("cl.rid=", p_rid);
    SET whereClause = CONCAT(whereClause, " AND cl.is_active='", isActive, "'");

    IF (searchedStr IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.lead_name LIKE '%", searchedStr, "%'");
        SET whereClause = CONCAT(whereClause, " OR ld.email LIKE '%", searchedStr, "%'");
        SET whereClause = CONCAT(whereClause, " OR ld.mobile_no LIKE '%", searchedStr, "%'");
    END IF;

    IF (projectName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND pm.project_name='", projectName, "'");
    END IF;

    IF (crmLeadFormSettingId > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.crm_lead_form_setting_id=", crmLeadFormSettingId);
    END IF;

    IF (leadAssignTo IS NOT NULL) THEN
        DROP TEMPORARY TABLE IF EXISTS temp_ids;
        CREATE TEMPORARY TABLE temp_ids (id INT);
        SET idList = leadAssignTo;
        WHILE LENGTH(idList) > 0 DO
            SET @value = SUBSTRING_INDEX(idList, ',', 1);
            INSERT INTO temp_ids (id) VALUES (CAST(@value AS UNSIGNED));
            SET idList = TRIM(BOTH ',' FROM SUBSTRING(idList, LENGTH(@value) + 2));
        END WHILE;
        SET whereClause = CONCAT(whereClause, " AND clea.rel_employee_id IN (SELECT id FROM temp_ids)");
    END IF;

    IF (sourceName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.lead_source_name='", sourceName, "'");
    END IF;

    IF (statusName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.status_name='", statusName, "'");
    END IF;

    IF (stageStatusName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.stage_status_name='", stageStatusName, "'");
    END IF;

    IF (reminderType IS NOT NULL AND reminderType = 'Upcoming') THEN
        SET whereClause = CONCAT(whereClause, " AND clr.reminder_date_and_time >'", CURRENT_TIMESTAMP, "'");
    END IF;

    IF (reminderType IS NOT NULL AND reminderType = 'Expired') THEN
        SET whereClause = CONCAT(whereClause, " AND clr.reminder_date_and_time <'", CURRENT_TIMESTAMP, "'");
    END IF;

    IF (startDate IS NOT NULL AND endDate IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.date_created BETWEEN '", startDate, "' AND '", endDate, "'");
    END IF;

    IF (startUpdateDate IS NOT NULL AND endUpdateDate IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.date_updated BETWEEN '", startUpdateDate, "' AND '", endUpdateDate, "'");
    END IF;

    SET @stmt = 'SELECT
        DISTINCT cl.crm_lead_id                    AS crmLeadId,
        cl.rid                                     AS relationshipId,
        cl.lead_name                               AS leadName,
        cl.is_active                               AS isActive,
        cl.industry_code                           AS industryCode,
        cl.industry_name                           AS industryName,
        cl.company_type_code                       AS companyTypeCode,
        cl.company_type_name                       AS companyTypeName,
        cl.website                                 AS website,
        cl.lead_source_name                        AS leadSourceName,
        cl.is_existing_lead                        AS isExistingLead,
        cl.has_lead_contacted                      AS hasLeadContacted,
        cl.status_name                             AS statusName,
        cl.has_proposal_sent                       AS hasProposalSent,
        cl.remarks                                 AS remarks,
        cl.lead_source_id                          AS leadSourceId,
        cl.date_created                            AS dateCreated,
        cl.date_updated                            AS dateUpdated,
        cl.created_by                              AS createdBy,
        cl.updated_by                              AS updatedBy,
        cl.status_color_for_ui_cell                AS statusColorForUiCell,
        cl.status_id                               AS statusId,
        cl.star_rating                             AS starRating,
        cl.created_by_emp_id                       AS createdByEmpId,
        cl.updated_by_emp_id                       AS updatedByEmpId,
        cl.form_name                               AS formName,
        cl.crm_lead_form_setting_id                AS crmLeadFormSettingId,
        cl.is_lead_to_customer                     AS isLeadToCustomer,
        clr.reminder_title                         AS reminderTitle,
        ld.full_name                               AS fullName,
        ld.email                                   AS email,
        ld.mobile_no                               AS mobileNo,
        COALESCE(cln.notesCount, 0)                AS totalNotes,
        cl.stage_status_name                       AS stageStatusName,

        /* ── NEW: Next scheduled activity ───────────────────────────── */
        nxa.title                                  AS nextActivityTitle,
        nxa.activity_type                          AS nextActivityType,
        nxa.scheduled_at                           AS nextActivityScheduledAt,
        nxa.assigned_to_emp_name                   AS nextActivityAssignedTo,

        /* ── NEW: BANT score (0-5) ──────────────────────────────────── */
        COALESCE(bant.score, 0)                    AS bantScore,

        /* ── NEW: Lead score (Hot/Warm/Cold) ────────────────────────── */
        COALESCE(cl.lead_score, ''Cold'')           AS leadScore,

        /* ── NEW: Conversion fields ─────────────────────────────────── */
        cl.is_converted                            AS isConverted,
        cl.converted_at                            AS convertedAt

        FROM crm_lead cl
        LEFT JOIN crm_lead_reminder clr
            ON cl.crm_lead_id = clr.crm_lead_id
        LEFT JOIN (
            SELECT crm_lead_id, COUNT(*) AS notesCount
            FROM crm_lead_notes
            GROUP BY crm_lead_id
        ) cln ON cl.crm_lead_id = cln.crm_lead_id
        LEFT JOIN crm_lead_emp_assigned clea
            ON cl.crm_lead_id = clea.crm_lead_id
        LEFT JOIN crm_lead_form_setting clfs
            ON cl.crm_lead_form_setting_id = clfs.crm_lead_form_setting_id
        LEFT JOIN (
            SELECT crm_lead_id,
                MAX(CASE WHEN label = "Full Name"  THEN value END) AS full_name,
                MAX(CASE WHEN label = "Email"      THEN value END) AS email,
                MAX(CASE WHEN label = "Mobile No." THEN value END) AS mobile_no
            FROM crm_lead_detail
            GROUP BY crm_lead_id
        ) ld ON cl.crm_lead_id = ld.crm_lead_id

        /* ── Next upcoming scheduled activity per lead ──────────────── */
        LEFT JOIN (
            SELECT sa.entity_id,
                   sa.title,
                   sa.activity_type,
                   sa.scheduled_at,
                   sa.assigned_to_emp_name
            FROM crm_scheduled_activity sa
            INNER JOIN (
                SELECT entity_id, MIN(scheduled_at) AS min_scheduled_at
                FROM crm_scheduled_activity
                WHERE entity_type = ''LEAD''
                  AND status = ''SCHEDULED''
                  AND scheduled_at > NOW()
                GROUP BY entity_id
            ) nxt ON sa.entity_id = nxt.entity_id
                  AND sa.scheduled_at = nxt.min_scheduled_at
                  AND sa.entity_type = ''LEAD''
        ) nxa ON cl.crm_lead_id = nxa.entity_id

        /* ── BANT record ────────────────────────────────────────────── */
        LEFT JOIN crm_lead_bant bant
            ON cl.crm_lead_id = bant.crm_lead_id

        WHERE ';

    SET @stmt1 = CONCAT(
        @stmt,
        whereClause,
        ' ORDER BY cl.date_updated DESC LIMIT ',
        pageSize,
        ' OFFSET ',
        pageNumber * pageSize
    );

    PREPARE stmt2 FROM @stmt1;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
    DROP TEMPORARY TABLE IF EXISTS temp_ids;

END$$

DELIMITER ;
;


use `alpide-crm`;
CREATE TABLE IF NOT EXISTS crm_lead_status_history (
    id                  BIGINT          NOT NULL AUTO_INCREMENT,
    rid                 BIGINT          NOT NULL COMMENT 'relationship id',
    crm_lead_id         BIGINT          NOT NULL COMMENT 'FK → crm_lead.crm_lead_id',
 
    -- "STATUS" or "STAGE_STATUS"
    change_type         VARCHAR(20)     NOT NULL,
 
    from_status_id      BIGINT          NULL     COMMENT 'NULL on first assignment',
    from_status_name    VARCHAR(255)    NULL,
    to_status_id        BIGINT          NOT NULL,
    to_status_name      VARCHAR(255)    NOT NULL,
 
    changed_by_emp_id   BIGINT          NOT NULL,
    changed_by_emp_name VARCHAR(255)    NULL,
    changed_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
 
    date_created        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
 
    PRIMARY KEY (id),
    INDEX idx_lead_history  (rid, crm_lead_id),
    INDEX idx_changed_at    (changed_at),
    INDEX idx_change_type   (rid, crm_lead_id, change_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Audit log: every status and stage-status change per lead';
  
  CREATE TABLE IF NOT EXISTS crm_lead_stage_status_parent (
    id               BIGINT          NOT NULL AUTO_INCREMENT,
    rid              BIGINT          NOT NULL COMMENT 'relationship id',
    stage_status_id  BIGINT          NOT NULL COMMENT 'FK → crm_lead_stage_status.lead_status_id',
    parent_status_id BIGINT          NOT NULL COMMENT 'FK → crm_lead_status.lead_status_id',
 
    PRIMARY KEY (id),
    UNIQUE KEY uq_stage_parent (rid, stage_status_id, parent_status_id),
    INDEX idx_by_parent  (rid, parent_status_id),
    INDEX idx_by_stage   (rid, stage_status_id),
 
    CONSTRAINT fk_ssp_stage
        FOREIGN KEY (stage_status_id)
        REFERENCES crm_lead_stage_status (lead_status_id)
        ON DELETE CASCADE,
 
    CONSTRAINT fk_ssp_parent
        FOREIGN KEY (parent_status_id)
        REFERENCES crm_lead_status (lead_status_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Many-to-many: stage status → parent status(es)';
    ALTER TABLE crm_lead_status_history                                                                                                                                                                                                       
  ADD COLUMN comment TEXT NULL AFTER changed_by_emp_name;  
