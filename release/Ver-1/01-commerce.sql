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

