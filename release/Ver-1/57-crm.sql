 USE `alpide-crm`;
  DROP PROCEDURE IF EXISTS `count_crm_leads_list`;

  USE `alpide-crm`;
  DROP PROCEDURE IF EXISTS `alpide-crm`.`count_crm_leads_list`;

  DELIMITER $$
  USE `alpide-crm`$$
  CREATE  PROCEDURE `count_crm_leads_list`(
      IN p_rid              INT,
      IN searchedStr        VARCHAR(45),
      IN projectName        VARCHAR(45),
      IN crmLeadFormSettingId INT,
      IN leadAssignTo       VARCHAR(45),
      IN sourceName         VARCHAR(45),
      IN statusName         VARCHAR(45),
      IN startDate          TIMESTAMP,
      IN endDate            TIMESTAMP,
      IN reminderType       VARCHAR(45),
      IN startUpdateDate    TIMESTAMP,
      IN endUpdateDate      TIMESTAMP,
      IN isActive           INT,
      IN stageStatusName    VARCHAR(100),
      IN isConverted        INT,
      IN leadScore          VARCHAR(200),
      IN leadStatusId       INT,
      IN isStale            INT
  )
  BEGIN
      DECLARE whereClause TEXT;
      DECLARE idList VARCHAR(255);
      DECLARE v_stale_days INT DEFAULT 30;

      IF (isStale = 1) THEN
          SELECT COALESCE(stale_days_for_lead, 30)
          INTO   v_stale_days
          FROM   crm_config
          WHERE  rid = p_rid
          LIMIT  1;
          IF v_stale_days IS NULL OR v_stale_days <= 0 THEN
              SET v_stale_days = 30;
          END IF;
      END IF;

      SET whereClause = CONCAT("cl.rid=", p_rid);
      SET whereClause = CONCAT(whereClause, ' AND cl.is_active=''', isActive, '''');

      IF (searchedStr IS NOT NULL) THEN
          SET whereClause = CONCAT(whereClause, " AND cl.lead_name LIKE '%", searchedStr, "%'");
          SET whereClause = CONCAT(whereClause, " OR ld.email LIKE '%", searchedStr, "%'");
          SET whereClause = CONCAT(whereClause, " OR ld.mobile_no LIKE '%", searchedStr, "%'");
      END IF;

      IF (crmLeadFormSettingId > 0) THEN
          SET whereClause = CONCAT(whereClause, " AND cl.crm_lead_form_setting_id=", crmLeadFormSettingId);
      END IF;

      IF (leadStatusId > 0) THEN
          SET whereClause = CONCAT(whereClause, " AND cl.status_id=", leadStatusId);
      END IF;

      IF (leadScore IS NOT NULL) THEN
          SET whereClause = CONCAT(whereClause, " AND cl.lead_score='", leadScore, "'");
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

      IF (isConverted IS NOT NULL) THEN
          SET whereClause = CONCAT(whereClause, " AND cl.is_converted='", isConverted, "'");
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

      IF (isStale = 1) THEN
          SET whereClause = CONCAT(whereClause,
              " AND cl.is_converted = 0",
              " AND DATEDIFF(CURDATE(), DATE(COALESCE(cl.date_updated, cl.date_created, CURDATE()))) > ",
              v_stale_days);
      END IF;

      SET @stmt = 'SELECT
                      COUNT(DISTINCT cl.crm_lead_id) AS total_count
                  FROM crm_lead cl
                      LEFT JOIN crm_lead_reminder clr ON cl.crm_lead_id = clr.crm_lead_id
                      LEFT JOIN crm_lead_emp_assigned clea ON cl.crm_lead_id = clea.crm_lead_id
                      LEFT JOIN crm_lead_form_setting clfs ON cl.crm_lead_form_setting_id = clfs.crm_lead_form_setting_id
                      LEFT JOIN (
                          SELECT crm_lead_id,
                                 MAX(CASE WHEN label = "Full Name"  THEN value END) AS "full_name",
                                 MAX(CASE WHEN label = "Email"      THEN value END) AS "email",
                                 MAX(CASE WHEN label = "Mobile No." THEN value END) AS "mobile_no"
                          FROM crm_lead_detail
                          GROUP BY crm_lead_id
                      ) ld ON cl.crm_lead_id = ld.crm_lead_id
                  WHERE ';

      SET @stmt1 = CONCAT(@stmt, whereClause);
      PREPARE stmt2 FROM @stmt1;
      EXECUTE stmt2;
      DEALLOCATE PREPARE stmt2;
      DROP TEMPORARY TABLE IF EXISTS temp_ids;
  END$$

  DELIMITER ;