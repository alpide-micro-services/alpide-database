-- ============================================================
-- Complete WhatsApp ChatBox Schema (All Tables)
-- Run manually against alpide-communication schema
-- ============================================================

-- ═══════════════════════════════════════════════════════════
-- 1. WhatsApp Settings (BYOK - Bring Your Own Key)
-- ═══════════════════════════════════════════════════════════
use `alpide-communication`;
CREATE TABLE IF NOT EXISTS whatsapp_setting (
    whatsapp_setting_id   BIGINT         AUTO_INCREMENT PRIMARY KEY,
    rid                   BIGINT         NOT NULL,
    provider              VARCHAR(50)    NOT NULL DEFAULT 'META'
                              COMMENT 'META | TWILIO | GUPSHUP',
    display_name          VARCHAR(255)   COMMENT 'Friendly label for this configuration',
    phone_number_id       VARCHAR(255)   COMMENT 'Meta: Phone Number ID from Business Manager',
    access_token          TEXT           COMMENT 'Meta: Permanent system-user access token',
    business_account_id   VARCHAR(255)   COMMENT 'Meta: WhatsApp Business Account (WABA) ID',
    webhook_verify_token  VARCHAR(255)   COMMENT 'Token used to verify Meta webhook callbacks',
    api_version           VARCHAR(20)    NOT NULL DEFAULT 'v19.0',
    from_phone_number     VARCHAR(50)    COMMENT 'Display phone number (E.164 format)',
    is_active             TINYINT(1)     NOT NULL DEFAULT 1,
    created_by_user_id    BIGINT,
    updated_by_user_id    BIGINT,
    date_created          TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated          TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wa_setting_rid (rid),
    INDEX idx_wa_setting_rid_provider (rid, provider),
    INDEX idx_wa_setting_active (is_active)
) COMMENT='WhatsApp credentials & settings per customer (RID)';

-- ═══════════════════════════════════════════════════════════
-- 2. WhatsApp Communication Log (Main Chat Storage)
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS whatsapp_communication_log (
    whatsapp_communication_log_id  BIGINT        AUTO_INCREMENT PRIMARY KEY,
    rid                            BIGINT        NOT NULL
                                       COMMENT 'Relationship ID - which customer',
    module_type                    VARCHAR(50)
                                       COMMENT 'LEAD | OPPORTUNITY | INVOICE | ACCOUNT | REPORT | CONTACT | CUSTOMER',
    module_id                      BIGINT        COMMENT 'PK of the record in the module (e.g., leadId)',
    provider                       VARCHAR(50)   NOT NULL DEFAULT 'META',
    from_number                    VARCHAR(50)   COMMENT 'Sender phone number (E.164 format)',
    to_number                      VARCHAR(255)  NOT NULL COMMENT 'Recipient phone number (E.164 format)',
    message_type                   VARCHAR(50)   NOT NULL DEFAULT 'TEXT'
                                       COMMENT 'TEXT | IMAGE | DOCUMENT | VIDEO | AUDIO | LOCATION | CONTACT',
    message_content                MEDIUMTEXT    COMMENT 'Text content or parsed metadata',
    media_url                      TEXT          COMMENT 'File ID or URL for media',
    media_type                     VARCHAR(50)   COMMENT 'image/jpeg | application/pdf | video/mp4 | audio/mpeg',
    media_caption                  TEXT          COMMENT 'Caption for image/video',
    media_filename                 VARCHAR(255)  COMMENT 'Filename for documents',
    whatsapp_message_id            VARCHAR(255)  UNIQUE COMMENT 'Unique ID from WhatsApp (wamid)',
    status                         VARCHAR(50)   NOT NULL DEFAULT 'SENT'
                                       COMMENT 'SENT | DELIVERED | READ | FAILED | PENDING',
    error_message                  TEXT          COMMENT 'Error details if FAILED',
    sent_by_user_id                BIGINT        COMMENT 'NULL = incoming from customer, else user ID',
    direction                      VARCHAR(20)   NOT NULL DEFAULT 'OUTGOING'
                                       COMMENT 'INCOMING | OUTGOING',
    date_created                   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated                   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes for fast queries
    INDEX idx_wa_log_rid (rid),
    INDEX idx_wa_log_module (module_type, module_id),
    INDEX idx_wa_log_to_number (to_number(20)),
    INDEX idx_wa_log_status (status),
    INDEX idx_wa_log_wamid (whatsapp_message_id(100)),
    INDEX idx_wa_log_rid_date (rid, date_created),
    INDEX idx_wa_log_from_number (from_number(20)),
    INDEX idx_wa_log_direction (direction),
    INDEX idx_wa_log_date_created (date_created),

    -- Composite index for chat thread queries
    INDEX idx_wa_log_rid_to_number_date (rid, to_number(20), date_created)
) COMMENT='Chat message history - sent & received messages';

