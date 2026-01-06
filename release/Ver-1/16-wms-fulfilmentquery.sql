ALTER TABLE `alpide-sales`.wms_pick_task_details 
ADD COLUMN qty_packed Double DEFAULT 0.0;



ALTER TABLE `alpide-sales`.customer_so_package_master 
ADD COLUMN pick_task_master_id BIGINT DEFAULT null;



ALTER TABLE `alpide-sales`.customer_so_package_details 
ADD COLUMN pick_task_detail_id BIGINT DEFAULT null;

ALTER TABLE `alpide-sales`.customer_so_package_details 
ADD COLUMN package_unit_id BIGINT DEFAULT null;

ALTER TABLE `alpide-sales`.customer_so_package_details 
ADD COLUMN package_name varchar(255) DEFAULT null;

ALTER TABLE `alpide-sales`.customer_so_package_details 
ADD COLUMN dimension varchar(255) DEFAULT null;

ALTER TABLE `alpide-sales`.customer_so_package_details 
ADD COLUMN weight varchar(255) DEFAULT null;

CREATE TABLE `alpide-inventory`.`inventory_item_varaint_stock_deduction_ref` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `item_variant_stock_id` BIGINT DEFAULT NULL,
  `quantity` DOUBLE DEFAULT NULL,
  `storage_bin_id` BIGINT DEFAULT NULL,
  `inventory_item_variant_id` BIGINT DEFAULT NULL,
  `item_id` BIGINT DEFAULT NULL,
  `master_id` BIGINT DEFAULT NULL,
  `txn_name` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
);
ALTER TABLE `alpide-inventory`.inventory_item_varaint_stock_deduction_ref 
ADD COLUMN detail_id BIGINT DEFAULT null;


ALTER TABLE `alpide-inventory`.inventory_item_varaint_stock_deduction_ref 
ADD COLUMN detail_id BIGINT DEFAULT null;

ALTER TABLE `alpide-inventory`.inventory_item_varaint_stock_deduction_ref 
ADD COLUMN detail_id BIGINT DEFAULT null;

ALTER TABLE `alpide-inventory`.inventory_item_varaint_stock_deduction_ref 
ADD COLUMN detail_id BIGINT DEFAULT null;

ALTER TABLE `alpide-purchase`.supplier_inbound_delivery_packing_unit_ref_child 
ADD COLUMN package_unit_id BIGINT DEFAULT null;

ALTER TABLE `alpide-purchase`.supplier_inbound_delivery_packing_unit_ref_child 
ADD COLUMN storage_bin_id BIGINT DEFAULT null;

ALTER TABLE `alpide-purchase`.supplier_inbound_delivery_packing_unit_ref_child 
ADD COLUMN storage_type_id BIGINT DEFAULT null;

ALTER TABLE `alpide-purchase`.`packing_unit_putaway_ref` 
CHANGE COLUMN `quantity` `quantity` DOUBLE NOT NULL ;


ALTER TABLE `alpide-inventory`.inventory_warehouse_master 
ADD COLUMN sales_person_id BIGINT DEFAULT null;

ALTER TABLE `alpide-inventory`.inventory_warehouse_master 
ADD COLUMN sales_person_name VARCHAR(255) DEFAULT null;

ALTER TABLE `alpide-crm`.`crm_lead` 
CHANGE COLUMN `date_updated` `date_updated` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ;

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
    IN stageStatusName VARCHAR(100)
)
BEGIN
    DECLARE whereClause TEXT;
    DECLARE idList VARCHAR(255);

    SET whereClause = CONCAT("cl.rid=", p_rid);
    SET whereClause = CONCAT(whereClause, " AND cl.is_active='", isActive, "'");
	-- Search filter 
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

