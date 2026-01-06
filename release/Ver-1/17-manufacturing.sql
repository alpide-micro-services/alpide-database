ALTER TABLE `alpide-sales`.`customer_sales_order_master`
    ADD COLUMN `is_production_sales_order` INT NULL DEFAULT '0' AFTER `status_qty_picked`;


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
    IN orderType VARCHAR(100)
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
                so.status_qty_picked as statusQtyPicked
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

