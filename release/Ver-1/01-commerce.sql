ALTER TABLE `alpide-commerce`.`ecom_setting` ADD COLUMN website_content text;

ALTER TABLE `alpide-commerce`.`ecom_setting`
CHANGE COLUMN `website_sequence_data` `website_sequence_data` MEDIUMTEXT NULL DEFAULT NULL ;


ALTER TABLE `alpide-education`.`org_registration_form_setting_permissions` ADD COLUMN first_name varchar(140) default null;
ALTER TABLE `alpide-education`.`org_registration_form_setting_permissions` ADD COLUMN last_name varchar(140) default null;


USE `alpide-education`;
DROP procedure IF EXISTS `get_school_student_list`;

USE `alpide-education`;
DROP procedure IF EXISTS `alpide-education`.`get_school_student_list`;
;

DELIMITER $$
USE `alpide-education`$$
CREATE  PROCEDURE `get_school_student_list`(
    IN p_rid INT,
    IN formId INT,
    IN studentName VARCHAR(45),
    IN fatherName VARCHAR(45),
    IN motherName VARCHAR(45),
    IN classId INT,
    IN isAllergy INT,
    IN paymentStatus VARCHAR(45),
    IN createdByEmpId INT,
    IN studentStatus VARCHAR(45),
    IN pageNumber INT,
    IN pageSize INT
)
BEGIN
    DECLARE whereClause TEXT;

    SET whereClause = CONCAT("ss.rid=", p_rid);

    IF (formId > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND ss.enroll_form_id=", formId);
    END IF;
    
	IF (studentName IS NOT NULL) THEN
		SET whereClause = CONCAT(whereClause, " AND concat(bc.first_name, ' ', bc.last_name) LIKE '%", studentName, "%'");
	END IF;
    
	IF (fatherName IS NOT NULL) THEN
		SET whereClause = CONCAT(whereClause, " AND concat(fc.first_name, ' ', fc.last_name) LIKE '%", fatherName, "%'");
	END IF;
    
	IF (motherName IS NOT NULL) THEN
		SET whereClause = CONCAT(whereClause, " AND concat(fc.first_name, ' ', fc.last_name) LIKE '%", motherName, "%'");
	END IF;
    
	IF (classId > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND ss.class_id=", classId);
    END IF;
    
	IF (isAllergy IS NOT NULL) THEN
		SET whereClause = CONCAT(whereClause, "  AND bc.is_allergy=", isAllergy);
	END IF;
    
	IF (createdByEmpId IS NOT NULL) THEN
		SET whereClause = CONCAT(whereClause, "  AND ss.created_by_emp_id=", createdByEmpId);
	END IF;
    
	IF (studentStatus IS NOT NULL) THEN
		SET whereClause = CONCAT(whereClause, "  AND ss.student_status=", studentStatus);
	END IF;
    

    SET @stmt = 'SELECT DISTINCT ss.student_id,
						ss.enroll_form_id,
						concat(bc.first_name, " ", bc.last_name) AS full_name,
						concat(fc.first_name, " ", fc.last_name) AS parent_name,
						bc.date_of_birth,
                        bc.gender,
                        ss.class_id,
                        ss.class_name,
                        ss.age,
						bc.email_address,
                        bc.cell_phone,
						fc.email_address AS parent_email,
                        fc.cell_phone AS parent_mobileNo,
						bc.is_allergy,
                        bc.allergies,
						ss.course_fee,
						ss.date_created,
						ss.student_status,
						ss.student_status_color,
                        sco.course_name,
                        sscr.class_section_id,
                        sscr.student_class_ref_id,
                        ss.org_registration_id,
                        ss.roll_no,
                        ss.customer_id,
                        ss.rid,
                        ss.logo_aws_object_key,
                        ss.face_id,
                        ss.file_name,
                        ss.bucket_name,
                        ss.folder_name,
                        ss.contact_id
					FROM school_student ss
					LEFT JOIN bo_contact bc ON ss.contact_id = bc.contact_id
					LEFT JOIN bo_contact fc ON bc.customer_id = fc.customer_id AND fc.is_primary_contact
                    LEFT JOIN school_class sc ON sc.class_id = ss.class_id
                    LEFT JOIN school_course sco ON sco.course_id = sc.course_id
                    LEFT JOIN school_student_class_ref sscr ON sscr.student_id = ss.student_id
                    
					WHERE ';

    SET @stmt1 = CONCAT(@stmt, whereClause, ' ORDER BY ss.date_created DESC LIMIT ', pageSize, ' OFFSET ', pageNumber * pageSize);
    INSERT INTO test values(@stmt1); 
    PREPARE stmt2 FROM @stmt1;
    EXECUTE stmt2; 
    DEALLOCATE PREPARE stmt2;

END$$

DELIMITER ;
;


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
    IN pageSize INT
)
BEGIN
    DECLARE whereClause TEXT;
    DECLARE idList VARCHAR(255);

    SET whereClause = CONCAT("cl.rid=", p_rid);
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
                    ld.mobile_no AS mobileNo
                    
					FROM crm_lead cl 
						LEFT JOIN crm_lead_reminder clr ON cl.crm_lead_id = clr.crm_lead_id
						LEFT JOIN crm_lead_emp_assigned clea ON cl.crm_lead_id = clea.crm_lead_id 
						LEFT JOIN crm_lead_form_setting clfs ON cl.crm_lead_form_setting_id = clfs.crm_lead_form_setting_id
                        LEFT JOIN (SELECT crm_lead_id,
										MAX(CASE WHEN label = "Full Name" THEN value END) AS "full_name",
										MAX(CASE WHEN label = "Email" THEN value END) AS "email",
										MAX(CASE WHEN label = "Mobile No." THEN value END) AS "mobile_no"
									FROM crm_lead_detail GROUP BY crm_lead_id) ld ON cl.crm_lead_id = ld.crm_lead_id
					WHERE ';

    SET @stmt1 = CONCAT(@stmt, whereClause, ' ORDER BY cl.date_created DESC LIMIT ', pageSize, ' OFFSET ', pageNumber * pageSize);
    PREPARE stmt2 FROM @stmt1;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
    DROP TEMPORARY TABLE IF EXISTS temp_ids;

END$$

DELIMITER ;
;

ALTER TABLE `alpide-crm`.`crm_lead_form_setting` MODIFY COLUMN form_fields_setting TEXT default null;

ALTER TABLE `alpide-inventory`.`inventory_item` ADD COLUMN product_additional_info TEXT;
ALTER TABLE `alpide-crm`.`crm_lead_form_setting` ADD COLUMN form_type VARCHAR(100) DEFAULT NULL;
ALTER TABLE `alpide-crm`.`crm_lead_form_setting` ADD COLUMN  is_two_column_layout VARCHAR(100) DEFAULT NULL;

CREATE TABLE `alpide-crm`.crm_lead_form_response (
    crm_lead_form_response_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    crm_lead_form_setting_id BIGINT DEFAULT null,
    rid BIGINT DEFAULT null,
    form_name VARCHAR(255) DEFAULT null,
    form_fields_response TEXT,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    form_short_description VARCHAR(512) DEFAULT null,
    form_type VARCHAR(100) DEFAULT null,
    is_two_column_layout VARCHAR(10) DEFAULT 'false'
);

ALTER TABLE `alpide-commerce`.`ecom_setting` ADD COLUMN cart_prefrence text DEFAULT NULL;
 ALTER TABLE `alpide-crm`.`crm_lead_form_response` MODIFY COLUMN extra_details TEXT default null;
ALTER TABLE `alpide-crm`.`crm_lead_detail` Add COLUMN question_text TEXT default null;

ALTER TABLE `alpide-purchase`.`supplier_debit_memo_applied` MODIFY COLUMN invoice_master_id Bigint default null;


DROP PROCEDURE IF EXISTS `alpide-purchase`.get_purchase_invoice_summary;
DELIMITER $$
$$
CREATE  PROCEDURE `alpide-purchase`.`get_purchase_invoice_summary`(IN rid int, in supplierId int, in status varchar(75), in projectMasterId int, in startDate timestamp, in endDate timestamp, in invoiceNumber varchar(45), in userStatus varchar(45), in reference varchar(45), in amount double, in amountSymbol varchar(45), in ledgerAccountId int, IN pageNumber int, IN pageSize int)
BEGIN
		declare whereClause TEXT;
		
		set whereClause = concat("pi.rid=", rid);
	
		IF( supplierId > 0) THEN
			set whereClause = concat(whereClause, " and pi.supplier_id=", supplierId);
		END IF;
		
        IF(status is not null) THEN
			set whereClause = concat(whereClause, " and pi.status='",status,"'");
		END IF;
        IF(projectMasterId >0) THEN
			set whereClause = concat(whereClause, " and pi.project_master_id='",projectMasterId,"'");
		END IF;
        IF(startDate is not null) THEN
			set whereClause = concat(whereClause, " and pi.invoice_date between '", startDate, "' and '", endDate, "'");
		END IF;
        IF(invoiceNumber is not null) THEN
			set whereClause = concat(whereClause, " and pi.invoice_number='",invoiceNumber,"'");
		END IF;
        IF(userStatus is not null) THEN
			set whereClause = concat(whereClause, " and pi.status=",user_status);
		END IF;
        IF(reference is not null) THEN
			set whereClause = concat(whereClause, " and pi.reference_number='",reference,"'");
		END IF;
        	IF(amount > 0) THEN
				IF(amountSymbol is not null && amountSymbol = '=') THEN
				set whereClause = concat(whereClause, " and pi.total_amount = ", amount);
				END IF;
				IF(amountSymbol is not null && amountSymbol = '>') THEN
				set whereClause = concat(whereClause, " and pi.total_amount > ", amount);
				END IF;
				IF(amountSymbol is not null && amountSymbol = '<') THEN
				set whereClause = concat(whereClause, " and pi.total_amount < ", amount);
				END IF;
			END IF;
			
		IF( ledgerAccountId > 0) THEN
			set whereClause = concat(whereClause, " and pi.invoice_master_id in (SELECT coa.invoice_master_id FROM supplier_coa_tx_invoice coa WHERE coa.ledger_account_id = ", ledgerAccountId,")");
		END IF;	
	SET @stmt= 'select
										
					pi.invoice_master_id,
					pi.rid,
					pi.invoice_number,
					pi.supplier_id,
					pi.invoice_date,
					pi.invoice_due_date,
					pi.purchase_order_id,
					pi.sub_total,
					pi.total_amount,
					pi.status,
					pi.status_color_for_ui_cell,
					pi.po_master_id,
					pi.date_created,
					pi.updated_by_user_id,
					pi.created_by_user_id,
					pi.date_updated,
					pi.payment_term_id,
					pi.reference_number,
					pi.foreign_currency_amount,
					pi.foreign_currency,
					pi.exchange_rate,
					pi.supplier_invoice_number,
					pi.supplier_po_date,
					pi.supplier_po_number,
					pi.is_multi_currency,
					pi.is_cash_invoice,
					pi.place_of_supply,
					pi.supplier_name,
					pi.payment_term_name,
					pi.relationship_name,
					pi.payment_term_days,
					pi.project_number,
					pi.project_name,
					pi.foreign_currency_icon,
					pi.is_xero_uploaded,
					pi.is_approval_required,
					pi.approved_by_emp_id,
					pi.reviewed_by_emp_id,
					pi.created_by_emp_id,
					pi.is_approved,
					pi.is_rejected,
					pi.approver_emp_id,
					pi.currency_code,
					pi.is_po_conversion,
					pi.is_id_conversion,
					pi.customer_inquiry_number,
					pi.customer_rfq_number,
					pi.customer_po_number,
					pi.supplier_quote_number,
					pi.user_status,
					pi.inquiry_master_id,
					pi.inquiry_number,
					pi.sales_quotation_master_id,
					pi.quotation_number,
					pi.sales_order_master_id,
					pi.so_number,
					sum(p.payment_amount) as totalPaymentMade,
                    count(p.supplier_payment_id) as paymentCount,
                    sum(a.amount_applied) as creditApplied
				from supplier_invoice_master pi
                left join supplier_payments p on pi.invoice_master_id = p.invoice_master_id
                left join supplier_debit_memo_applied a on pi.invoice_master_id = a.invoice_master_id
				where';
		SET @stmt1=CONCAT(@stmt,' ', whereClause, ' group by pi.invoice_master_id order by pi.invoice_master_id desc LIMIT ', pageSize, ' OFFSET ', pageNumber*pageSize);
		PREPARE stmt2 FROM @stmt1;
		EXECUTE stmt2;
		DEALLOCATE PREPARE stmt2;
	END$$
DELIMITER ;
ALTER TABLE `alpide-purchase`.`supplier_po_master` ADD COLUMN total_po_multicurrency_amount double  DEFAULT 0.0;
ALTER TABLE `alpide-purchase`.`supplier_invoice_master` ADD COLUMN invoice_multicurrency_total_amount double  DEFAULT 0.0;
ALTER TABLE `alpide-purchase`.`supplier_debit_memo_details` ADD COLUMN item_variant_stock_id bigint  DEFAULT null;
ALTER TABLE `alpide-sales`.`customer_sales_order_details` ADD COLUMN stock_deduction_type varchar(120)  DEFAULT null;
ALTER TABLE `alpide-sales`.`customer_invoice_details` ADD COLUMN stock_deduction_type varchar(120)  DEFAULT null;
ALTER TABLE `alpide-sales`.`customer_so_shipment_details` ADD COLUMN stock_deduction_type varchar(120)  DEFAULT null;
ALTER TABLE `alpide-sales`.`customer_so_package_details` ADD COLUMN stock_deduction_type varchar(120)  DEFAULT null;
ALTER TABLE `alpide-sales`.`customer_sales_order_additional_info` ADD COLUMN country_calling_code int  DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_sales_order_additional_info` ADD COLUMN relationship_country_calling_code int  DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_invoice_additional_info` ADD COLUMN country_calling_code int  DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_invoice_additional_info` ADD COLUMN relationship_country_calling_code int  DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_so_package_additional_info` ADD COLUMN country_calling_code int  DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_so_package_additional_info` ADD COLUMN relationship_country_calling_code int  DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_so_package_additional_info` ADD COLUMN relationship_phone_number varchar(100)  DEFAULT null;
ALTER TABLE `alpide-sales`.`customer_so_shipment_additional_info` ADD COLUMN country_calling_code int  DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_so_shipment_additional_info` ADD COLUMN relationship_country_calling_code int  DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_so_shipment_additional_info` ADD COLUMN relationship_phone_number varchar(100)  DEFAULT null;

ALTER TABLE `alpide-sales`.`customer_sales_quotation_master` ADD COLUMN multicurrency_total_amount double  DEFAULT 0.0;
ALTER TABLE `alpide-sales`.`customer_sales_order_master` ADD COLUMN multicurrency_total_amount double  DEFAULT 0.0;
ALTER TABLE `alpide-sales`.`customer_invoice_master` ADD COLUMN multicurrency_total_amount double  DEFAULT 0.0;
ALTER TABLE `alpide-sales`.`customer_sales_quotation_additional_info` ADD COLUMN country_calling_code int  DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_sales_quotation_additional_info` ADD COLUMN relationship_country_calling_code int  DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_credit_memo_details` ADD COLUMN item_variant_stock_id bigint  DEFAULT null;
ALTER TABLE `alpide-purchase`.`supplier_debit_memo_master` ADD COLUMN is_multicurrency int  DEFAULT 0;
DROP PROCEDURE IF EXISTS `alpide-sales`.get_sales_order_summary;
DELIMITER $$
$$
CREATE  PROCEDURE `alpide-sales`.`get_sales_order_summary`(
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
        SET whereClause = CONCAT(whereClause, " AND so.so_number = '", soNumber, "'");
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
                so.rr_item AS rrItem
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
ALTER TABLE `alpide-sales`.`customer_sales_order_master` ADD COLUMN pricelist_id Bigint  DEFAULT 0
ALTER TABLE `alpide-sales`.`customer_sales_order_master` ADD COLUMN price_list_name varchar(200)  DEFAULT 0
ALTER TABLE `alpide-sales`.`customer_sales_order_master` ADD COLUMN priceList_type varchar(200)  DEFAULT 0
ALTER TABLE `alpide-sales`.`customer_sales_order_master` ADD COLUMN price_list_percentage double  DEFAULT 0.0
ALTER TABLE `alpide-sales`.`customer_invoice_master` ADD COLUMN pricelist_id Bigint  DEFAULT 0
ALTER TABLE `alpide-sales`.`customer_invoice_master` ADD COLUMN price_list_name varchar(200)  DEFAULT 0
ALTER TABLE `alpide-sales`.`customer_invoice_master` ADD COLUMN priceList_type varchar(200)  DEFAULT 0
ALTER TABLE `alpide-sales`.`customer_invoice_master` ADD COLUMN price_list_percentage double  DEFAULT
ALTER TABLE `alpide-purchase`.`lc_details` ADD COLUMN exchange_rate Double  DEFAULT 0
ALTER TABLE `alpide-purchase`.`lc_details` ADD COLUMN exchange_rate double  DEFAULT 0.0
ALTER TABLE `alpide-users`.`client_online_user_account` ADD COLUMN have_portal_access int  DEFAULT 0;  
ALTER TABLE `alpide-users`.`client_online_user_account` ADD COLUMN supplier_id bigint  DEFAULT null; 
ALTER TABLE `alpide-sales`.`customers` ADD COLUMN portal_password varchar(200)  DEFAULT null;
ALTER TABLE `alpide-sales`.`customers` ADD COLUMN have_portal_access int  DEFAULT 0;

ALTER TABLE `alpide-crm`.`crm_lead_notes` ADD COLUMN created_by_emp varchar(200)  DEFAULT null;
DROP PROCEDURE IF EXISTS `alpide-crm`.get_crm_leads_list;
DELIMITER $$
$$
CREATE PROCEDURE `alpide-crm`.`get_crm_leads_list`(
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
    IN pageSize INT
)
BEGIN
    DECLARE whereClause TEXT;
    DECLARE idList VARCHAR(255);
    SET whereClause = CONCAT("cl.rid=", p_rid);
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
	COALESCE(cln.notesCount, 0) AS totalNotes
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
    SET @stmt1 = CONCAT(@stmt, whereClause, ' ORDER BY cl.date_created DESC LIMIT ', pageSize, ' OFFSET ', pageNumber * pageSize);
    PREPARE stmt2 FROM @stmt1;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
    DROP TEMPORARY TABLE IF EXISTS temp_ids;
END$$
DELIMITER ;
ALTER TABLE `alpide-commerce`.`ecom_cart` ADD COLUMN supplier_id bigint DEFAULT null;
ALTER TABLE `alpide-sales`.`customer_sales_quotation_details` ADD COLUMN exchange_rate double DEFAULT 0.0;
ALTER TABLE `alpide-sales`.`customer_sales_order_details` ADD COLUMN exchange_rate double DEFAULT 0.0;
ALTER TABLE `alpide-purchase`.`supplier_po_details` ADD COLUMN exchange_rate double DEFAULT 0.0;
ALTER TABLE `alpide-purchase`.`supplier_invoice_details` ADD COLUMN foreign_currency_amount double DEFAULT 0.0;
ALTER TABLE `alpide-purchase`.`supplier_debit_memo_details` ADD COLUMN exchange_rate double DEFAULT 0.0;
ALTER TABLE `alpide-sales`.`customer_invoice_details` ADD COLUMN exchange_rate double DEFAULT 0.0;
ALTER TABLE `alpide-sales`.`customer_credit_memo_details` ADD COLUMN exchange_rate double DEFAULT 0.0;
CREATE TABLE `alpide-crm`.`crm_ziwo_user_creds` (
  `crm_ziwo_user_id` bigint NOT NULL AUTO_INCREMENT,
  `rel_emp_id` bigint DEFAULT NULL,
  `rid` bigint DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `tenant` varchar(255) DEFAULT NULL,
  `access_token` text,
  PRIMARY KEY (`crm_ziwo_user_id`)
)





CREATE TABLE alpide-crm.`crm_ziwo_user_creds` (
  `crm_ziwo_user_id` bigint NOT NULL AUTO_INCREMENT,
  `rel_emp_id` bigint DEFAULT NULL,
  `rid` bigint DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `tenant` varchar(255) DEFAULT NULL,
  `access_token` text,
  PRIMARY KEY (`crm_ziwo_user_id`)
);



DROP PROCEDURE IF EXISTS `alpide-crm`.count_crm_leads_list;
DELIMITER $$
$$
CREATE  PROCEDURE `alpide-crm`.`count_crm_leads_list`(
    IN p_rid INT,
    IN searchedStr VARCHAR(45),
    IN projectName VARCHAR(45),
    IN crmLeadFormSettingId INT,
    IN leadAssignTo VARCHAR(45),
    IN sourceName VARCHAR(45),
    IN statusName VARCHAR(45),
    IN startDate TIMESTAMP,
    IN endDate TIMESTAMP,
    IN reminderType VARCHAR(45),
    In startUpdateDate TIMESTAMP,
    In endUpdateDate TIMESTAMP
)
BEGIN
    DECLARE whereClause TEXT;
    DECLARE idList VARCHAR(255);
    SET whereClause = CONCAT("cl.rid=", p_rid);
	-- Search filter
	IF (searchedStr IS NOT NULL) THEN
		SET whereClause = CONCAT(whereClause, " AND cl.lead_name LIKE '%", searchedStr, "%'");
		SET whereClause = CONCAT(whereClause, " OR ld.email LIKE '%", searchedStr, "%'");
        SET whereClause = CONCAT(whereClause, " OR ld.mobile_no LIKE '%", searchedStr, "%'");
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
					count(DISTINCT cl.crm_lead_id) AS total_count
					FROM crm_lead cl
						LEFT JOIN crm_lead_reminder clr ON cl.crm_lead_id = clr.crm_lead_id
						LEFT JOIN crm_lead_emp_assigned clea ON cl.crm_lead_id = clea.crm_lead_id
						LEFT JOIN crm_lead_form_setting clfs ON cl.crm_lead_form_setting_id = clfs.crm_lead_form_setting_id
                        LEFT JOIN (SELECT crm_lead_id,
										MAX(CASE WHEN label = "Full Name" THEN value END) AS "full_name",
										MAX(CASE WHEN label = "Email" THEN value END) AS "email",
										MAX(CASE WHEN label = "Mobile No." THEN value END) AS "mobile_no"
									FROM crm_lead_detail GROUP BY crm_lead_id) ld ON cl.crm_lead_id = ld.crm_lead_id
					WHERE ';
    SET @stmt1 = CONCAT(@stmt, whereClause);
    PREPARE stmt2 FROM @stmt1;
    EXECUTE stmt2;
    DROP TEMPORARY TABLE IF EXISTS temp_ids;
END$$
DELIMITER ;
7:51
DROP PROCEDURE IF EXISTS `alpide-crm`.get_crm_leads_list;
DELIMITER $$
$$
CREATE  PROCEDURE `alpide-crm`.`get_crm_leads_list`(
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
    IN isActive INT
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
	COALESCE(cln.notesCount, 0) AS totalNotes
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
    SET @stmt1 = CONCAT(@stmt, whereClause, ' ORDER BY cl.date_created DESC LIMIT ', pageSize, ' OFFSET ', pageNumber * pageSize);
    PREPARE stmt2 FROM @stmt1;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
    DROP TEMPORARY TABLE IF EXISTS temp_ids;
END$$
DELIMITER ;


CREATE TABLE alpide-crm.`crm_lead_tiles` (
  `crm_lead_tiles_id` bigint NOT NULL AUTO_INCREMENT,
  `rid` bigint DEFAULT NULL,
  `tiles_data` text,
  PRIMARY KEY (`crm_lead_tiles_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci





CREATE TABLE `alpide-crm`.`crm_form_image_ref` (
  `crm_form_image_ref_Id` bigint NOT NULL AUTO_INCREMENT,
  `version` int DEFAULT '0',
  `rid` bigint DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `crm_lead_form_response_id` bigint DEFAULT NULL,
  `folder_name` varchar(255) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `bucket_name` varchar(255) DEFAULT NULL,
  `file_size` bigint DEFAULT NULL,
  `date_created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `date_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `image_info` text,
  PRIMARY KEY (`crm_form_image_ref_Id`)
)

ALTER TABLE `alpide-purchase`.`supplier_purchase_request_master` ADD COLUMN multi_currency_amount double DEFAULT 0.0;
ALTER TABLE `alpide-purchase`.`supplier_purchase_request_details` ADD COLUMN foreign_currency_amount double DEFAULT 0.0;
ALTER TABLE `alpide-purchase`.`supplier_purchase_request_details` ADD COLUMN exchange_rate double DEFAULT 0.0;

ALTER TABLE `alpide-purchase`.`supplier_purchase_request_master` ADD COLUMN is_multi_currency int DEFAULT 0; 

ALTER TABLE `alpide-purchase`.`supplier_purchase_request_master` ADD COLUMN exchange_rate double DEFAULT 0.0;

ALTER TABLE `alpide-purchase`.`supplier_purchase_request_master` ADD COLUMN foreign_currency varchar(120) DEFAULT null;
ALTER TABLE `alpide-purchase`.`supplier_purchase_request_master` ADD COLUMN foreign_currency_icon varchar(120) DEFAULT null;





































