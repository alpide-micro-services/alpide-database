-- =============================================================================
-- Subcontract PO Flow DDL
-- Covers: SC-PO header, material lines, service line, material issue slip,
--         subcontract receipt, QC inspection, vendor stock ledger, cost tracking
-- Aligned with: Alpide Multi-Step Subcontracting Workflow v1.0
-- =============================================================================

USE `alpide-purchase`;

-- -----------------------------------------------------------------------------
-- 1. subcontract_po_master
--    SC-PO header — one per external routing operation
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subcontract_po_master (
    sc_po_master_id         BIGINT          NOT NULL AUTO_INCREMENT,
    version                 INT             NOT NULL DEFAULT 0,
    sc_po_number            VARCHAR(100)    NULL,
    rid                     BIGINT          NOT NULL,
    work_order_id           BIGINT          NOT NULL,           -- FK to manufacturing work order
    work_order_number       VARCHAR(100)    NULL,
    routing_sequence        INT             NULL,               -- Seq number on routing (e.g. 50, 70)
    operation_code          VARCHAR(50)     NULL,               -- e.g. OP-005
    operation_name          VARCHAR(255)    NULL,               -- e.g. Fabrication / Stitching
    supplier_id               BIGINT          NOT NULL,           -- Supplier / Job Worker
    supplier_name             VARCHAR(255)    NULL,
    sc_po_date              TIMESTAMP        NULL,
    delivery_due_date       TIMESTAMP        NULL,
    expected_output_item_id BIGINT          NULL,  
             -- WIP or FG item expected back
             expected_output_variant_id BIGINT          NULL,  
    expected_output_item_name VARCHAR(255)  NULL,
    expected_qty            DOUBLE          DEFAULT 0,
    service_charge_per_unit DOUBLE          DEFAULT 0,
    total_service_charge    DOUBLE          DEFAULT 0,
    total_rm_cost           DOUBLE          DEFAULT 0,
    total_po_value          DOUBLE          DEFAULT 0,          -- RM cost + service charge
    currency_code           VARCHAR(10)     NULL,
    exchange_rate           DOUBLE          DEFAULT 1,
    status                  VARCHAR(50)     NULL,               -- draft/pending_approval/approved/rm_issued/partially_received/fully_received/closed/cancelled/amended
    status_color            VARCHAR(30)     NULL,
    user_status             VARCHAR(50)     NULL,
    user_status_color       VARCHAR(30)     NULL,
    is_auto_generated       INT             DEFAULT 1,          -- 1=auto from WO release, 0=manual
    is_approval_required    INT             DEFAULT 0,
    is_approved             INT             DEFAULT 0,
    is_rejected             INT             DEFAULT 0,
    rejection_reason        VARCHAR(500)    NULL,
    approved_by_emp_id      BIGINT          NULL,
    approver_emp_id         BIGINT          NULL,
    amendment_version       INT             DEFAULT 1,
    parent_sc_po_master_id  BIGINT          NULL,               -- for amendments — points to original
    remarks                 VARCHAR(1000)   NULL,
    reference               VARCHAR(255)    NULL,
    fy_start_date           TIMESTAMP        NULL,
    fy_end_date             TIMESTAMP        NULL,
    created_by_user_id      BIGINT          NULL,
    updated_by_user_id      BIGINT          NULL,
    created_by_emp_id       BIGINT          NULL,
    date_created            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    date_updated            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (sc_po_master_id),
    INDEX idx_scpo_rid              (rid),
    INDEX idx_scpo_vendor           (rid, supplier_id),
    INDEX idx_scpo_work_order       (rid, work_order_id),
    INDEX idx_scpo_status           (rid, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. subcontract_po_material_line
--    Materials (RM or WIP) to be issued to vendor for this SC-PO
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subcontract_po_material_line (
    sc_po_material_line_id  BIGINT          NOT NULL AUTO_INCREMENT,
    version                 INT             NOT NULL DEFAULT 0,
    sc_po_master_id         BIGINT         DEFAULT 0 ,
    rid                     BIGINT          NOT NULL,
    s_no                    INT             NULL,
    item_id                 BIGINT          NOT NULL,
    item_name               VARCHAR(255)    NULL,
    item_variant_id         BIGINT          NULL,
    sku                     VARCHAR(100)    NULL,
    attribute_value1        VARCHAR(100)    NULL,
    attribute_value2        VARCHAR(100)    NULL,
    uom_name                VARCHAR(50)     NULL,
    qty_to_issue            DOUBLE          DEFAULT 0,
    qty_issued              DOUBLE          DEFAULT 0,          -- updated on Material Issue Slip
    unit_cost               DOUBLE          DEFAULT 0,          -- weighted avg or standard cost
    extended_cost           DOUBLE          DEFAULT 0,          -- qty_to_issue x unit_cost
    routing_link_code       VARCHAR(50)     NULL,               -- links BOM material to routing op
    date_created            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    date_updated            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (sc_po_material_line_id),
    INDEX idx_scpo_mat_master       (sc_po_master_id, rid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. subcontract_material_issue_slip
--    Material Issue Slip — issues RM/WIP from Warehouse Stock to Vendor Stock
--    One slip per SC-PO (can be partial)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subcontract_material_issue_slip (
    issue_slip_id           BIGINT          NOT NULL AUTO_INCREMENT,
    version                 INT             NOT NULL DEFAULT 0,
    issue_slip_number       VARCHAR(100)    NULL,
    rid                     BIGINT          NOT NULL,
    sc_po_master_id         BIGINT          NOT NULL,
    supplier_id               BIGINT          NOT NULL,
    supplier_name             VARCHAR(255)    NULL,
    work_order_id           BIGINT          NULL,
    issue_date              TIMESTAMP        NULL,
    status                  VARCHAR(50)     NULL,               -- draft/posted/cancelled
    status_color            VARCHAR(30)     NULL,
    total_issue_cost        DOUBLE          DEFAULT 0,
    remarks                 VARCHAR(1000)   NULL,
    created_by_user_id      BIGINT          NULL,
    updated_by_user_id      BIGINT          NULL,
    date_created            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    date_updated            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (issue_slip_id),
    INDEX idx_mis_rid                (rid),
    INDEX idx_mis_scpo               (rid, sc_po_master_id),
    INDEX idx_mis_vendor             (rid, supplier_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. subcontract_material_issue_slip_details
--    Line items for each Material Issue Slip
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subcontract_material_issue_slip_details (
    issue_slip_details_id   BIGINT          NOT NULL AUTO_INCREMENT,
    version                 INT             NOT NULL DEFAULT 0,
    issue_slip_id           BIGINT          DEFAULT 0,
    sc_po_master_id         BIGINT          NOT NULL,
    rid                     BIGINT          NOT NULL,
    s_no                    INT             NULL,
    item_id                 BIGINT          NOT NULL,
    item_name               VARCHAR(255)    NULL,
    item_variant_id         BIGINT          NULL,
    sku                     VARCHAR(100)    NULL,
    uom_name                VARCHAR(50)     NULL,
    qty_issued              DOUBLE          DEFAULT 0,
    unit_cost               DOUBLE          DEFAULT 0,
    extended_cost           DOUBLE          DEFAULT 0,
    date_created            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (issue_slip_details_id),
    INDEX idx_mis_det_slip           (issue_slip_id, rid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. subcontract_vendor_stock
--    Vendor Stock ledger — tracks RM/WIP held at vendor (owned by factory)
--    Equivalent to SAP "Stock Provided to Vendor" / MT 541
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subcontract_vendor_stock (
    vendor_stock_id         BIGINT          NOT NULL AUTO_INCREMENT,
    version                 INT             NOT NULL DEFAULT 0,
    rid                     BIGINT          NOT NULL,
    supplier_id               BIGINT          NOT NULL,
    sc_po_master_id         BIGINT          NOT NULL,
    item_id                 BIGINT          NOT NULL,
    item_name               VARCHAR(255)    NULL,
    item_variant_id         BIGINT          NULL,
    sku                     VARCHAR(100)    NULL,
    uom_name                VARCHAR(50)     NULL,
    qty_issued              DOUBLE          DEFAULT 0,          -- total issued to vendor
    qty_returned            DOUBLE          DEFAULT 0,          -- returned (rejected/excess)
    qty_consumed            DOUBLE          DEFAULT 0,          -- consumed on GRN posting
    qty_balance             DOUBLE          DEFAULT 0,          -- qty_issued - qty_returned - qty_consumed
    unit_cost               DOUBLE          DEFAULT 0,
    total_cost              DOUBLE          DEFAULT 0,          -- qty_balance x unit_cost
    status                  VARCHAR(50)     NULL,               -- open/cleared
    date_created            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    date_updated            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (vendor_stock_id),
    INDEX idx_vs_rid                 (rid),
    INDEX idx_vs_vendor_item         (rid, supplier_id, item_id),
    INDEX idx_vs_scpo                (rid, sc_po_master_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. subcontract_receipt_master
--    Subcontract Receipt — vendor returns processed goods
--    Triggers QC inspection before GRN is posted
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subcontract_receipt_master (
    sc_receipt_master_id    BIGINT          NOT NULL AUTO_INCREMENT,
    version                 INT             NOT NULL DEFAULT 0,
    sc_receipt_number       VARCHAR(100)    NULL,
    rid                     BIGINT          NOT NULL,
    sc_po_master_id         BIGINT          NOT NULL,
    supplier_id               BIGINT          NOT NULL,
    supplier_name             VARCHAR(255)    NULL,
    work_order_id           BIGINT          NULL,
    receipt_date            TIMESTAMP        NULL,
    qty_received            DOUBLE          DEFAULT 0,
    qty_accepted            DOUBLE          DEFAULT 0,          -- after QC
    qty_rejected            DOUBLE          DEFAULT 0,          -- after QC
    output_item_id          BIGINT          NULL,               -- WIP or FG item received
    output_item_name        VARCHAR(255)    NULL,
    output_item_variant_id  BIGINT          NULL,
    uom_name                VARCHAR(50)     NULL,
    qc_status               VARCHAR(50)     NULL,               -- pending/accepted/partially_accepted/rejected
    qc_remarks              VARCHAR(1000)   NULL,
    rejection_reason        VARCHAR(500)    NULL,
    grn_posted              INT             DEFAULT 0,          -- 1 = GRN posted
    grn_number              VARCHAR(100)    NULL,
    status                  VARCHAR(50)     NULL,               -- draft/qc_pending/qc_done/grn_posted/cancelled
    status_color            VARCHAR(30)     NULL,
    remarks                 VARCHAR(1000)   NULL,
    created_by_user_id      BIGINT          NULL,
    updated_by_user_id      BIGINT          NULL,
    date_created            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    date_updated            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (sc_receipt_master_id),
    INDEX idx_scr_rid                (rid),
    INDEX idx_scr_scpo               (rid, sc_po_master_id),
    INDEX idx_scr_vendor             (rid, supplier_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 7. subcontract_cost_entry
--    Cost accumulation per SC-PO — RM cost + vendor service charge
--    Rolled up to Work Order on SC-PO closure
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subcontract_cost_entry (
    sc_cost_entry_id        BIGINT          NOT NULL AUTO_INCREMENT,
    version                 INT             NOT NULL DEFAULT 0,
    rid                     BIGINT          NOT NULL,
    sc_po_master_id         BIGINT          NOT NULL,
    work_order_id           BIGINT          NULL,
    cost_element            VARCHAR(100)    NULL,               -- rm_cost / vendor_service_charge / wip_cost
    source_document         VARCHAR(100)    NULL,               -- issue_slip_number / sc_po_number
    qty                     DOUBLE          DEFAULT 0,
    unit_cost               DOUBLE          DEFAULT 0,
    total_cost              DOUBLE          DEFAULT 0,
    date_created            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (sc_cost_entry_id),
    INDEX idx_sce_rid                (rid),
    INDEX idx_sce_scpo               (rid, sc_po_master_id),
    INDEX idx_sce_wo                 (rid, work_order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 8. tx_conversion_wo_to_scpo_ref
--    Conversion tracking: Work Order → Subcontract PO
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tx_conversion_wo_to_scpo_ref (
    wo_to_scpo_ref_id       BIGINT          NOT NULL AUTO_INCREMENT,
    version                 INT             NOT NULL DEFAULT 0,
    rid                     BIGINT          NOT NULL,
    work_order_id           BIGINT          NOT NULL,
    sc_po_master_id         BIGINT          NOT NULL,
    routing_sequence        INT             NULL,
    date_created            TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (wo_to_scpo_ref_id),
    INDEX idx_wo_scpo_ref            (rid, work_order_id, sc_po_master_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `alpide-purchase`.`subcontract_po_master` 
ADD COLUMN `expected_output_variant_id` BIGINT NULL AFTER `date_updated`;

-- =====================================================
-- ALTER EXISTING TABLE
-- supplier_inbound_delivery_master
-- =====================================================

ALTER TABLE supplier_inbound_delivery_master
ADD COLUMN is_subcontract_grn INT DEFAULT 0,
ADD COLUMN sc_po_master_id BIGINT,
ADD COLUMN sc_po_number VARCHAR(100);



-- =====================================================
-- CREATE NEW TABLE
-- inbound_delivery_sc_po_ref
-- =====================================================

CREATE TABLE inbound_delivery_sc_po_ref (

    inbound_delivery_sc_po_ref_id BIGINT PRIMARY KEY AUTO_INCREMENT,

    relationship_id BIGINT NOT NULL,

    inbound_delivery_master_id BIGINT NOT NULL,

    sc_po_master_id BIGINT NOT NULL,

    sc_po_number VARCHAR(100),

    expected_output_item_id BIGINT,

    inventory_item_variant_id BIGINT,

    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,

    date_updated DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_id_scpo_inbound_delivery
        FOREIGN KEY (inbound_delivery_master_id)
        REFERENCES supplier_inbound_delivery_master(inbound_delivery_master_id),

    CONSTRAINT fk_id_scpo_master
        FOREIGN KEY (sc_po_master_id)
        REFERENCES subcontract_po_master(sc_po_master_id)

);

ALTER TABLE `alpide-purchase`.`inbound_delivery_sc_po_ref` 
DROP FOREIGN KEY `fk_id_scpo_inbound_delivery`,
DROP FOREIGN KEY `fk_id_scpo_master`;
ALTER TABLE `alpide-purchase`.`inbound_delivery_sc_po_ref` 
CHANGE COLUMN `inbound_delivery_master_id` `inbound_delivery_master_id` BIGINT NULL DEFAULT '0' ,
CHANGE COLUMN `sc_po_master_id` `sc_po_master_id` BIGINT NULL DEFAULT '0' ;
ALTER TABLE `alpide-purchase`.`inbound_delivery_sc_po_ref` 
ADD CONSTRAINT `fk_id_scpo_inbound_delivery`
  FOREIGN KEY (`inbound_delivery_master_id`)
  REFERENCES `alpide-purchase`.`supplier_inbound_delivery_master` (`inbound_delivery_master_id`),
ADD CONSTRAINT `fk_id_scpo_master`
  FOREIGN KEY (`sc_po_master_id`)
  REFERENCES `alpide-purchase`.`subcontract_po_master` (`sc_po_master_id`);


ALTER TABLE `alpide-purchase`.`subcontract_po_master` 
ADD COLUMN `expected_output_item_sku` VARCHAR(45) NULL AFTER `date_updated`;


ALTER TABLE `alpide-inventory`.`inventory_item` 
ADD COLUMN `is_semi_finished_goods` INT NULL DEFAULT '0' AFTER `is_active`;

