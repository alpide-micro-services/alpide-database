USE `alpide-crm`;

-- 1. Connection table
CREATE TABLE crm_google_calendar_connection (
    id                  BIGINT          NOT NULL AUTO_INCREMENT,
    relationship_id     BIGINT          NOT NULL,
    client_id           VARCHAR(255)    NOT NULL,
    client_secret       VARCHAR(255)    NOT NULL,
    google_user_id      VARCHAR(255),
    google_email        VARCHAR(255),
    access_token        TEXT,
    refresh_token       TEXT,
    token_expiry        DATETIME,
    connected           TINYINT(1)      DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uq_relationship_id (relationship_id)
);

-- 2. Settings table
CREATE TABLE crm_google_calendar_settings (
    id                      BIGINT          NOT NULL AUTO_INCREMENT,
    relationship_id         BIGINT          NOT NULL,
    work_start_time         VARCHAR(10)     DEFAULT '09:00',
    work_end_time           VARCHAR(10)     DEFAULT '18:00',
    buffer_minutes          INT             DEFAULT 15,
    notice_hours            INT             DEFAULT 2,
    slot_duration_minutes   INT             DEFAULT 30,
    timezone                VARCHAR(100)    DEFAULT 'UTC',
    PRIMARY KEY (id),
    UNIQUE KEY uq_relationship_id (relationship_id)
);

-- 3. Meeting table
CREATE TABLE crm_meeting (
    meeting_id          BIGINT          NOT NULL AUTO_INCREMENT,
    relationship_id     BIGINT          NOT NULL,
    lead_id             BIGINT,
    prospect_name       VARCHAR(255),
    prospect_email      VARCHAR(255),
    prospect_phone      VARCHAR(50),
    start_time          DATETIME,
    end_time            DATETIME,
    duration            INT,
    google_event_id     VARCHAR(255),
    timezone            VARCHAR(100),
    status              ENUM(
                            'SCHEDULED',
                            'CANCELLED',
                            'RESCHEDULED',
                            'NO_SHOW',
                            'COMPLETED'
                        )               DEFAULT 'SCHEDULED',
    reminder_sent       TINYINT(1)      DEFAULT 0,
    created_at          DATETIME,
    updated_at          DATETIME,
    PRIMARY KEY (meeting_id),
    INDEX idx_relationship_id   (relationship_id),
    INDEX idx_status            (status),
    INDEX idx_start_time        (start_time)
);
USE `alpide-crm`;

ALTER TABLE crm_google_calendar_settings
ADD COLUMN work_days_json    TEXT,
ADD COLUMN meeting_title     VARCHAR(255),
ADD COLUMN reminder_timing   VARCHAR(100),
ADD COLUMN reminder_channel  VARCHAR(100);

USE `alpide-crm`;
ALTER TABLE crm_meeting
ADD COLUMN company_name     VARCHAR(255),
ADD COLUMN description   VARCHAR(100);

USE `alpide-crm`;
ALTER TABLE crm_google_calendar_connection 
MODIFY COLUMN client_id VARCHAR(255) NULL,
MODIFY COLUMN client_secret VARCHAR(255) NULL;
