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