-- ═══════════════════════════════════════════════════════════
-- 3. WhatsApp Sync State (For Optimized Polling)
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS whatsapp_sync_state (
    whatsapp_sync_state_id       BIGINT         AUTO_INCREMENT PRIMARY KEY,
    whatsapp_setting_id          BIGINT         NOT NULL UNIQUE,
    rid                          BIGINT         NOT NULL,
    last_sync_time               BIGINT         COMMENT 'Unix timestamp of last sync',
    last_conversation_cursor     TEXT           COMMENT 'Meta pagination cursor for conversations',
    total_messages_synced        BIGINT         DEFAULT 0,
    last_error_message           TEXT,
    consecutive_failures         INT            DEFAULT 0,
    date_created                 TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated                 TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wa_sync_rid (rid),
    INDEX idx_wa_sync_setting (whatsapp_setting_id),
    CONSTRAINT fk_wa_sync_setting FOREIGN KEY (whatsapp_setting_id)
        REFERENCES whatsapp_setting(whatsapp_setting_id) ON DELETE CASCADE
) COMMENT='Tracks sync progress & state per WhatsApp setting';

-- ═══════════════════════════════════════════════════════════
-- 4. WhatsApp Contact Profile (Optional - Store customer info)
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS whatsapp_contact_profile (
    whatsapp_contact_profile_id  BIGINT         AUTO_INCREMENT PRIMARY KEY,
    rid                          BIGINT         NOT NULL,
    phone_number                 VARCHAR(50)    NOT NULL COMMENT 'E.164 format +919876543210',
    contact_name                 VARCHAR(255)   COMMENT 'Display name from WhatsApp profile',
    contact_avatar_url           TEXT           COMMENT 'Profile picture URL',
    last_message_at              TIMESTAMP      COMMENT 'Last interaction time',
    total_messages               INT            DEFAULT 0,
    status                       VARCHAR(50)    DEFAULT 'ACTIVE' COMMENT 'ACTIVE | ARCHIVED | BLOCKED',
    date_created                 TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated                 TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_wa_contact_rid (rid),
    INDEX idx_wa_contact_phone (phone_number(20)),
    INDEX idx_wa_contact_rid_phone (rid, phone_number(20)),
    UNIQUE KEY unique_rid_phone (rid, phone_number(50))
) COMMENT='Store WhatsApp contact info per customer (RID)';

-- ═══════════════════════════════════════════════════════════
-- 5. WhatsApp Message Mapping to Module (Link chats to CRM)
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS whatsapp_chat_module_mapping (
    whatsapp_chat_module_mapping_id  BIGINT    AUTO_INCREMENT PRIMARY KEY,
    rid                              BIGINT    NOT NULL,
    phone_number                     VARCHAR(50)    NOT NULL COMMENT 'E.164 format',
    module_type                      VARCHAR(50)    NOT NULL COMMENT 'LEAD | OPPORTUNITY | ACCOUNT | CONTACT',
    module_id                        BIGINT         NOT NULL,
    mapped_by_user_id                BIGINT,
    mapping_notes                    TEXT           COMMENT 'Why this chat is linked to this module',
    date_created                     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated                     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_wa_map_rid (rid),
    INDEX idx_wa_map_module (module_type, module_id),
    INDEX idx_wa_map_phone (phone_number(20)),
    UNIQUE KEY unique_rid_phone_module (rid, phone_number(50), module_type, module_id)
) COMMENT='Link WhatsApp conversations to CRM modules (LEAD, OPPORTUNITY, etc.)';

  -- Add the direction column to existing table
  ALTER TABLE whatsapp_communication_log
  ADD COLUMN direction VARCHAR(20) NOT NULL DEFAULT 'OUTGOING' AFTER sent_by_user_id;

  -- Add the index
  ALTER TABLE whatsapp_communication_log
  ADD INDEX idx_wa_log_direction (direction);
-- ═══════════════════════════════════════════════════════════
-- Create Indexes for Performance
-- ═══════════════════════════════════════════════════════════

-- Fast message deduplication during sync
ALTER TABLE whatsapp_communication_log ADD UNIQUE INDEX  idx_wa_log_wamid_unique (whatsapp_message_id(100));

-- Fast chat thread retrieval
ALTER TABLE whatsapp_communication_log ADD INDEX  idx_wa_log_thread_query (rid, to_number(20), date_created DESC);

-- Fast status updates for delivery tracking
ALTER TABLE whatsapp_communication_log ADD INDEX  idx_wa_log_status_updates (status, date_updated);

-- Fast contact list query
ALTER TABLE whatsapp_contact_profile ADD INDEX  idx_wa_contact_last_msg (rid, last_message_at DESC);

-- ═══════════════════════════════════════════════════════════
-- Sample Data for Testing (Optional)
-- ═══════════════════════════════════════════════════════════

