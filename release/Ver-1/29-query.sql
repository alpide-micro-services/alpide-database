ALTER TABLE `alpide-sales`.`customer_sales_order_master`
ADD COLUMN `is_mps_created` INT NULL DEFAULT '0' AFTER `status_qty_picked`;

USE `alpide-sales`;
DROP procedure IF EXISTS `get_sales_order_summary`;

USE `alpide-sales`;
DROP procedure IF EXISTS `alpide-sales`.`get_sales_order_summary`;
;

DELIMITER $$
USE `alpide-sales`$$
CREATE PROCEDURE `get_sales_order_summary`(
    IN rid INT,
    IN customerId INT,
    IN soStatus VARCHAR(75),
    IN orderPriority VARCHAR(75),
    IN projectMasterId INT,
    IN salesPersonId INT,
    IN startDate TIMESTAMP,
    IN endDate TIMESTAMP,
    IN soNumber VARCHAR(15),
    IN refNumber VARCHAR(75),
    IN amount DOUBLE,
    IN amountSymbol VARCHAR(45),
    IN userStatus VARCHAR(45),
    IN pageNumber INT,
    IN pageSize INT,
    IN isConsignmentOrder INT,
    IN priceListId INT,
    IN orderType VARCHAR(100),
    IN isMPSCreated INT
)
BEGIN
    DECLARE whereClause TEXT;
    SET whereClause = CONCAT("so.rid = ", rid);
    -- Order Type Filtering
