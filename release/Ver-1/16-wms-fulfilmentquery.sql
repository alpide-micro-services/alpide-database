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