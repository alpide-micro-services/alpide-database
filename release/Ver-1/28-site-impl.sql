-- ============================================================
-- Hierarchical Structure Migration
-- Adds hierarchy columns to client_relationship.
-- Creates ref table, franchisee_terms, and OTP temp table.
-- ============================================================

-- 1. Add hierarchy columns to existing client_relationship table
ALTER TABLE `alpide-users`.client_relationship
    ADD COLUMN relationship_type  VARCHAR(50)  DEFAULT NULL COMMENT 'tenant | company | branch | franchisee',
  ADD COLUMN parent_rid         INT          DEFAULT NULL COMMENT 'FK to parent rid in same table',
  ADD COLUMN tenant_rid         INT          DEFAULT NULL COMMENT 'Root tenant rid for multi-tenancy filtering',
  ADD COLUMN metadata           JSON         DEFAULT NULL COMMENT '{"level":1,"status":"active","franchiseeModel":"franchise"}';

ALTER TABLE `alpide-users`.client_relationship
    ADD INDEX idx_cr_parent_rid        (parent_rid),
  ADD INDEX idx_cr_tenant_rid        (tenant_rid),
  ADD INDEX idx_cr_relationship_type (relationship_type);

-- 2. Explicit parent-child audit trail
CREATE TABLE IF NOT EXISTS `alpide-users`.client_relationship_hierarchy_ref (
                                                                                id                BIGINT AUTO_INCREMENT PRIMARY KEY,
                                                                                parent_rid        INT          NOT NULL COMMENT 'FK to client_relationship.rid',
                                                                                child_rid         INT          NOT NULL COMMENT 'FK to client_relationship.rid',
                                                                                relationship_type VARCHAR(100) NOT NULL COMMENT 'tenant_company | company_branch | branch_franchisee',
    created_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_parent_child (parent_rid, child_rid),
    INDEX idx_ref_type (relationship_type)
    );

-- 3. Franchisee-specific agreement terms
CREATE TABLE IF NOT EXISTS `alpide-users`.franchisee_terms (
                                                               id                    BIGINT        AUTO_INCREMENT PRIMARY KEY,
                                                               franchisee_rid        INT           NOT NULL UNIQUE COMMENT 'FK to client_relationship.rid',
                                                               parent_branch_rid     INT           NOT NULL COMMENT 'FK to client_relationship.rid',
                                                               commission_rate       DECIMAL(5, 2) NOT NULL,
    territory             VARCHAR(500)  NOT NULL,
    agreement_start_date  DATE          NOT NULL,
    agreement_end_date    DATE          DEFAULT NULL,
    status                VARCHAR(20)   DEFAULT 'active' COMMENT 'active | inactive | suspended',
    royalty_percentage    DECIMAL(5, 2) DEFAULT NULL,
    metadata              JSON          DEFAULT NULL,
    created_at            TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_ft_status    (status),
    INDEX idx_ft_territory (territory),
    INDEX idx_ft_parent    (parent_branch_rid)
    );

-- 4. Temporary OTP storage for child account email verification
CREATE TABLE IF NOT EXISTS `alpide-users`.email_verification_temp (
                                                                      verification_id BIGINT       AUTO_INCREMENT PRIMARY KEY,
                                                                      email           VARCHAR(255) NOT NULL,
    code            VARCHAR(10)  NOT NULL,
    parent_rid      INT          NOT NULL COMMENT 'FK to client_relationship.rid',
    attempt_count   TINYINT      DEFAULT 0,
    expires_at      TIMESTAMP    NOT NULL,
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_evt_email      (email),
    INDEX idx_evt_expires_at (expires_at)
    );