-- Order Type Filtering
	IF (orderType IS NOT NULL AND orderType != 'all') THEN
	    IF (orderType = 'consignment') THEN
	        SET whereClause = CONCAT(whereClause, " AND so.is_consignment_order = 1");
	    ELSEIF (orderType = 'online') THEN
	        SET whereClause = CONCAT(whereClause, " AND so.customer_pre_order_master_id > 0");
        ELSEIF (orderType = 'production') THEN
	        SET whereClause = CONCAT(whereClause, " AND so.is_production_sales_order > 0");
	    ELSEIF (orderType = 'regular') THEN
	        SET whereClause = CONCAT(whereClause, " AND (so.customer_pre_order_master_id IS NULL OR so.customer_pre_order_master_id = 0)");
	        SET whereClause = CONCAT(whereClause, " AND so.is_consignment_order = 0");
	    END IF;
	END IF;
    -- Other Filters
    IF (customerId > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND so.customer_id = ", customerId);
    END IF;
    IF (soStatus IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND so.status = '", soStatus, "'");
    END IF;
    IF (orderPriority IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND so.order_priority = '", orderPriority, "'");
    END IF;
    IF (projectMasterId > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND so.project_master_id = ", projectMasterId);
    END IF;
    IF (salesPersonId > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND so.sales_person_id = ", salesPersonId);
    END IF;
    IF (startDate IS NOT NULL AND endDate IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND so.sales_order_date BETWEEN '", startDate, "' AND '", endDate, "'");
    END IF;
	IF (soNumber IS NOT NULL) THEN
	    SET whereClause = CONCAT(whereClause, " AND so.so_number LIKE '%", soNumber, "%'");
	END IF;
    IF (refNumber IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND so.reference_number = '", refNumber, "'");
    END IF;
    IF (amount > 0) THEN
        IF (amountSymbol IS NOT NULL AND amountSymbol = '=') THEN
            SET whereClause = CONCAT(whereClause, " AND so.total_amount = ", amount);
        ELSEIF (amountSymbol = '>') THEN
            SET whereClause = CONCAT(whereClause, " AND so.total_amount > ", amount);
        ELSEIF (amountSymbol = '<') THEN
            SET whereClause = CONCAT(whereClause, " AND so.total_amount < ", amount);
        END IF;
    END IF;
    IF (userStatus IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND so.user_status = '", userStatus, "'");
    END IF;
    IF (priceListId > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND so.pricelist_id = ", priceListId);
    END IF;
    IF (isMPSCreated IS NOT NULL) THEN
    SET whereClause = CONCAT(whereClause, " AND so.is_mps_created = ", isMPSCreated);
END IF;
    -- Build Final Query
    SET @stmt = CONCAT(
        "SELECT so.sales_order_master_id,
                so.rid,
                so.so_id,
                so.so_number,
                so.warehouse_location_id,
                so.payment_term_id,
                so.customer_id,
                so.status,
                so.status_invoice,
                so.status_package,
                so.status_shipment,
                so.status_color_for_ui_cell,
                so.status_color_invoice,
                so.status_color_package,
                so.status_color_shipment,
                so.invoice_master_id,
                so.sales_order_date,
                so.foreign_currency_amount,
                so.sub_total,
                so.total_amount,
                so.sales_order_due_date,
                so.so_rejection_comments,
                so.status_pr,
                so.status_color_pr,
                so.customer_po_number,
                so.reference_number,
                so.status_approval,
                so.status_color_approval,
                so.remarks_internal,
                so.remarks_customer,
                so.contact_id,
                so.order_priority,
                so.sales_person_id,
                so.customer_contact_id,
                so.date_created,
                so.date_updated,
                so.updated_by_user_id,
                so.created_by_user_id,
                so.status_service,
                so.place_of_supply,
                so.so_source_name,
                so.foreign_currency,
                so.exchange_rate,
                so.is_multi_currency,
                so.customer_name,
                so.payment_term_name,
                so.relationship_name,
                so.is_quote_conversion,
                so.sales_quotation_master_id,
                so.quotation_number,
                so.project_number,
                so.project_name,
                so.project_master_id,
                so.document_name,
                so.foreign_currency_icon,
                so.is_approved,
                so.is_reviewed,
                so.approved_by_emp_id,
                so.reviewed_by_emp_id,
                so.approval_date,
                so.reviewed_date,
                so.is_approval_required,
                so.created_by_emp_id,
                so.approver_emp_id,
                so.rejection_reason,
                so.is_rejected,
                so.delivery_date,
                so.user_status,
                so.user_status_color,
                so.currency_code,
                so.incoterm_name,
                so.customer_inquiry_number,
                so.customer_rfq_number,
                so.inquiry_master_id,
                so.inquiry_number,
                so.status_pr_message,
                so.customer_pre_order_master_id,
                SUM(p.payment_amount) AS totalPaymentReceived,
                (SELECT GROUP_CONCAT(detail.sales_order_details_id)
                 FROM customer_sales_order_details detail
                 WHERE detail.sales_order_master_id = so.sales_order_master_id
                 AND detail.rid = so.rid) AS customerSalesOrderDetailsList,
                so.amend_sales_order_master_id AS amendSalesOrderMasterId,
                so.aso_number AS asoNumber,
                so.counter_order_master_id AS counterOrderMasterId,
                so.counter_so_number AS counterSoNumber,
                so.cancel_order_data AS cancelOrderData,
                so.rr_item AS rrItem,
                so.status_qty_to_pick as  statusQtyToPick ,
                so.status_qty_picked as statusQtyPicked ,
                so.is_mps_created as isMPSCreated
         FROM customer_sales_order_master so
         LEFT JOIN customer_so_payment p ON so.sales_order_master_id = p.sales_order_master_id
         WHERE ", whereClause,
        " GROUP BY so.sales_order_master_id
          ORDER BY so.sales_order_master_id DESC
          LIMIT ", pageSize, " OFFSET ", pageNumber * pageSize
    );
    PREPARE stmt2 FROM @stmt;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
END$$

DELIMITER ;
;

ALTER TABLE `alpide-sales`.`customer_sales_order_master`
ADD COLUMN `is_mps_created` INT NULL DEFAULT '0' AFTER `status_qty_picked`;

ALTER TABLE `alpide-purchase`.`supplier_po_master`
ADD COLUMN `isConsignmentOrder` INT NULL DEFAULT '0' AFTER `is_mrp_conversion`;


ALTER TABLE `alpide-purchase`.`supplier_purchase_request_master`
ADD COLUMN `is_mrp_conversion` INT NULL DEFAULT '0' AFTER `is_multi_currency`;
CREATE TABLE `alpide-purchase`.`tx_conversion_mrp_to_pr_ref` (

    `tx_conversion_mrp_to_pr_ref_id` BIGINT NOT NULL AUTO_INCREMENT,

    `version` INT NOT NULL DEFAULT 0,

    `rid` BIGINT NULL,

    `supplier_id` BIGINT NULL,

    `purchase_request_master_id` BIGINT NULL,

    `soMasterId` BIGINT NULL,

    `mrp_purchase_request_id` BIGINT NULL,

    `mps_master_id` BIGINT NULL,

    `mrp_run_id` BIGINT NULL,

    `bom_master_id` BIGINT NULL,

    `item_id` BIGINT NULL,

    `item_variant_id` BIGINT NULL,

    `sku` VARCHAR(255) NULL,

    `quantity` DOUBLE NULL,

    `fulfilled_quantity` DOUBLE NULL,

    `fulfilled_status` VARCHAR(100) NULL,

    `date_created` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`tx_conversion_mrp_to_pr_ref_id`)
);



use `alpide-project`;
ALTER TABLE project_master
    ADD COLUMN  priority          VARCHAR(20) default null,
    ADD COLUMN  project_status    VARCHAR(30) default null,
    ADD COLUMN  customer_id       BIGINT default null ,
    ADD COLUMN  customer_name     VARCHAR(200) default null;

-- ── Step 2: Financial Info additions ──────────────────────────
ALTER TABLE project_master
    ADD COLUMN  contract_value            DECIMAL(18,2)   default null,
    ADD COLUMN  project_currency          VARCHAR(10)     default null ,
    ADD COLUMN  internal_cost_budget      DECIMAL(18,2)   default null,
    ADD COLUMN  contingency_percent       DECIMAL(5,2)    default null,
    ADD COLUMN  contract_date             TIMESTAMP       NULL,
    ADD COLUMN  project_payment_term_id   BIGINT          default null,
    ADD COLUMN  project_payment_term_name VARCHAR(100)    default null,
    ADD COLUMN  invoice_frequency         VARCHAR(50)     default null COMMENT 'Weekly / Monthly / Milestone etc.',
    ADD COLUMN  billing_type              VARCHAR(50)     default null COMMENT 'Fixed Price / Time & Material / Milestone / Retainer';

-- ── Step 3: Team & Settings additions ─────────────────────────
ALTER TABLE project_master
    ADD COLUMN  project_manager_id    BIGINT       NULL,
    ADD COLUMN  project_manager_name  VARCHAR(200) NULL,
    ADD COLUMN  enable_timesheets     TINYINT(1)    DEFAULT 0,
    ADD COLUMN  budget_alerts         TINYINT(1)   DEFAULT 0,
    ADD COLUMN  allow_sub_projects    TINYINT(1)    DEFAULT 0,
    ADD COLUMN  hse_tracking          TINYINT(1)    DEFAULT 0;

-- ── Project Tax table (Step 2: Tax / VAT rows) ─────────────────
CREATE TABLE IF NOT EXISTS project_tax (
    project_tax_id   BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    version          INT              DEFAULT 0,
    project_master_id BIGINT         default null,
    rid              BIGINT          default null,
    tax_type         VARCHAR(100)    default null,
    tax_rate         DECIMAL(5,2)    default null,
    tax_id           BIGINT          default null,
    CONSTRAINT fk_project_tax_master
        FOREIGN KEY (project_master_id, rid)
        REFERENCES project_master (project_master_id, rid)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


ALTER TABLE `alpide-manufacturing`.work_order_quality_check
MODIFY COLUMN execution_id BIGINT NOT NULL;


-- ============================================================
-- Migration: project_wbs table
-- ============================================================

CREATE TABLE IF NOT EXISTS project_wbs (
    wbs_id                  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    version                 INT             NOT NULL DEFAULT 0,
    wbs_code                VARCHAR(50)     DEFAULT NULL COMMENT '1.0 / 1.1 / 1.1.1',
    wbs_name                VARCHAR(200)    DEFAULT NULL,
    wbs_level               VARCHAR(50)     DEFAULT NULL COMMENT 'Phase / Deliverable / Task / Milestone',
    project_master_id       BIGINT          DEFAULT NULL,
    rid                     BIGINT          DEFAULT NULL,
    parent_wbs_id           BIGINT          DEFAULT 0,
    responsible_person_id   BIGINT          DEFAULT NULL,
    responsible_person_name VARCHAR(200)    DEFAULT NULL,
    planned_start_date      TIMESTAMP       NULL,
    planned_end_date        TIMESTAMP       NULL,
    progress_percent        DECIMAL(5,2)    DEFAULT NULL,
    weight_percent          DECIMAL(5,2)    DEFAULT NULL,
    wbs_status              VARCHAR(50)     DEFAULT 'Draft',
    notes                   VARCHAR(1000)   DEFAULT NULL,
    is_active               TINYINT(1)      NOT NULL DEFAULT 1,
    date_created            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_user_name    VARCHAR(200)    DEFAULT NULL,

    CONSTRAINT fk_wbs_project
        FOREIGN KEY (project_master_id, rid)
        REFERENCES project_master (project_master_id, rid)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_wbs_project   ON project_wbs (project_master_id, rid);
CREATE INDEX idx_wbs_parent    ON project_wbs (parent_wbs_id, rid);


CREATE TABLE `alpide-manufacturing`.`product_configuration` (
  `product_configuration_id`  bigint        NOT NULL AUTO_INCREMENT,
  `version`                   int           DEFAULT '0',
  `rid`                       bigint        DEFAULT '0',
  `item_id`                   bigint        DEFAULT '0',
  `item_name`                 varchar(255)  DEFAULT NULL,
  `sku`                       varchar(100)  DEFAULT NULL,
  `rounting_id`               bigint        DEFAULT '0',
  `rounting_name`             varchar(255)  DEFAULT NULL,
  `bom_id`                    bigint        DEFAULT '0',
  `bom_name`                  varchar(255)  DEFAULT NULL,
  `description`               text          DEFAULT NULL,
  `created_by_user_id`        bigint        DEFAULT '0',
  `updated_by_user_id`        bigint        DEFAULT '0',
  `deleted_by_user_id`        bigint        DEFAULT '0',
  `is_active`                 int           DEFAULT '1',
  `is_deleted`                int           DEFAULT '0',
  `date_created`              timestamp     NULL DEFAULT CURRENT_TIMESTAMP,
  `date_updated`              timestamp     NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `date_deleted`              timestamp     NULL DEFAULT NULL,
  PRIMARY KEY (`product_configuration_id`)
);



CREATE TABLE `alpide-manufacturing`.`product_config_material_consumption` (
  `product_config_material_consumption_id`  bigint        NOT NULL AUTO_INCREMENT,
  `version`                                 int           DEFAULT '0',
  `rid`                                     bigint        DEFAULT '0',
  `product_configuration_id`               bigint        DEFAULT '0',
  `bom_main_component_id`                  bigint        DEFAULT '0',
  `operation_id`                            bigint        DEFAULT '0',
  `rounting_operation_id`                  bigint        DEFAULT '0',
  `item_id`                                 bigint        DEFAULT '0',
  `item_variant_id`                         bigint        DEFAULT '0',
  `sku`                                     varchar(100)  DEFAULT NULL,
  `item_name`                               varchar(255)  DEFAULT NULL,
  `quantity`                                double        DEFAULT '0',
  `uom_name`                                varchar(50)   DEFAULT NULL,
  `created_by_user_id`                      bigint        DEFAULT '0',
  `updated_by_user_id`                      bigint        DEFAULT '0',
  `deleted_by_user_id`                      bigint        DEFAULT '0',
  `is_active`                               int           DEFAULT '1',
  `is_deleted`                              int           DEFAULT '0',
  `date_created`                            timestamp     NULL DEFAULT CURRENT_TIMESTAMP,
  `date_updated`                            timestamp     NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `date_deleted`                            timestamp     NULL DEFAULT NULL,
  PRIMARY KEY (`product_config_material_consumption_id`)
);


-- ============================================================
-- Migration: Project team & employee assignment tables
-- Stores exactly: team_id + team_name / emp_id + emp_name
-- Lives in the PROJECT microservice database
-- ============================================================

-- Team assignments per project
CREATE TABLE project_team_assigned (
    id                BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY,
    version           INT           NOT NULL DEFAULT 0,
    project_master_id BIGINT        DEFAULT NULL,
    rid               BIGINT        DEFAULT NULL,
    team_id           BIGINT        DEFAULT NULL,
    team_name         VARCHAR(200)  DEFAULT NULL,
    date_created      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pta_project
        FOREIGN KEY (project_master_id, rid)
        REFERENCES project_master (project_master_id, rid)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_pta_project ON project_team_assigned (project_master_id, rid);

-- Employee assignments per project
CREATE TABLE project_emp_assigned (
    id                BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY,
    version           INT           NOT NULL DEFAULT 0,
    project_master_id BIGINT        DEFAULT NULL,
    rid               BIGINT        DEFAULT NULL,
    rel_emp_id        BIGINT        DEFAULT NULL COMMENT 'relationshipEmployeeId from HRMS',
    emp_name          VARCHAR(200)  DEFAULT NULL,
    date_created      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pea_project
        FOREIGN KEY (project_master_id, rid)
        REFERENCES project_master (project_master_id, rid)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_pea_project ON project_emp_assigned (project_master_id, rid);



CREATE TABLE `alpide-project`.project_task (
    task_id             BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    version             INT             NOT NULL DEFAULT 0,
    task_code           VARCHAR(20)     DEFAULT NULL COMMENT 'TSK-001 global per relationship',
    task_seq            BIGINT          DEFAULT NULL COMMENT 'raw sequence used for code generation',
    task_name           VARCHAR(200)    DEFAULT NULL,
    task_type           VARCHAR(50)     DEFAULT NULL COMMENT 'Feature/Bug/Review/Meeting/Documentation/Testing/Deployment',
    description         TEXT            DEFAULT NULL,
    project_master_id   BIGINT          DEFAULT NULL,
    rid                 BIGINT          DEFAULT NULL,
    wbs_id              BIGINT          DEFAULT NULL,
    wbs_code            VARCHAR(50)     DEFAULT NULL COMMENT 'e.g. 1.1',
    wbs_name            VARCHAR(200)    DEFAULT NULL,
    assignee_emp_id     BIGINT          DEFAULT NULL,
    assignee_name       VARCHAR(200)    DEFAULT NULL,
    reporter_emp_id     BIGINT          DEFAULT NULL,
    reporter_name       VARCHAR(200)    DEFAULT NULL,
    priority            VARCHAR(20)     DEFAULT NULL COMMENT 'Low/Medium/High/Critical',
    task_status         VARCHAR(50)     DEFAULT 'To Do' COMMENT 'To Do/In Progress/In Review/Done/Blocked',
    start_date          TIMESTAMP       NULL,
    due_date            TIMESTAMP       NULL,
    estimated_hours     DECIMAL(8,2)    DEFAULT NULL,
    completion_date     TIMESTAMP       NULL,
    completed_by_emp_id BIGINT          DEFAULT NULL,
    completed_by_name   VARCHAR(200)    DEFAULT NULL,
    is_active           TINYINT(1)      NOT NULL DEFAULT 1,
    date_created        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_user_name VARCHAR(200)   DEFAULT NULL,
    CONSTRAINT fk_task_project
        FOREIGN KEY (project_master_id, rid)
        REFERENCES project_master (project_master_id, rid)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_task_project ON project_task (project_master_id, rid);
CREATE INDEX idx_task_wbs     ON project_task (wbs_id, rid);
CREATE INDEX idx_task_status  ON project_task (task_status, rid);


ALTER TABLE `alpide-manufacturing`.`product_configuration`
ADD COLUMN configuration_name VARCHAR(255) NOT NULL DEFAULT '',
ADD COLUMN configuration_code VARCHAR(255) NOT NULL DEFAULT '';


CREATE TABLE `alpide-project`.project_milestone (
    milestone_id        BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    version             INT             NOT NULL DEFAULT 0,
    milestone_name      VARCHAR(200)    DEFAULT NULL,
    project_master_id   BIGINT          DEFAULT NULL,
    rid                 BIGINT          DEFAULT NULL,
    wbs_id              BIGINT          DEFAULT NULL,
    wbs_code            VARCHAR(50)     DEFAULT NULL,
    wbs_name            VARCHAR(200)    DEFAULT NULL,
    responsible_emp_id  BIGINT          DEFAULT NULL,
    responsible_name    VARCHAR(200)    DEFAULT NULL,
    due_date            TIMESTAMP       NULL,
    completion_percent  DECIMAL(5,2)    DEFAULT 0.00,
    completion_date     TIMESTAMP       NULL,
    milestone_status    VARCHAR(30)     DEFAULT 'Upcoming',
    is_billing_milestone TINYINT(1)     NOT NULL DEFAULT 0
        COMMENT '1 = triggers invoice when marked complete',
    billing_amount      DECIMAL(18,2)   DEFAULT NULL,
    billing_currency    VARCHAR(10)     DEFAULT NULL,
    invoice_term_id     BIGINT          DEFAULT NULL,
    invoice_term_name   VARCHAR(100)    DEFAULT NULL,
    notes               TEXT            DEFAULT NULL,
    is_active           TINYINT(1)      NOT NULL DEFAULT 1,
    date_created        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_user_name VARCHAR(200)   DEFAULT NULL,

    CONSTRAINT fk_milestone_project
        FOREIGN KEY (project_master_id, rid)
        REFERENCES project_master (project_master_id, rid)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_milestone_project ON project_milestone (project_master_id, rid);
CREATE INDEX idx_milestone_wbs     ON project_milestone (wbs_id, rid);
CREATE INDEX idx_milestone_due     ON project_milestone (due_date);


CREATE TABLE  `alpide-inventory`.inventory_import_template (
    import_template_id  BIGINT       NOT NULL AUTO_INCREMENT,
    rid                 BIGINT       NOT NULL,
    template_data       LONGTEXT     NOT NULL,
    date_modified       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (import_template_id),
    UNIQUE KEY uq_import_template_rid (rid)
);


USE `alpide-lookup`;
CREATE TABLE IF NOT EXISTS `defect_type` (
    defecttype_id       BIGINT          NOT NULL AUTO_INCREMENT,
    defecttype_name     VARCHAR(255)    NOT NULL,



    rid                 BIGINT          NOT NULL,
    date_created        DATETIME        DEFAULT CURRENT_TIMESTAMP,
    date_updated        DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    date_deleted        DATETIME        DEFAULT NULL,
    created_by_user_id  BIGINT          DEFAULT NULL,
    updated_by_user_id  BIGINT          DEFAULT NULL,
    deleted_by_user_id  BIGINT          DEFAULT NULL,
    is_active           INTEGER         DEFAULT 1,
    is_deleted          INTEGER         DEFAULT 0,

    PRIMARY KEY (defecttype_id)
);


ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_defect_master`
ADD COLUMN `po_number` VARCHAR(255) NULL AFTER `updated_by_user_id`,
ADD COLUMN `inbound_delivery_number` VARCHAR(255) NULL AFTER `po_number`,
ADD COLUMN `supplier_name` VARCHAR(255) NULL AFTER `inbound_delivery_number`;


USE `alpide-sales`;
DROP procedure IF EXISTS `get_sales_invoice_summary`;

USE `alpide-sales`;
DROP procedure IF EXISTS `alpide-sales`.`get_sales_invoice_summary`;
;

DELIMITER $$
USE `alpide-sales`$$
CREATE  PROCEDURE `get_sales_invoice_summary`(
    IN rid INT,
    IN pageNumber INT,
    IN pageSize INT,
    IN customerId INT,
    IN invoiceStatus VARCHAR(255), -- can be comma-separated list
    IN projectName VARCHAR(75),
    IN startDate TIMESTAMP,
    IN endDate TIMESTAMP,
    IN registration_form_setting_id INT,
    IN ledgerAccountId INT,
    IN invoiceNumber VARCHAR(100)
)
BEGIN
    DECLARE whereClause TEXT;
    SET whereClause = CONCAT("si.rid=", rid);

    IF (customerId > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND si.customer_id=", customerId);
    END IF;

    -- :white_check_mark: Handle multiple statuses (comma-separated)
    IF (invoiceStatus IS NOT NULL AND invoiceStatus <> '') THEN
        -- Replace commas with "','" and wrap inside NOT IN (...) or IN (...)
        SET whereClause = CONCAT(
            whereClause,
            " AND si.status IN ('",
            REPLACE(invoiceStatus, ',', "','"),
            "')"
        );
    END IF;

    IF (projectName IS NOT NULL AND projectName <> '') THEN
        SET whereClause = CONCAT(whereClause, " AND si.project_name='", projectName, "'");
    END IF;

    IF (invoiceNumber IS NOT NULL AND invoiceNumber <> '') THEN
        SET whereClause = CONCAT(whereClause, " AND si.invoice_number LIKE '%", invoiceNumber, "%'");
    END IF;

    IF (startDate IS NOT NULL AND endDate IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND si.invoice_date BETWEEN '", startDate, "' AND '", endDate, "'");
    END IF;

    IF (registration_form_setting_id > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND si.registration_form_setting_id=", registration_form_setting_id);
    END IF;

    IF (ledgerAccountId > 0) THEN
        SET whereClause = CONCAT(whereClause,
            " AND si.invoice_master_id IN (",
            "SELECT coa.invoice_master_id FROM customer_coa_tx_invoice coa WHERE coa.ledger_account_id = ",
            ledgerAccountId,
            ")"
        );
    END IF;

    -- Main query
    SET @stmt = '
        SELECT
            si.invoice_master_id AS invoiceMasterId,
            si.customer_id AS customerId,
            si.fy_start_date AS fyStartDate,
            si.fy_end_date AS fyEndDate,
            si.foreign_currency AS foreignCurrency,
            si.user_status AS userStatus,
            si.exchange_rate AS exchangeRate,
            si.foreign_currency_icon AS foreignCurrencyIcon,
            si.project_master_id AS projectMasterId,
            si.is_approval_required AS isApprovalRequired,
            si.is_approved AS isApproved,
            si.approved_by_emp_id AS approvedByEmpId,
            si.currency_code AS currencyCode,
            si.is_xero_uploaded AS isXeroUploaded,
            si.is_cash_invoice AS isCashInvoice,
            si.total_amount AS invoiceTotalAmount,
            si.foreign_currency_amount AS foreignCurrencyAmount,
            si.customer_name AS customerName,
            si.relationship_name AS relationshipName,
            si.tx_type AS txType,
            si.invoice_number AS invoiceNumber,
            si.invoice_type AS invoiceType,
            si.place_of_supply AS placeOfSupply,
            si.status AS status,
            si.status_color_for_ui_cell AS statusColorForUICell,
            si.invoice_date AS invoiceDate,
            si.invoice_due_date AS invoiceDueDate,
            si.invoice_source AS invoiceSource,
            si.rid AS relationshipId,
            si.is_so_conversion AS isSOConversion,
            si.is_shipment_conversion AS isShipmentConversion,
            si.is_proforma_conversion AS isProformaConversion,
            si.is_independent_invoice AS isIndependentInvoice,
            si.is_recurring_invoice AS isRecurringInvoice,
            si.customer_po_number AS customerPONumber,
            si.reference_number AS referenceNumber,
            si.remarks_customer AS remarksCustomer,
            si.remarks_internal AS remarksInternal,
            si.payment_term_id AS paymentTermId,
            si.payment_term_name AS paymentTermName,
            si.sales_person_id AS salesPersonId,
            si.date_created AS dateCreated,
            si.date_updated AS dateUpdated,
            si.created_by_user_id AS createdByUserId,
            si.updated_by_user_id AS updatedByUserId,
            si.footer AS footer,
            si.is_multi_currency AS isMultiCurrency,
            si.payment_term_days AS paymentTermDays,
            si.stamp_aws_key AS stampAwsKey,
            si.name_of_transport AS nameOfTransport,
            si.vehicle_number AS vehicleNumber,
            si.road_permit_number AS roadPermitNumber,
            si.freight_type AS freightType,
            si.consignee AS consignee,
            si.eway_bill_no AS ewayBillNo,
            si.station AS station,
            si.project_number AS projectNumber,
            si.document_name AS documentName,
            si.created_by_emp_id AS createdByEmpId,
            si.rejection_reason AS rejectionReason,
            si.is_rejected AS isRejected,
            COALESCE(pay.totalPaymentReceived,0) AS totalPaymentReceived,
            si.project_name AS projectName,
            COALESCE(cm.creditApplied,0) AS creditApplied,
            MAX(info.payment_gateway_name) AS paymentGateway,
            MAX(info.payment_gateway_id) AS paymentGatewayId,
            COUNT(rm.reminder_sales_invoice_id) AS reminderCount,
            COUNT(rc.recurring_invoice_id) AS recurringCount,
            si.module AS module,
            si.registration_form_setting_id AS formId,
            si.contact_id AS contactIdId,
            si.invoice_title AS invoiceTitle,
            COALESCE(pay.paymentCount,0) AS paymentCount,
            si.is_e_invoice_generated AS isEInvoiceGenerated,
            si.e_invoice_type AS eInvoiceType,
            si.irn AS irn,
            si.pos_user_id as posUserId
        FROM customer_invoice_master si
        LEFT JOIN (
            SELECT invoice_master_id,
                   SUM(payment_amount) AS totalPaymentReceived,
                   COUNT(*) AS paymentCount
            FROM customer_payment
            GROUP BY invoice_master_id
        ) pay ON si.invoice_master_id = pay.invoice_master_id
        LEFT JOIN (
            SELECT invoice_master_id,
                   SUM(amount_applied) AS creditApplied
            FROM customer_credit_memo_applied
            GROUP BY invoice_master_id
        ) cm ON si.invoice_master_id = cm.invoice_master_id
        LEFT JOIN customer_invoice_additional_info info ON si.invoice_master_id = info.invoice_master_id
        LEFT JOIN reminder_sales_invoice rm ON si.invoice_master_id = rm.invoice_master_id
        LEFT JOIN recurring_invoice rc ON si.invoice_master_id = rc.invoice_master_id
        WHERE ';

    SET @stmt1 = CONCAT(@stmt, whereClause,
        ' GROUP BY si.invoice_master_id
          ORDER BY si.invoice_master_id DESC
          LIMIT ', pageSize, ' OFFSET ', pageNumber * pageSize);

    PREPARE stmt2 FROM @stmt1;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
END$$

DELIMITER ;
;Aniket Tyagi  [5:41 PM]
use `alpide-lookup` ;
CREATE TABLE lk_default_template (
    default_template_id  BIGINT          NOT NULL AUTO_INCREMENT,
    version              INT             NOT NULL DEFAULT 0,
    rid                  BIGINT          NOT NULL,
    tx_type              VARCHAR(100)    NOT NULL,
    template_type        VARCHAR(100)    NOT NULL,
    date_created         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_created_name    VARCHAR(255),
    PRIMARY KEY (default_template_id),
    UNIQUE KEY uq_rid_tx_type (rid, tx_type)
);



use `alpide-lookup` ;
CREATE TABLE lk_default_template (
    default_template_id  BIGINT         NOT NULL AUTO_INCREMENT,
    version              INT             NOT NULL DEFAULT 0,
    rid                  BIGINT          NOT NULL,
    tx_type               VARCHAR(100)     NOT NULL,
    template_type        VARCHAR(100)        NOT NULL,
    date_created           TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_created_name       VARCHAR(255),
    PRIMARY KEY (default_template_id),
    UNIQUE KEY uq_rid_tx_type (rid, tx_type)
);


ALTER TABLE `alpide-users`.client_relationship
ADD can_create_direct_grn INT default 0,
ADD can_create_direct_shipment INT default 0,
ADD tax_on_profit INT default 0,
ADD tax_type VARCHAR(50) default null;


ALTER TABLE `alpide-inventory`.`inventory_item`
ADD COLUMN `is_service_product` INT NULL DEFAULT '0' AFTER `is_lot_tracking`;

ALTER TABLE `alpide-purchase`.supplier_invoice_details
ADD customer_name varchar(255) default null,
ADD customer_id BIGINT Default Null;

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
	In startUpdateDate TIMESTAMP,
    In endUpdateDate TIMESTAMP
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
		IF (startUpdateDate IS NOT NULL AND endUpdateDate IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.date_updated BETWEEN '", startUpdateDate, "' AND '", endUpdateDate, "'");
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