SET @stmt = 'SELECT 
	DISTINCT cl.crm_lead_id AS crmLeadId,
	cl.rid AS relationshipId,
	cl.lead_name AS leadName,
	cl.is_active AS isActive,
	cl.industry_code AS industryCode,
	cl.industry_name AS industryName,
	cl.company_type_code AS companyTypeCode,
	cl.company_type_name AS companyTypeName,
	cl.website AS website,
	cl.lead_source_name AS leadSourceName, 
	cl.is_existing_lead AS isExistingLead,
	cl.has_lead_contacted AS hasLeadContacted,
	cl.status_name AS statusName,
	cl.has_proposal_sent AS hasProposalSent,
	cl.remarks AS remarks,
	cl.lead_source_id AS leadSourceId,
	cl.date_created AS dateCreated,
	cl.date_updated AS dateUpdated,
	cl.created_by AS createdBy,
	cl.updated_by AS updatedBy,
	cl.status_color_for_ui_cell AS statusColorForUiCell,
	cl.status_id AS statusId,
	cl.star_rating AS starRating,
	cl.created_by_emp_id AS createdByEmpId,
	cl.updated_by_emp_id AS updatedByEmpId,
	cl.form_name AS formName,
	cl.crm_lead_form_setting_id AS crmLeadFormSettingId,
	cl.is_lead_to_customer AS isLeadToCustomer,
	clr.reminder_title AS reminderTitle, 
	ld.full_name AS fullName,
	ld.email AS email,
	ld.mobile_no AS mobileNo,
	COALESCE(cln.notesCount, 0) AS totalNotes,
    cl.stage_status_name AS stageStatusName

	FROM crm_lead cl 
		LEFT JOIN crm_lead_reminder clr ON cl.crm_lead_id = clr.crm_lead_id
		LEFT JOIN (
			SELECT crm_lead_id, COUNT(*) AS notesCount
			FROM crm_lead_notes
			GROUP BY crm_lead_id
		) cln ON cl.crm_lead_id = cln.crm_lead_id
		LEFT JOIN crm_lead_emp_assigned clea ON cl.crm_lead_id = clea.crm_lead_id 
		LEFT JOIN crm_lead_form_setting clfs ON cl.crm_lead_form_setting_id = clfs.crm_lead_form_setting_id
		LEFT JOIN (
			SELECT crm_lead_id,
				MAX(CASE WHEN label = "Full Name" THEN value END) AS "full_name",
				MAX(CASE WHEN label = "Email" THEN value END) AS "email",
				MAX(CASE WHEN label = "Mobile No." THEN value END) AS "mobile_no"
			FROM crm_lead_detail 
			GROUP BY crm_lead_id
		) ld ON cl.crm_lead_id = ld.crm_lead_id
	WHERE ';


    SET @stmt1 = CONCAT(@stmt, whereClause, ' ORDER BY cl.date_updated DESC LIMIT ', pageSize, ' OFFSET ', pageNumber * pageSize);
    PREPARE stmt2 FROM @stmt1;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
    DROP TEMPORARY TABLE IF EXISTS temp_ids;

END$$

DELIMITER ;
;

ALTER TABLE `alpide-purchase`.`packing_unit_putaway_ref` 
CHANGE COLUMN `storage_type_id` `storage_type_id` BIGINT NULL ;


ALTER TABLE `alpide-crm`.`crm_lead` 
ADD COLUMN `last_note` VARCHAR(45) NULL AFTER `stage_status_name`;

ALTER TABLE `alpide-users`.`pos_user` 
ADD COLUMN `created_by_user_id` BIGINT NULL AFTER `updated_at`;




ALTER TABLE `alpide-inventory`.inventory_item 
ADD COLUMN customer_id BIGINT DEFAULT null;

ALTER TABLE `alpide-inventory`.inventory_item 
ADD COLUMN is_seller_inventory BIGINT DEFAULT null;

Use `alpide-sales`;
ALTER TABLE customers 
ADD COLUMN is_seller INT DEFAULT 0 COMMENT 'Seller flag (0=No, 1=Yes)';

-- 2. Add index for seller queries
CREATE INDEX idx_customers_is_seller ON customers(is_seller, rid);

