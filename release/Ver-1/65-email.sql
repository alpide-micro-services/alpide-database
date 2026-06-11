use `alpide-crm`;

-- Extend crm_meeting (existing table)
ALTER TABLE crm_meeting ADD COLUMN title VARCHAR(500);
ALTER TABLE crm_meeting ADD COLUMN meeting_type VARCHAR(20);
ALTER TABLE crm_meeting ADD COLUMN google_meet_link VARCHAR(500);
ALTER TABLE crm_meeting ADD COLUMN attendees TEXT;
ALTER TABLE crm_meeting ADD COLUMN created_by BIGINT;

-- Sent email audit log (Module 4)
CREATE TABLE crm_sent_email_log (
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    relationship_id      BIGINT,
    relationship_impl_id BIGINT,
    gmail_message_id     VARCHAR(255),
    recipient_email      VARCHAR(500),
    subject              VARCHAR(1000),
    body                 LONGTEXT,
    sent_at              DATETIME(6)
);