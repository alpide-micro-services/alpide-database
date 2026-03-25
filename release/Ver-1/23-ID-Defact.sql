
USE `alpide-purchase`;






CREATE TABLE IF NOT EXISTS supplier_inbound_delivery_defect_master (
                                                                       defect_master_id        BIGINT          NOT NULL AUTO_INCREMENT,
                                                                       version                 INT             NOT NULL DEFAULT 0,
                                                                       defect_number           VARCHAR(50)     NULL,
    rid                     BIGINT          NOT NULL,
    supplier_id             BIGINT          NULL,
    inbound_delivery_master_id BIGINT       NULL,
    po_master_id            BIGINT          NULL,
    created_by_emp_id       BIGINT          NULL,
    defect_date             DATETIME        NULL,
    status                  VARCHAR(50)     NULL,
    status_color            VARCHAR(20)     NULL,
    user_status             VARCHAR(50)     NULL,
    user_status_color       VARCHAR(20)     NULL,
    defect_reason           VARCHAR(500)    NULL,
    defect_action           VARCHAR(500)    NULL,
    total_defect_qty        DOUBLE          DEFAULT 0,
    total_defect_amount     DOUBLE          DEFAULT 0,
    remarks                 VARCHAR(1000)   NULL,
    created_by_user_id      BIGINT          NULL,
    updated_by_user_id      BIGINT          NULL,
    date_created            DATETIME        DEFAULT CURRENT_TIMESTAMP,
    date_updated            DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (defect_master_id)

    KEY idx_defect_details_master (defect_master_id, rid)
    INDEX `idx_defect_master_rid` (`defect_master_id`, `rid`) COMMENT 'Composite index for FK reference from details table',
    INDEX `idx_rid_supplier` (`rid`, `supplier_id`) COMMENT 'Composite index for tenant and supplier queries',
    INDEX `idx_inbound_delivery` (`inbound_delivery_master_id`) COMMENT 'Index for GRN lookup',
    INDEX `idx_po_master` (`po_master_id`) COMMENT 'Index for PO lookup',
    INDEX `idx_defect_number` (`defect_number`) COMMENT 'Index for defect number search',
    INDEX `idx_defect_date` (`defect_date`) COMMENT 'Index for date range queries',
    INDEX `idx_status` (`status`) COMMENT 'Index for status filtering'
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. supplier_inbound_delivery_defect_details
--    (line items per defect master — one row per item/variant)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS supplier_inbound_delivery_defect_details (
                                                                        defect_details_id           BIGINT          NOT NULL AUTO_INCREMENT,
                                                                        version                     INT             NOT NULL DEFAULT 0,
                                                                        defect_master_id            BIGINT          NOT NULL,
                                                                        rid                         BIGINT          NOT NULL,
                                                                        inbound_delivery_details_id BIGINT          NULL,
                                                                        item_id                     BIGINT          NULL,
                                                                        item_variant_id             BIGINT          NULL,
                                                                        sku                         VARCHAR(100)    NULL,
    attribute_value1            VARCHAR(100)    NULL,
    attribute_value2            VARCHAR(100)    NULL,
    attribute_value3            VARCHAR(100)    NULL,
    attribute_id1               BIGINT          NULL,
    attribute_id2               BIGINT          NULL,
    attribute_id3               BIGINT          NULL,
    qty_defect                  DOUBLE          DEFAULT 0,
    qty_from_grn                DOUBLE          DEFAULT 0,
    purchase_price              DOUBLE          DEFAULT 0,
    defect_amount               DOUBLE          DEFAULT 0,
    is_variant                  TINYINT         DEFAULT 0,
    defect_type                 VARCHAR(100)    NULL,
    defect_description          VARCHAR(1000)   NULL,
    date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (defect_details_id),

    -- Indexes for performance
    INDEX `idx_defect_master` (`defect_master_id`, `rid`) COMMENT 'Composite index for master lookup',
    INDEX `idx_inbound_delivery_details` (`inbound_delivery_details_id`) COMMENT 'Index for GRN detail lookup',
    INDEX `idx_item` (`item_id`) COMMENT 'Index for item queries',
    INDEX `idx_item_variant` (`item_variant_id`) COMMENT 'Index for variant queries',
    INDEX `idx_sku` (`sku`) COMMENT 'Index for SKU search'

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    COMMENT='Detail lines for defect records - individual defective items';




-- ============================================================================
-- 2. SUPPLIER INBOUND DELIVERY DEFECT DETAILS TABLE
-- ============================================================================
-- Line items for defect records - tracks individual defective items
-- Links to GRN details and contains item-specific defect information
-- ============================================================================

CREATE TABLE IF NOT EXISTS `supplier_inbound_delivery_defect_details` (
                                                                          `defect_details_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'Primary key for defect detail line',
                                                                          `version` INT DEFAULT NULL DEFAULT 0 COMMENT 'Optimistic locking version field',
                                                                          `defect_master_id` BIGINT DEFAULT NULL COMMENT 'Foreign key to defect master',
                                                                          `rid` BIGINT DEFAULT NULL COMMENT 'Relationship ID - must match master record',
                                                                          `inbound_delivery_details_id` BIGINT DEFAULT NULL COMMENT 'Foreign key to GRN detail line',
                                                                          `item_id` BIGINT DEFAULT NULL COMMENT 'Foreign key to inventory item master',
                                                                          `item_variant_id` BIGINT DEFAULT NULL COMMENT 'Foreign key to item variant (if applicable)',
                                                                          `sku` VARCHAR(100) DEFAULT NULL COMMENT 'Stock Keeping Unit code',
    `attribute_value1` VARCHAR(255) DEFAULT NULL COMMENT 'First variant attribute value (e.g., Size)',
    `attribute_value2` VARCHAR(255) DEFAULT NULL COMMENT 'Second variant attribute value (e.g., Color)',
    `attribute_value3` VARCHAR(255) DEFAULT NULL COMMENT 'Third variant attribute value',
    `attribute_id1` BIGINT DEFAULT NULL COMMENT 'First attribute ID',
    `attribute_id2` BIGINT DEFAULT NULL COMMENT 'Second attribute ID',
    `attribute_id3` BIGINT DEFAULT NULL COMMENT 'Third attribute ID',
    `qty_defect` DOUBLE DEFAULT 0 COMMENT 'Quantity of defective items',
    `qty_from_grn` DOUBLE NOT NULL DEFAULT 0 COMMENT 'Original quantity received in GRN',
    `purchase_price` DOUBLE NOT NULL DEFAULT 0 COMMENT 'Unit purchase price',
    `defect_amount` DOUBLE NOT NULL DEFAULT 0 COMMENT 'Total defect amount (qty_defect * purchase_price)',
    `is_variant` INT NOT NULL DEFAULT 0 COMMENT 'Flag: 1 if item has variants, 0 otherwise',
    `defect_type` VARCHAR(100) DEFAULT NULL COMMENT 'Type of defect (e.g., Physical Damage, Quality Issue)',
    `defect_description` TEXT DEFAULT NULL COMMENT 'Detailed description of the defect',
    `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',

    PRIMARY KEY (`defect_details_id`),

    -- Indexes for performance
    INDEX `idx_defect_master` (`defect_master_id`, `rid`) COMMENT 'Composite index for master lookup',
    INDEX `idx_inbound_delivery_details` (`inbound_delivery_details_id`) COMMENT 'Index for GRN detail lookup',
    INDEX `idx_item` (`item_id`) COMMENT 'Index for item queries',
    INDEX `idx_item_variant` (`item_variant_id`) COMMENT 'Index for variant queries',
    INDEX `idx_sku` (`sku`) COMMENT 'Index for SKU search'

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    COMMENT='Detail lines for defect records - individual defective items';


-- ============================================================================
-- 3. TX CONVERSION ID TO DEFECT REF TABLE
-- ============================================================================
-- Transaction conversion tracking table
-- Maintains the relationship chain: PO → GRN → Defect
-- Enables traceability and reporting across the procurement flow
-- ============================================================================

CREATE TABLE IF NOT EXISTS `tx_conversion_id_to_defect_ref` (
                                                                `tx_conversion_id_to_defect_ref_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
                                                                `version` INT NOT NULL DEFAULT 0 COMMENT 'Optimistic locking version field',
                                                                `rid` BIGINT NOT NULL COMMENT 'Relationship ID - tenant identifier',
                                                                `supplier_id` BIGINT DEFAULT NULL COMMENT 'Foreign key to supplier',
                                                                `inbound_delivery_master_id` BIGINT DEFAULT NULL COMMENT 'Foreign key to GRN master',
                                                                `defect_master_id` BIGINT DEFAULT NULL COMMENT 'Foreign key to defect master',
                                                                `po_master_id` BIGINT DEFAULT NULL COMMENT 'Foreign key to PO master',
                                                                `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',

                                                                PRIMARY KEY (`tx_conversion_id_to_defect_ref_id`),

    -- Indexes for lookup performance
    INDEX `idx_rid_grn` (`rid`, `inbound_delivery_master_id`) COMMENT 'Index for GRN-based queries',
    INDEX `idx_rid_defect` (`rid`, `defect_master_id`) COMMENT 'Index for defect-based queries',
    INDEX `idx_rid_po` (`rid`, `po_master_id`) COMMENT 'Index for PO-based queries',
    INDEX `idx_supplier` (`supplier_id`) COMMENT 'Index for supplier queries',

    -- Unique constraint to prevent duplicate conversions
    UNIQUE KEY `uk_grn_defect` (`rid`, `inbound_delivery_master_id`, `defect_master_id`)
    COMMENT 'Ensures one-to-one mapping between GRN and Defect'

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    COMMENT='Transaction conversion reference - tracks PO to GRN to Defect relationships';


-- ============================================================================
-- 4. SUPPLIER INBOUND DELIVERY DEFECT DRAFT TABLE
-- ============================================================================
-- Stores work-in-progress defect records
-- Allows users to save incomplete defect entries and resume later
-- Uses JSON format for flexible draft data storage
-- ============================================================================

CREATE TABLE IF NOT EXISTS `supplier_inbound_delivery_defect_draft` (
                                                                        `defect_draft_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'Primary key for draft record',
                                                                        `rid` BIGINT NOT NULL COMMENT 'Relationship ID - tenant identifier',
                                                                        `supplier_id` BIGINT DEFAULT NULL COMMENT 'Foreign key to supplier',
                                                                        `inbound_delivery_master_id` BIGINT DEFAULT NULL COMMENT 'Foreign key to GRN master',
                                                                        `draft_data` TEXT DEFAULT NULL COMMENT 'JSON-formatted draft data',
                                                                        `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Draft creation timestamp',
                                                                        `date_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',

                                                                        PRIMARY KEY (`defect_draft_id`),

    -- Indexes
    INDEX `idx_rid_supplier` (`rid`, `supplier_id`) COMMENT 'Index for tenant and supplier queries',
    INDEX `idx_inbound_delivery` (`inbound_delivery_master_id`) COMMENT 'Index for GRN lookup',

    -- Unique constraint - one draft per GRN
    UNIQUE KEY `uk_rid_grn` (`rid`, `inbound_delivery_master_id`)
    COMMENT 'Ensures only one draft per GRN'

    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    COMMENT='Draft storage for incomplete defect records';


-- ============================================================================
-- 5. ALTER EXISTING TABLES (IF NEEDED)
-- ============================================================================
-- Add defect-related columns to GRN master table
-- These columns track defect status at the GRN level
-- ============================================================================

-- Check if columns exist before adding (MySQL 5.7+ compatible approach)
-- Run these statements individually and ignore errors if columns already exist

ALTER TABLE `supplier_inbound_delivery_master`
    ADD COLUMN `status_defect` VARCHAR(50) DEFAULT NULL COMMENT 'Defect-specific status';

ALTER TABLE `supplier_inbound_delivery_master`
    ADD COLUMN `status_color_defect` VARCHAR(20) DEFAULT NULL COMMENT 'Color code for defect status';

ALTER TABLE `supplier_inbound_delivery_master`
    ADD COLUMN `is_defect_recorded` INT NOT NULL DEFAULT 0 COMMENT 'Flag: 1 if defects recorded, 0 otherwise';

-- Add index for defect flag queries
ALTER TABLE `supplier_inbound_delivery_master`
    ADD INDEX `idx_is_defect_recorded` (`is_defect_recorded`);



DELIMITER $$

DROP PROCEDURE IF EXISTS `get_defect_summary`$$

CREATE PROCEDURE `get_defect_summary`(
    IN p_rid BIGINT,
    IN p_page_number INT,
    IN p_page_size INT,
    IN p_filters JSON
)
BEGIN
    DECLARE v_offset INT;
    DECLARE v_supplier_id BIGINT;
    DECLARE v_status VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_user_status VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_defect_number VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_from_date DATE;
    DECLARE v_to_date DATE;

    -- Calculate offset for pagination
    SET v_offset = p_page_number * p_page_size;

    -- Extract filter values from JSON (if provided)
    IF p_filters IS NOT NULL THEN
        SET v_supplier_id = JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.supplierId'));
        SET v_status = JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.status'));
        SET v_user_status = JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.userStatus'));
        SET v_defect_number = JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.defectNumber'));

        -- Handle date fields properly - convert 'null' string to NULL using NULLIF
        SET v_from_date = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.fromDate')), NULL);
        SET v_to_date = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.toDate')), NULL);
END IF;

    -- Main query with filters
SELECT
    dm.defect_master_id,
    dm.defect_number,
    dm.rid,
    dm.supplier_id,
    dm.defect_date,
    dm.total_defect_qty,
    dm.total_defect_amount,
    dm.status,
    dm.status_color,
    dm.user_status,
    sm.supplier_company_name,
    gm.inbound_delivery_number,
    dm.date_created
FROM
    supplier_inbound_delivery_defect_master dm
        LEFT JOIN
    suppliers sm ON dm.supplier_id = sm.supplier_id AND dm.rid = sm.rid
        LEFT JOIN
    supplier_inbound_delivery_master gm ON dm.inbound_delivery_master_id = gm.inbound_delivery_master_id
        AND dm.rid = gm.rid
WHERE
    dm.rid = p_rid
  AND (v_supplier_id IS NULL OR v_supplier_id = 'null' OR dm.supplier_id = v_supplier_id)
  AND (v_status IS NULL OR v_status = 'null' OR dm.status = v_status)
  AND (v_user_status IS NULL OR v_user_status = 'null' OR dm.user_status = v_user_status)
  AND (v_defect_number IS NULL OR v_defect_number = 'null' OR dm.defect_number LIKE CONCAT('%', v_defect_number, '%'))
  AND (v_from_date IS NULL OR v_from_date = null OR DATE(dm.defect_date) >= v_from_date)
       AND (v_to_date IS NULL OR v_to_date = null OR DATE(dm.defect_date) <= v_to_date)
ORDER BY
    dm.date_created DESC
    LIMIT
    v_offset, p_page_size;

END$$

DELIMITER ;


-- ============================================================================
-- 7.2 COUNT DEFECT SUMMARY
-- ============================================================================
-- Returns total count of defects matching the filter criteria
-- Used for pagination
-- ============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS `count_defect_summary`$$

CREATE PROCEDURE `count_defect_summary`(
    IN p_rid BIGINT,
    IN p_filters JSON
)
BEGIN
    DECLARE v_supplier_id BIGINT;
    DECLARE v_status VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_user_status VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_defect_number VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_from_date DATE;
    DECLARE v_to_date DATE;

    -- Extract filter values from JSON (if provided)
    IF p_filters IS NOT NULL THEN
        SET v_supplier_id = JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.supplierId'));
        SET v_status = JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.status'));
        SET v_user_status = JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.userStatus'));
        SET v_defect_number = JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.defectNumber'));

        -- Handle date fields properly - convert 'null' string to NULL using NULLIF
        SET v_from_date = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.fromDate')), null);
        SET v_to_date = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_filters, '$.toDate')), null);
END IF;

    -- Count query with same filters
SELECT
    COUNT(*) as total_count
FROM
    supplier_inbound_delivery_defect_master dm
WHERE
    dm.rid = p_rid
  AND (v_supplier_id IS NULL OR v_supplier_id = 'null' OR dm.supplier_id = v_supplier_id)
  AND (v_status IS NULL OR v_status = 'null' OR dm.status = v_status)
  AND (v_user_status IS NULL OR v_user_status = 'null' OR dm.user_status = v_user_status)
  AND (v_defect_number IS NULL OR v_defect_number = 'null' OR dm.defect_number LIKE CONCAT('%', v_defect_number, '%'))
  AND (v_from_date IS NULL OR v_from_date = null OR DATE(dm.defect_date) >= v_from_date)
        AND (v_to_date IS NULL OR v_to_date = null OR DATE(dm.defect_date) <= v_to_date);

END$$

DELIMITER ;



-- -----------------------------------------------------------------------------
-- 3. defect_disposition
--    (one record per disposition action: scrap | rework | debit_memo)
--    Multiple dispositions can exist per defect master (partial qty support)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS defect_disposition (
                                                  disposition_id          BIGINT          NOT NULL AUTO_INCREMENT,
                                                  version                 INT             NOT NULL DEFAULT 0,
                                                  rid                     BIGINT          NOT NULL,
                                                  defect_master_id        BIGINT          NOT NULL,
                                                  supplier_id             BIGINT          NULL,
                                                  disposition_type        VARCHAR(50)     NOT NULL COMMENT 'scrap | rework | debit_memo',
    disposition_number      VARCHAR(50)     NULL,
    total_qty               DOUBLE          DEFAULT 0,
    total_amount            DOUBLE          DEFAULT 0,
    debit_memo_master_id    BIGINT          NULL COMMENT 'populated when disposition_type = debit_memo',
    remarks                 VARCHAR(1000)   NULL,
    status                  VARCHAR(50)     NULL,
    status_color            VARCHAR(20)     NULL,
    created_by_user_id      BIGINT          NULL,
    disposition_date        DATETIME        NULL,
    date_created            DATETIME        DEFAULT CURRENT_TIMESTAMP,
    date_updated            DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (disposition_id),
    KEY idx_disposition_defect (defect_master_id, rid),
    KEY idx_disposition_type (rid, disposition_type)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. defect_disposition_details
--    (line items per disposition — tracks partial qty per defect detail line)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS defect_disposition_details (
                                                          disposition_details_id  BIGINT          NOT NULL AUTO_INCREMENT,
                                                          version                 INT             NOT NULL DEFAULT 0,
                                                          disposition_id          BIGINT          ,
                                                          rid                     BIGINT          NOT NULL,
                                                          defect_details_id       BIGINT          NULL COMMENT 'ref to original defect detail line',
                                                          item_id                 BIGINT          NULL,
                                                          item_variant_id         BIGINT          NULL,
                                                          sku                     VARCHAR(100)    NULL,
    attribute_value1        VARCHAR(100)    NULL,
    attribute_value2        VARCHAR(100)    NULL,
    attribute_value3        VARCHAR(100)    NULL,
    attribute_id1           BIGINT          NULL,
    attribute_id2           BIGINT          NULL,
    attribute_id3           BIGINT          NULL,
    qty_disposition         DOUBLE          DEFAULT 0,
    purchase_price          DOUBLE          DEFAULT 0,
    disposition_amount      DOUBLE          DEFAULT 0,
    is_variant              TINYINT         DEFAULT 0,
    date_created            DATETIME        DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (disposition_details_id),
    KEY idx_disp_details_disposition (disposition_id, rid),
    KEY idx_disp_details_defect (defect_details_id, rid)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. supplier_coa_tx_defect_disposition
--    (COA / ledger entries for defect transactions)
--    Used at 4 levels:
--      - defect master     (defect_master_id set, others null)
--      - defect details    (defect_details_id set, others null)
--      - disposition master (disposition_id set, disposition_details_id null)
--      - disposition detail (disposition_id + disposition_details_id both set)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS supplier_coa_tx_defect_disposition (
                                                                  coa_tx_disposition_id   BIGINT          NOT NULL AUTO_INCREMENT,
                                                                  version                 INT             NOT NULL DEFAULT 0,
                                                                  rid                     BIGINT          NOT NULL,
                                                                  disposition_id          BIGINT          NULL,
                                                                  disposition_details_id  BIGINT          NULL,
                                                                  defect_master_id        BIGINT          NULL,
                                                                  defect_details_id       BIGINT          NULL,
                                                                  supplier_id             BIGINT          NULL,
                                                                  tx_type                 VARCHAR(50)     NULL COMMENT 'scrap | rework | debit_memo | defect_record',
    disposition_number      VARCHAR(50)     NULL,
    ledger_account_id       BIGINT          NULL,
    accounting_entry        VARCHAR(5)      NULL COMMENT 'DR | CR',
    amount                  DOUBLE          DEFAULT 0,
    amount_percent          DOUBLE          DEFAULT 0,
    tax_id                  BIGINT          NULL,
    tax_name                VARCHAR(100)    NULL,
    cost_center_id          BIGINT          NULL,
    created_by              BIGINT          NULL,
    tx_date                 DATETIME        NULL,
    fy_start_date           DATETIME        NULL,
    fy_end_date             DATETIME        NULL,
    date_created            DATETIME        DEFAULT CURRENT_TIMESTAMP,
    date_updated            DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (coa_tx_disposition_id),
    KEY idx_coa_defect_disposition (disposition_id, rid),
    KEY idx_coa_defect_master (defect_master_id, rid),
    KEY idx_coa_defect_details (defect_details_id, rid)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
