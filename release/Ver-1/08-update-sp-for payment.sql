USE `alpide-sales`;
DROP procedure IF EXISTS `get_sales_payment_summary`;

USE `alpide-sales`;
DROP procedure IF EXISTS `alpide-sales`.`get_sales_payment_summary`;
;

DELIMITER $$
USE `alpide-sales`$$
CREATE PROCEDURE `get_sales_payment_summary`(IN rid int, IN pageNumber int, IN pageSize int, in customerId int, in invoiceNumber varchar(75), in projectName varchar(75), in startDate timestamp, in endDate timestamp)
BEGIN
		declare whereClause TEXT;
		set whereClause = concat("sp.rid=", rid);

		IF( customerId > 0) THEN
			set whereClause = concat(whereClause, " and sp.customer_id=",customerId);
END IF;

        IF(invoiceNumber is not null) THEN
			set whereClause = concat(whereClause, " and sp.invoice_number='",invoiceNumber,"'");
END IF;

        IF(projectName is not null) THEN
			set whereClause = concat(whereClause, " and sp.project_name='",projectName,"'");
END IF;

        IF(startDate is not null) THEN
			set whereClause = concat(whereClause, " and sp.payment_date between '", startDate, "' and '", endDate, "'");
END IF;

	SET @stmt= 'select sp.customer_payment_id,
    sp.rid,
    sp.payment_amount,
    sp.invoice_master_id,
			 sp.foreign_currency_icon,
             sp.payment_date,
             sp.remarks,
             sp.payment_mode_name,
			 sp.is_xero_uploaded,
             sp.payment_number,
             sp.invoice_number,
             sp.customer_name,
             sp.customer_inquiry_number,
             sp.customer_rfq_number,
			sp.customer_po_number,
            sp.relationship_name,
            sp.invoice_due_date,
            sp.customer_id,
            sp.invoice_amount,
			sp.date_created,
            sp.created_by_user_id,
            sp.currency_code,
            sp.foreign_currency,
            sp.payment_mode_detail,
            sp.is_multi_currency,
			sp.project_number,
            sp.project_name,
            sp.quotation_number,
            sp.rfq_number,
            sp.reference,
            sp.sales_quotation_master_id,
			sp.description,
            sp.payment_source,
			sp.transaction_id ,
			sp.module as module,
			sp.form_id as formId,
            sp.is_recon as is_recon
			from customer_payment sp where';

		SET @stmt1=CONCAT(@stmt,' ', whereClause, ' order by sp.customer_payment_id desc LIMIT ', pageSize, ' OFFSET ', pageNumber*pageSize);
PREPARE stmt2 FROM @stmt1;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;
END$$

DELIMITER ;
;