-- Insert test WhatsApp setting for RID 1
INSERT INTO whatsapp_setting (rid, provider, display_name, phone_number_id, access_token, business_account_id, from_phone_number, is_active)
VALUES (
    1,
    'META',
    'Main WhatsApp Account',
    'YOUR_PHONE_NUMBER_ID',
    'YOUR_ACCESS_TOKEN',
    'YOUR_WABA_ID',
    '+919876543210',
    1
) ON DUPLICATE KEY UPDATE date_updated = CURRENT_TIMESTAMP;

-- ═══════════════════════════════════════════════════════════
-- Views for ChatBox (Optional but helpful)
-- ═══════════════════════════════════════════════════════════

  DROP VIEW IF EXISTS whatsapp_conversation_list_view;
  DROP VIEW IF EXISTS whatsapp_chat_thread_view;

  -- Recreate with explicit table aliases
  CREATE OR REPLACE VIEW whatsapp_chat_thread_view AS
  SELECT
      wcl.whatsapp_communication_log_id,
      wcl.rid,
      wcl.from_number,
      wcl.to_number,
      wcl.message_type,
      wcl.message_content,
      wcl.media_url,
      wcl.media_type,
      wcl.media_caption,
      wcl.status,
      wcl.direction,
      wcl.sent_by_user_id,
      wcl.date_created,
      COALESCE(wcp.contact_name, wcl.from_number) as sender_name,
      wcp.contact_avatar_url as sender_avatar,
      wcm.module_type,
      wcm.module_id
  FROM whatsapp_communication_log wcl
  LEFT JOIN whatsapp_contact_profile wcp ON wcl.rid = wcp.rid AND wcl.from_number = wcp.phone_number
  LEFT JOIN whatsapp_chat_module_mapping wcm ON wcl.rid = wcm.rid AND wcl.to_number = wcm.phone_number
  ORDER BY wcl.date_created;

  CREATE OR REPLACE VIEW whatsapp_conversation_list_view AS
  SELECT
      wcl.rid,
      wcl.to_number as phone_number,
      COALESCE(wcp.contact_name, wcl.to_number) as contact_name,
      wcp.contact_avatar_url,
      (SELECT message_content FROM whatsapp_communication_log
       WHERE rid = wcl.rid AND to_number = wcl.to_number
       ORDER BY date_created DESC LIMIT 1) as last_message,
      (SELECT direction FROM whatsapp_communication_log
       WHERE rid = wcl.rid AND to_number = wcl.to_number
       ORDER BY date_created DESC LIMIT 1) as last_message_direction,
      (SELECT date_created FROM whatsapp_communication_log
       WHERE rid = wcl.rid AND to_number = wcl.to_number
       ORDER BY date_created DESC LIMIT 1) as last_message_time,
      COUNT(*) as total_messages
  FROM whatsapp_communication_log wcl
  LEFT JOIN whatsapp_contact_profile wcp ON wcl.rid = wcp.rid AND wcl.to_number = wcp.phone_number
  GROUP BY wcl.rid, wcl.to_number
  ORDER BY last_message_time DESC;


  DROP VIEW IF EXISTS whatsapp_conversation_list_view;

  CREATE OR REPLACE VIEW whatsapp_conversation_list_view AS
  SELECT
      wcl.rid,
      wcl.to_number as phone_number,
      COALESCE(wcp.contact_name, wcl.to_number) as contact_name,
      wcp.contact_avatar_url,
      (SELECT message_content FROM whatsapp_communication_log
       WHERE rid = wcl.rid AND to_number = wcl.to_number
       ORDER BY date_created DESC LIMIT 1) as last_message,
      (SELECT direction FROM whatsapp_communication_log
       WHERE rid = wcl.rid AND to_number = wcl.to_number
       ORDER BY date_created DESC LIMIT 1) as last_message_direction,
      (SELECT date_created FROM whatsapp_communication_log
       WHERE rid = wcl.rid AND to_number = wcl.to_number
       ORDER BY date_created DESC LIMIT 1) as last_message_time,
      COUNT(*) as total_messages
  FROM whatsapp_communication_log wcl
  LEFT JOIN whatsapp_contact_profile wcp ON wcl.rid = wcp.rid AND wcl.to_number = wcp.phone_number
  GROUP BY wcl.rid, wcl.to_number
  ORDER BY last_message_time DESC;

-- ═══════════════════════════════════════════════════════════
-- Permissions & Constraints Summary
-- ═══════════════════════════════════════════════════════════

-- Each RID (customer) has:
-- ✓ Own WhatsApp settings (credentials)
-- ✓ Own chat messages (whatsapp_communication_log)
-- ✓ Own contact profiles
-- ✓ Own sync state

-- Multi-tenancy is enforced by RID in WHERE clauses
-- Example: SELECT * FROM whatsapp_communication_log WHERE rid = 123;


  ALTER TABLE `alpide-communication`.whatsapp_communication_log
  ADD COLUMN contact_name VARCHAR(255) COMMENT 'Contact name (lead name if linked, otherwise phone number)'
  AFTER to_number;