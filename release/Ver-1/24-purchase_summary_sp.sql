USE `alpide-purchase`;
DROP procedure IF EXISTS `get_purchase_order_summary`;

DELIMITER $$
CREATE PROCEDURE `get_purchase_order_summary`(
    IN rid              INT,
    IN supplierId       INT,
    IN status           VARCHAR(75),
    IN projectMasterId  INT,
    IN startDate        VARCHAR(75),
    IN endDate          VARCHAR(75),
    IN poNumber         VARCHAR(45),
    IN userStatus       VARCHAR(45),
    IN reference        VARCHAR(45),
    IN amount           DOUBLE,
    IN amountSymbol     VARCHAR(45),
    IN pageNumber       INT,
    IN pageSize         INT
)
BEGIN
    DECLARE whereClause TEXT;
    SET whereClause = CONCAT('po.rid=', rid);

    IF (supplierId > 0) THEN
        SET whereClause = CONCAT(whereClause, ' and po.supplier_id=', supplierId);
END IF;
    IF (status IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' and po.status=''', status, '''');
END IF;
    IF (projectMasterId > 0) THEN
        SET whereClause = CONCAT(whereClause, ' and po.project_master_id=''', projectMasterId, '''');
END IF;
    IF (poNumber IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' AND po.po_number LIKE ''%', poNumber, '%''');
END IF;
    IF (userStatus IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' and po.user_status=', userStatus);
END IF;
    IF (reference IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' and po.reference=''', reference, '''');
END IF;
    IF (amount > 0) THEN
        IF (amountSymbol IS NOT NULL && amountSymbol = '=') THEN
            SET whereClause = CONCAT(whereClause, ' and po.po_amount = ', amount);
END IF;
        IF (amountSymbol IS NOT NULL && amountSymbol = '>') THEN
            SET whereClause = CONCAT(whereClause, ' and po.po_amount > ', amount);
END IF;
        IF (amountSymbol IS NOT NULL && amountSymbol = '<') THEN
            SET whereClause = CONCAT(whereClause, ' and po.po_amount < ', amount);
END IF;
END IF;
    IF (startDate IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' and po.po_date between ''', startDate, ''' and ''', endDate, '''');
END IF;

    SET @stmt = 'select
        po.po_master_id,
        po.po_number,
        po.rid,
        po.supplier_id,
        po.po_date,
        po.po_due_date,
        po.status,
        po.status_color,
        po.sub_total,
        po.foreign_currency_amount,
        po.po_amount,
        po.date_created,
        po.date_updated,
        po.payment_term_id,
        po.supplier_po_number,
        po.status_invoice,
        po.status_color_invoice,
        po.status_inbound_delivery,
        po.status_color_inbound_delivery,
        po.expected_delivery_date,
        po.reference,
        po.supplier_po_date,
        po.foreign_currency,
        po.exchange_rate,
        po.is_multi_currency,
        po.place_of_supply,
        po.payment_term_name,
        po.supplier_name,
        po.is_rfq_conversion,
        po.is_pr_conversion,
        po.rfq_master_id,
        po.purchase_request_master_id,
        po.purchase_request_number,
        po.rfq_number,
        po.relationship_name,
        po.project_number,
        po.project_name,
        po.project_master_id,
        po.foreign_currency_icon,
        po.is_approval_required,
        po.approved_by_emp_id,
        po.reviewed_by_emp_id,
        po.is_approved,
        po.is_rejected,
        po.currency_code,
        po.user_status,
        po.customer_inquiry_number,
        po.customer_rfq_number,
        po.customer_po_number,
        po.supplier_quote_number,
        po.inquiry_master_id,
        po.inquiry_number,
        po.sales_quotation_master_id,
        po.quotation_number,
        COALESCE(dc.defectCount, 0) AS defectCount
    from supplier_po_master po
    LEFT JOIN (
        SELECT po_master_id, rid, COUNT(defect_master_id) AS defectCount
        FROM supplier_inbound_delivery_defect_master
        GROUP BY po_master_id, rid
    ) dc ON dc.po_master_id = po.po_master_id AND dc.rid = po.rid
    where';

    SET @stmt1 = CONCAT(@stmt, ' ', whereClause, ' order by po.po_master_id desc LIMIT ', pageSize, ' OFFSET ', pageNumber * pageSize);
PREPARE stmt2 FROM @stmt1;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------

USE `alpide-purchase`;
DROP procedure IF EXISTS `get_purchase_grn_summary`;

DELIMITER $$
CREATE PROCEDURE `get_purchase_grn_summary`(
    IN rid              INT,
    IN supplierId       INT,
    IN poNumber         VARCHAR(75),
    IN grnNumber        VARCHAR(75),
    IN projectMasterId  VARCHAR(75),
    IN reference        VARCHAR(75),
    IN userStatus       VARCHAR(45),
    IN statusInvoice    VARCHAR(45),
    IN startDate        TIMESTAMP,
    IN endDate          TIMESTAMP,
    IN pageNumber       INT,
    IN pageSize         INT
)
BEGIN
    DECLARE whereClause TEXT;
    SET whereClause = CONCAT('sq.rid=', rid);

    IF (supplierId > 0) THEN
        SET whereClause = CONCAT(whereClause, ' and sq.supplier_id=', supplierId);
END IF;
    IF (poNumber IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' and sq.po_number=''', poNumber, '''');
END IF;
    IF (grnNumber IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' and sq.inbound_delivery_number=''', grnNumber, '''');
END IF;
    IF (projectMasterId > 0) THEN
        SET whereClause = CONCAT(whereClause, ' and sq.project_master_id=', projectMasterId);
END IF;
    IF (reference IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' and sq.reference=''', reference, '''');
END IF;
    IF (userStatus IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' and sq.user_status=', userStatus);
END IF;
    IF (statusInvoice IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' and sq.status_invoice=''', statusInvoice, '''');
END IF;
    IF (startDate IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, ' and sq.inbound_delivery_date between ''', startDate, ''' and ''', endDate, '''');
END IF;

    SET @stmt = 'select
        sq.inbound_delivery_master_id,
        sq.inbound_delivery_number,
        sq.rid,
        sq.supplier_id,
        sq.inbound_delivery_date,
        sq.sub_total,
        sq.foreign_currency_amount,
        sq.po_amount,
        sq.inbound_delivery_amount,
        sq.date_created,
        sq.date_updated,
        sq.supplier_po_number,
        sq.status_invoice,
        sq.status_color_invoice,
        sq.reference,
        sq.supplier_po_date,
        sq.foreign_currency,
        sq.exchange_rate,
        sq.is_multi_currency,
        sq.place_of_supply,
        sq.relationship_name,
        sq.supplier_name,
        sq.project_number,
        sq.project_name,
        sq.rfq_child_master_id,
        sq.po_master_id,
        sq.po_number,
        sq.expense_id,
        sq.user_status,
        COALESCE(dc.defectCount, 0) AS defectCount
    from supplier_inbound_delivery_master sq
    LEFT JOIN (
        SELECT inbound_delivery_master_id, rid, COUNT(defect_master_id) AS defectCount
        FROM supplier_inbound_delivery_defect_master
        GROUP BY inbound_delivery_master_id, rid
    ) dc ON dc.inbound_delivery_master_id = sq.inbound_delivery_master_id AND dc.rid = sq.rid
    where';

    SET @stmt1 = CONCAT(@stmt, ' ', whereClause, ' order by sq.purchase_request_master_id desc LIMIT ', pageSize, ' OFFSET ', pageNumber * pageSize);
PREPARE stmt2 FROM @stmt1;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;
END$$
DELIMITER ;