-- 3. Create seller_config table (stores seller preferences as JSON)
CREATE TABLE IF NOT EXISTS seller_config (
    seller_config_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    rid BIGINT NOT NULL,
    rate_card_id BIGINT,
    seller_preferences JSON COMMENT 'JSON: platforms, carriers, handling, packaging',
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by_user_id BIGINT,
    updated_by_user_id BIGINT,
    is_active INT DEFAULT 1,
    FOREIGN KEY (customer_id, rid) REFERENCES customers(customer_id, rid) ON DELETE CASCADE,
    UNIQUE KEY unique_customer_seller (customer_id, rid),
    INDEX idx_rate_card (rate_card_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Stores seller-specific configuration with JSON';

-- 4. Create seller_product_categories table (normalized for filtering)
CREATE TABLE IF NOT EXISTS seller_product_categories (
    seller_product_category_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    inventory_item_category_id BIGINT NOT NULL,
    rid BIGINT NOT NULL,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id BIGINT,
    is_active INT DEFAULT 1,
    FOREIGN KEY (customer_id, rid) REFERENCES customers(customer_id, rid) ON DELETE CASCADE,
    INDEX idx_customer_rid (customer_id, rid),
    INDEX idx_category (inventory_item_category_id),
    UNIQUE KEY unique_customer_category (customer_id, inventory_item_category_id, rid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Stores product categories for sellers';


ALTER TABLE `alpide-sales`.`customers` 
ADD COLUMN `warehouse_master_id` BINARY NULL DEFAULT NULL AFTER `is_seller`,
ADD COLUMN `warehouse_name` VARCHAR(255) NULL DEFAULT NULL AFTER `warehouse_master_id`;

ALTER TABLE `alpide-sales`.`customers` 
CHANGE COLUMN `warehouse_master_id` `warehouse_master_id` BIGINT NULL DEFAULT NULL ;

ALTER TABLE `alpide-sales`.`customer_sales_quotation_details` 
ADD COLUMN `short_description` TEXT NULL AFTER `exchange_rate`;

-- 1. INVENTORY BATCH TABLE
USE `alpide-inventory`;

CREATE TABLE inventory_batch (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid VARCHAR(50) UNIQUE NOT NULL,
    
    -- Batch Information
    batch_name VARCHAR(255) DEFAULT NULL,
    batch_code VARCHAR(100) UNIQUE DEFAULT NULL,
    note TEXT DEFAULT NULL,
    
    -- Hierarchy
    parent_batch_id BIGINT DEFAULT NULL,
    hierarchy_level INT NOT NULL DEFAULT 0,
    
    -- POS Assignment
    assigned_pos_user_id BIGINT DEFAULT NULL,
    assigned_pos_user_name VARCHAR(255) DEFAULT NULL,
    is_assigned BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Status
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    
    -- Quantities
    total_quantity DECIMAL(19,4) DEFAULT 0,
    quantity_split DECIMAL(19,4) DEFAULT 0,
    quantity_remaining DECIMAL(19,4) DEFAULT 0,
    quantity_dissolved DECIMAL(19,4) DEFAULT 0,
    
    -- Timestamps
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    
    -- Audit fields
    created_by VARCHAR(100) DEFAULT NULL,
    updated_by VARCHAR(100) DEFAULT NULL,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by VARCHAR(100) DEFAULT NULL,
    
    -- Indexes
    INDEX idx_rid (rid),

    
    -- Foreign Key
    CONSTRAINT fk_parent_batch FOREIGN KEY (parent_batch_id) 
        REFERENCES inventory_batch(id) ON DELETE RESTRICT
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- 2. INVENTORY BATCH ITEM TABLE
-- ============================================================================
CREATE TABLE inventory_batch_item (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid VARCHAR(50) UNIQUE NOT NULL,
    batch_id BIGINT NOT NULL,
    
    -- Item Information
    item_id BIGINT NOT NULL,
    item_name VARCHAR(255) DEFAULT NULL,
    item_code VARCHAR(100) DEFAULT NULL,
    
    -- Variant Information
    item_variant_id BIGINT DEFAULT NULL,
    variant_name VARCHAR(255) DEFAULT NULL,
    variant_code VARCHAR(100) DEFAULT NULL,
    
    -- Quantities
    original_quantity DECIMAL(19,4) NOT NULL DEFAULT 0,
    current_quantity DECIMAL(19,4) NOT NULL DEFAULT 0,
    quantity_distributed DECIMAL(19,4) DEFAULT 0,
    quantity_split DECIMAL(19,4) DEFAULT 0,
    quantity_dissolved DECIMAL(19,4) DEFAULT 0,
    quantity_remaining DECIMAL(19,4) DEFAULT 0,
    
    -- Unit Information
    unit VARCHAR(50) DEFAULT NULL,
    unit_price DECIMAL(19,4) DEFAULT NULL,
    total_value DECIMAL(19,4) DEFAULT NULL,
    
    -- Additional Info
    sku VARCHAR(100) DEFAULT NULL,
    barcode VARCHAR(100) DEFAULT NULL,
    note TEXT DEFAULT NULL,
    
    -- Timestamps
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    
    -- Audit fields
    created_by VARCHAR(100) DEFAULT NULL,
    updated_by VARCHAR(100) DEFAULT NULL,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by VARCHAR(100) DEFAULT NULL,
    

    
    -- Foreign Key
    CONSTRAINT fk_batch_item_batch FOREIGN KEY (batch_id) 
        REFERENCES inventory_batch(id) ON DELETE CASCADE
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- 3. BATCH SPLIT HISTORY TABLE
-- ============================================================================
CREATE TABLE batch_split_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid VARCHAR(50) UNIQUE NOT NULL,
    
    -- Batch References
    parent_batch_id BIGINT NOT NULL,
    child_batch_id BIGINT NOT NULL,
    
    -- Split Details
    split_quantity DECIMAL(19,4) DEFAULT NULL,
    parent_remaining_quantity DECIMAL(19,4) DEFAULT NULL,
    split_reason VARCHAR(255) DEFAULT NULL,
    note TEXT DEFAULT NULL,
    
    -- Audit
    split_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    split_by VARCHAR(100) DEFAULT NULL,

    
    -- Foreign Keys
    CONSTRAINT fk_split_parent FOREIGN KEY (parent_batch_id) 
        REFERENCES inventory_batch(id) ON DELETE CASCADE,
    CONSTRAINT fk_split_child FOREIGN KEY (child_batch_id) 
        REFERENCES inventory_batch(id) ON DELETE CASCADE
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- 4. BATCH DISSOLVE HISTORY TABLE
-- ============================================================================
CREATE TABLE batch_dissolve_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rid VARCHAR(50) UNIQUE NOT NULL,
    
    -- Batch References
    dissolved_batch_id BIGINT NOT NULL,
    parent_batch_id BIGINT NOT NULL,
    
    -- Dissolve Details
    dissolved_quantity DECIMAL(19,4) DEFAULT NULL,
    parent_new_quantity DECIMAL(19,4) DEFAULT NULL,
    dissolve_reason VARCHAR(255) DEFAULT NULL,
    note TEXT DEFAULT NULL,
    items_count INT DEFAULT NULL,
    
    -- Audit
    dissolve_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dissolved_by VARCHAR(100) DEFAULT NULL,
    
    -- Foreign Keys
    CONSTRAINT fk_dissolve_child FOREIGN KEY (dissolved_batch_id) 
        REFERENCES inventory_batch(id) ON DELETE CASCADE,
    CONSTRAINT fk_dissolve_parent FOREIGN KEY (parent_batch_id) 
        REFERENCES inventory_batch(id) ON DELETE CASCADE
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


ALTER TABLE `alpide-inventory`.`inventory_item_variant` 
ADD COLUMN `quantity_on_asn` Double DEFAULT 0.000;

ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_details` 
ADD COLUMN `asn_master_id` BIGINT DEFAULT NULL;


CREATE TABLE `alpide-purchase`.`asn_order_master` (
  `asn_master_id` BIGINT NOT NULL AUTO_INCREMENT,
  `rid` BIGINT NOT NULL,
  `asn_number` VARCHAR(50) NOT NULL,
  `customer_id` BIGINT NOT NULL,
  `customer_name` VARCHAR(255) DEFAULT NULL,
  `supplier_id` BIGINT DEFAULT NULL,

  -- Dates
  `po_date` TIMESTAMP NULL DEFAULT NULL,
  `supplier_po_date` TIMESTAMP NULL DEFAULT NULL,
  `expected_delivery_date` TIMESTAMP NULL DEFAULT NULL,
  `fy_start_date` TIMESTAMP NULL DEFAULT NULL,
  `fy_end_date` TIMESTAMP NULL DEFAULT NULL,

  -- Status fields
  `status` VARCHAR(50) NOT NULL DEFAULT 'Open',
  `status_color` VARCHAR(50) DEFAULT 'label label-info',
  `status_inbound_delivery` VARCHAR(50) DEFAULT 'Not Received',
  `status_color_inbound_delivery` VARCHAR(50) DEFAULT 'label label-primary',
  `user_status` VARCHAR(100) DEFAULT NULL,
  `user_status_color` VARCHAR(50) DEFAULT NULL,

  -- Currency and amounts
  `currency_code` VARCHAR(10) DEFAULT 'USD',
  `foreign_currency` VARCHAR(10) DEFAULT NULL,
  `foreign_currency_icon` VARCHAR(10) DEFAULT NULL,
  `foreign_currency_amount` DECIMAL(15,2) DEFAULT 0.00,
  `exchange_rate` DECIMAL(15,6) DEFAULT 1.000000,
  `is_multi_currency` TINYINT(1) DEFAULT 0,
  `tax` DECIMAL(15,2) DEFAULT 0.00,

  -- Additional information
  `place_of_supply` VARCHAR(255) DEFAULT NULL,
  `reference` VARCHAR(255) DEFAULT NULL,
  `seller_notes` TEXT,
  `footer` TEXT,
  `carrier_name` VARCHAR(255) DEFAULT NULL,
  `tracking_number` VARCHAR(100) DEFAULT NULL,

  -- Document storage
  `folder_name` VARCHAR(500) DEFAULT NULL,
  `file_name` VARCHAR(500) DEFAULT NULL,
  `bucket_name` VARCHAR(255) DEFAULT NULL,

  -- Relationship and metadata
  `relationship_name` VARCHAR(255) DEFAULT NULL,
  `document_name` VARCHAR(255) DEFAULT NULL,

  -- Audit fields
  `created_by_user_id` BIGINT DEFAULT NULL,
  `updated_by_user_id` BIGINT DEFAULT NULL,
  `created_by_emp_id` BIGINT DEFAULT NULL,
  `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_updated` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`asn_master_id`)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `alpide-purchase`.`asn_order_details` (
  `asn_details_id` BIGINT NOT NULL AUTO_INCREMENT,
  `asn_master_id` BIGINT NOT NULL,
  `rid` BIGINT NOT NULL,

  `parent_details_id` BIGINT DEFAULT NULL,

  `item_id` BIGINT NOT NULL,
  `item_name` VARCHAR(500) DEFAULT NULL,
  `item_variant_id` BIGINT DEFAULT NULL,
  `is_variant` TINYINT(1) DEFAULT 0,
  `sku` VARCHAR(100) DEFAULT NULL,
  `hsn_code` VARCHAR(50) DEFAULT NULL,
  `description` TEXT,

  `quantity` DECIMAL(15,3) NOT NULL DEFAULT 0.000,
  `qty_to_invoice` DECIMAL(15,3) DEFAULT 0.000,
  `uom_name` VARCHAR(50) DEFAULT 'EA',

  `attribute_name1` VARCHAR(100) DEFAULT NULL,
  `attribute_value1` VARCHAR(255) DEFAULT NULL,
  `attribute_id1` BIGINT DEFAULT NULL,

  `attribute_name2` VARCHAR(100) DEFAULT NULL,
  `attribute_value2` VARCHAR(255) DEFAULT NULL,
  `attribute_id2` BIGINT DEFAULT NULL,

  `attribute_name3` VARCHAR(100) DEFAULT NULL,
  `attribute_value3` VARCHAR(255) DEFAULT NULL,
  `attribute_id3` BIGINT DEFAULT NULL,

  `foreign_currency_amount` DECIMAL(15,2) DEFAULT 0.00,
  `exchange_rate` DECIMAL(15,6) DEFAULT 1.000000,

  `s_no` BIGINT DEFAULT NULL,
  `row_height` VARCHAR(20) DEFAULT NULL,

  `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `version` INT NOT NULL DEFAULT 0,

  PRIMARY KEY (`asn_details_id`)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;



ALTER TABLE `alpide-purchase`.`asn_order_master` 
ADD COLUMN `supplier_name` VARCHAR(255) NULL DEFAULT NULL AFTER `date_updated`;

ALTER TABLE `alpide-purchase`.`asn_order_master` 
ADD COLUMN `version` INT NULL DEFAULT 0 AFTER `supplier_name`;

ALTER TABLE `alpide-purchase`.`asn_order_details` 
ADD COLUMN `packing_unit_ref_list` TEXT  AFTER `version`;

ALTER TABLE `alpide-purchase`.`tx_conversion_po_to_id_ref` 
ADD COLUMN `asn_master_id` BIGINT  DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`tx_conversion_po_to_id_ref` 
ADD COLUMN `customer_id` BIGINT  DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_details` 
ADD COLUMN `asn_number` varchar(255)  DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_master` 
ADD COLUMN `grn_source` VARCHAR(255) DEFAULT NULL AFTER `is_direct_grn`;

ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_master` 
ADD COLUMN `asn_master_id` BIGINT DEFAULT NULL AFTER `grn_source`;

ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_master` 
ADD COLUMN `asn_number` VARCHAR(255) DEFAULT NULL AFTER `asn_master_id`;

USE `alpide-inventory`;

CREATE OR REPLACE
    ALGORITHM = UNDEFINED
    DEFINER = `alpide`@`%`
    SQL SECURITY DEFINER
VIEW `alpide-inventory`.`vw_seller_inventory_summary` AS
SELECT
    c.customer_id,
    c.company_name AS seller_name,
    c.rid AS relationship_id,

    COALESCE(inv.total_skus, 0) AS total_skus,
    COALESCE(inv.total_units, 0) AS total_units,
    COALESCE(FLOOR(inv.total_units / 50), 0) AS pallets_used,
    COALESCE(inv.inventory_value, 0) AS inventory_value,
    COALESCE(inv.total_bins_used, 0) AS total_bins_used,
    COALESCE(inv.total_variants, 0) AS total_variants,
    COALESCE(inv.total_sales_committed, 0) AS total_sales_committed,
    COALESCE(inv.total_on_order, 0) AS total_on_order,
    NOW() AS last_updated
FROM `alpide-sales`.customers c

LEFT JOIN (
    SELECT
        ii.customer_id,
        ii.rid,
        COUNT(DISTINCT ii.item_id) AS total_skus,
        SUM(iivs.current_stock) AS total_units,
        SUM(iivs.current_stock * iiv.purchased_price) AS inventory_value,
        COUNT(DISTINCT iivsbr.storage_bin_id) AS total_bins_used,
        COUNT(DISTINCT iiv.inventory_item_variant_id) AS total_variants,
        SUM(iivs.sales_committed) AS total_sales_committed,
        SUM(iivs.on_order) AS total_on_order
    FROM `alpide-inventory`.inventory_item ii
    LEFT JOIN `alpide-inventory`.inventory_item_variant iiv
        ON iiv.item_id = ii.item_id
        AND iiv.rid = ii.rid
    LEFT JOIN `alpide-inventory`.inventory_item_variant_stock iivs
        ON iivs.inventory_item_variant_id = iiv.inventory_item_variant_id
        AND iivs.item_id = iiv.item_id
        AND iivs.rid = iiv.rid
    LEFT JOIN `alpide-inventory`.inventory_item_varaint_stock_storage_bin_ref iivsbr
        ON iivsbr.item_variant_stock_id = iivs.item_variant_stock_id
    WHERE ii.is_seller_inventory = 1
    GROUP BY ii.customer_id, ii.rid
) inv
    ON inv.customer_id = c.customer_id
    AND inv.rid = c.rid

WHERE c.is_seller = 1;
