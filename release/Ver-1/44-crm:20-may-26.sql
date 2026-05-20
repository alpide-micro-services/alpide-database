  CREATE TABLE crm_manual_communication_log (
      crm_manual_comm_log_id  BIGINT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
      rid                     BIGINT          NOT NULL,
      crm_lead_id             BIGINT          DEFAULT NULL,
      crm_opportunity_id      BIGINT          DEFAULT NULL,
      comm_type               VARCHAR(20)     NOT NULL,   -- Call|WhatsApp|Email|SMS|Visit
      outcome                 VARCHAR(50)     NOT NULL,   -- Connected|No answer|Busy|Left voicemail|Met|Replied
      communicated_to         VARCHAR(255)    DEFAULT NULL,
      direction               VARCHAR(20)     DEFAULT NULL,  -- Outbound|Inbound (call only)
      from_number             VARCHAR(30)     DEFAULT NULL,
      to_number               VARCHAR(30)     DEFAULT NULL,
      start_time              DATETIME        DEFAULT NULL,
      duration_mins           INT             DEFAULT NULL,
      notes                   TEXT            DEFAULT NULL,
      comm_date               DATE            NOT NULL,
      created_by_emp_id       BIGINT          DEFAULT NULL,
      created_by_emp          VARCHAR(100)    DEFAULT NULL,
      updated_by_emp_id       BIGINT          DEFAULT NULL,
      updated_by_emp          VARCHAR(100)    DEFAULT NULL,
      date_created            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_rid           (rid),
      INDEX idx_lead          (rid, crm_lead_id),
      INDEX idx_opportunity   (rid, crm_opportunity_id)
  );


USE `alpide-crm`;
DROP procedure IF EXISTS `count_crm_leads_list`;

USE `alpide-crm`;
DROP procedure IF EXISTS `alpide-crm`.`count_crm_leads_list`;
;

DELIMITER $$
USE `alpide-crm`$$
CREATE PROCEDURE `count_crm_leads_list`(
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
    In endUpdateDate TIMESTAMP,
    In leadStatusId INT
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
    
       IF (leadStatusId > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.status_id=", leadStatusId);
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
;




USE `alpide-crm`;
DROP procedure IF EXISTS `get_crm_leads_list`;

USE `alpide-crm`;
DROP procedure IF EXISTS `alpide-crm`.`get_crm_leads_list`;
;

DELIMITER $$
USE `alpide-crm`$$
CREATE PROCEDURE `get_crm_leads_list`(
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
    IN startUpdateDate TIMESTAMP,
    IN endUpdateDate TIMESTAMP,
    IN isConverted INT,
    IN leadScore VARCHAR(200),
    IN leadStatusId INT
)
BEGIN
    DECLARE whereClause TEXT;
    DECLARE idList VARCHAR(255);

    SET whereClause = CONCAT("cl.rid=", p_rid);
    SET whereClause = CONCAT(whereClause, " AND cl.is_active='", isActive, "'");
       IF (leadStatusId > 0) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.status_id=", leadStatusId);
    END IF;
    IF (searchedStr IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.lead_name LIKE '%", searchedStr, "%'");
        SET whereClause = CONCAT(whereClause, " OR ld.email LIKE '%", searchedStr, "%'");
        SET whereClause = CONCAT(whereClause, " OR ld.mobile_no LIKE '%", searchedStr, "%'");
    END IF;

    IF (projectName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND pm.project_name='", projectName, "'");
    END IF;
    
	IF (leadScore IS NOT NULL) THEN 
        SET whereClause = CONCAT(whereClause, " AND cl.lead_score='", leadScore, "'");
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
    
        IF (sourceName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.lead_source_name='", sourceName, "'");
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

    SET @stmt = 'SELECT
        DISTINCT cl.crm_lead_id                    AS crmLeadId,
        cl.rid                                     AS relationshipId,
        cl.lead_name                               AS leadName,
        cl.is_active                               AS isActive,
        cl.industry_code                           AS industryCode,
        cl.industry_name                           AS industryName,
        cl.company_type_code                       AS companyTypeCode,
        cl.company_type_name                       AS companyTypeName,
        cl.website                                 AS website,
        cl.lead_source_name                        AS leadSourceName,
        cl.is_existing_lead                        AS isExistingLead,
        cl.has_lead_contacted                      AS hasLeadContacted,
        cl.status_name                             AS statusName,
        cl.has_proposal_sent                       AS hasProposalSent,
        cl.remarks                                 AS remarks,
        cl.lead_source_id                          AS leadSourceId,
        cl.date_created                            AS dateCreated,
        cl.date_updated                            AS dateUpdated,
        cl.created_by                              AS createdBy,
        cl.updated_by                              AS updatedBy,
        cl.status_color_for_ui_cell                AS statusColorForUiCell,
        cl.status_id                               AS statusId,
        cl.star_rating                             AS starRating,
        cl.created_by_emp_id                       AS createdByEmpId,
        cl.updated_by_emp_id                       AS updatedByEmpId,
        cl.form_name                               AS formName,
        cl.crm_lead_form_setting_id                AS crmLeadFormSettingId,
        cl.is_lead_to_customer                     AS isLeadToCustomer,
        clr.reminder_title                         AS reminderTitle,
        ld.full_name                               AS fullName,
        ld.email                                   AS email,
        ld.mobile_no                               AS mobileNo,
        COALESCE(cln.notesCount, 0)                AS totalNotes,
        cl.stage_status_name                       AS stageStatusName,

        /* ── NEW: Next scheduled activity ───────────────────────────── */
        nxa.title                                  AS nextActivityTitle,
        nxa.activity_type                          AS nextActivityType,
        nxa.scheduled_at                           AS nextActivityScheduledAt,
        nxa.assigned_to_emp_name                   AS nextActivityAssignedTo,

        /* ── NEW: BANT score (0-5) ──────────────────────────────────── */
        COALESCE(bant.score, 0)                    AS bantScore,

        /* ── NEW: Lead score (Hot/Warm/Cold) ────────────────────────── */
        COALESCE(cl.lead_score, ''Cold'')           AS leadScore,

        /* ── NEW: Conversion fields ─────────────────────────────────── */
        cl.is_converted                            AS isConverted,
        cl.converted_at                            AS convertedAt,
        cl.company_name                            AS companyName,
        cl.competitor                              AS competitor

        FROM crm_lead cl
        LEFT JOIN crm_lead_reminder clr
            ON cl.crm_lead_id = clr.crm_lead_id
        LEFT JOIN (
            SELECT crm_lead_id, COUNT(*) AS notesCount
            FROM crm_lead_notes
            GROUP BY crm_lead_id
        ) cln ON cl.crm_lead_id = cln.crm_lead_id
        LEFT JOIN crm_lead_emp_assigned clea
            ON cl.crm_lead_id = clea.crm_lead_id
        LEFT JOIN crm_lead_form_setting clfs
            ON cl.crm_lead_form_setting_id = clfs.crm_lead_form_setting_id
        LEFT JOIN (
            SELECT crm_lead_id,
                MAX(CASE WHEN label = "Full Name"  THEN value END) AS full_name,
                MAX(CASE WHEN label = "Email"      THEN value END) AS email,
                MAX(CASE WHEN label = "Mobile No." THEN value END) AS mobile_no
            FROM crm_lead_detail
            GROUP BY crm_lead_id
        ) ld ON cl.crm_lead_id = ld.crm_lead_id

        /* ── Next upcoming scheduled activity per lead ──────────────── */
        LEFT JOIN (
            SELECT sa.entity_id,
                   sa.title,
                   sa.activity_type,
                   sa.scheduled_at,
                   sa.assigned_to_emp_name
            FROM crm_scheduled_activity sa
            INNER JOIN (
                SELECT entity_id, MIN(scheduled_at) AS min_scheduled_at
                FROM crm_scheduled_activity
                WHERE entity_type = ''LEAD''
                  AND status = ''SCHEDULED''
                  AND scheduled_at > NOW()
                GROUP BY entity_id
            ) nxt ON sa.entity_id = nxt.entity_id
                  AND sa.scheduled_at = nxt.min_scheduled_at
                  AND sa.entity_type = ''LEAD''
        ) nxa ON cl.crm_lead_id = nxa.entity_id

        /* ── BANT record ────────────────────────────────────────────── */
        LEFT JOIN crm_lead_bant bant
            ON cl.crm_lead_id = bant.crm_lead_id

        WHERE ';

    SET @stmt1 = CONCAT(
        @stmt,
        whereClause,
        ' ORDER BY cl.date_updated DESC LIMIT ',
        pageSize,
        ' OFFSET ',
        pageNumber * pageSize
    );

    PREPARE stmt2 FROM @stmt1;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
    DROP TEMPORARY TABLE IF EXISTS temp_ids;

END$$

DELIMITER ;
;

ALTER TABLE `alpide-crm`.`crm_audit_trail` 
CHANGE COLUMN `entity_type` `entity_type` VARCHAR(255) NOT NULL ,
CHANGE COLUMN `action` `action` VARCHAR(255) NOT NULL ;


USE `alpide-crm`;
DROP procedure IF EXISTS `get_crm_leads_list`;

USE `alpide-crm`;
DROP procedure IF EXISTS `alpide-crm`.`get_crm_leads_list`;
;

DELIMITER $$
USE `alpide-crm`$$
CREATE DEFINER=`alpide`@`%` PROCEDURE `get_crm_leads_list`(
      IN p_rid              INT,
      IN searchedStr        VARCHAR(45),
      IN projectName        VARCHAR(45),
      IN crmLeadFormSettingId INT,
      IN leadAssignTo       VARCHAR(255),
      IN sourceName         VARCHAR(45),
      IN statusName         VARCHAR(45),    -- kept for compat, no longer used in WHERE
      IN startDate          TIMESTAMP,
      IN endDate            TIMESTAMP,
      IN reminderType       VARCHAR(45),
      IN pageNumber         INT,
      IN pageSize           INT,
      IN isActive           INT,
      IN stageStatusName    VARCHAR(100),
      IN startUpdateDate    TIMESTAMP,
      IN endUpdateDate      TIMESTAMP,
      IN isConverted        INT,
      IN leadScore          VARCHAR(200),
      IN leadStatusId       INT
  )
BEGIN
      DECLARE whereClause TEXT;
      DECLARE idList      VARCHAR(255);

      SET whereClause = CONCAT('cl.rid=', p_rid);
      SET whereClause = CONCAT(whereClause, ' AND cl.is_active=''', isActive, '''');

      -- filter by status_id (stable) — status_name ignored
      IF (leadStatusId > 0) THEN
          SET whereClause = CONCAT(whereClause, ' AND cl.status_id=', leadStatusId);
      END IF;

      IF (searchedStr IS NOT NULL) THEN
          SET whereClause = CONCAT(whereClause, " AND cl.lead_name LIKE '%", searchedStr, "%'");
          SET whereClause = CONCAT(whereClause, " OR ld.email LIKE '%", searchedStr, "%'");
          SET whereClause = CONCAT(whereClause, " OR ld.mobile_no LIKE '%", searchedStr, "%'");
      END IF;

      IF (projectName IS NOT NULL) THEN
          SET whereClause = CONCAT(whereClause, " AND pm.project_name='", projectName, "'");
      END IF;

      IF (leadScore IS NOT NULL) THEN
          SET whereClause = CONCAT(whereClause, " AND cl.lead_score='", leadScore, "'");
      END IF;

      IF (crmLeadFormSettingId > 0) THEN
          SET whereClause = CONCAT(whereClause, ' AND cl.crm_lead_form_setting_id=', crmLeadFormSettingId);
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
          SET whereClause = CONCAT(whereClause, ' AND clea.rel_employee_id IN (SELECT id FROM temp_ids)');
      END IF;

      -- sourceName (deduplicated — was appearing twice before)
      IF (sourceName IS NOT NULL) THEN
          SET whereClause = CONCAT(whereClause, " AND cl.lead_source_name='", sourceName, "'");
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

       SET @stmt = '
      SELECT DISTINCT
          cl.crm_lead_id                              AS crmLeadId,            /* 0  */
          cl.rid                                      AS relationshipId,        /* 1  */
          cl.lead_name                                AS leadName,              /* 2  */
          cl.is_active                                AS isActive,              /* 3  */
          cl.industry_code                            AS industryCode,          /* 4  */
          cl.industry_name                            AS industryName,          /* 5  */
          cl.company_type_code                        AS companyTypeCode,       /* 6  */
          cl.company_type_name                        AS companyTypeName,       /* 7  */
          cl.website                                  AS website,               /* 8  */
          cl.lead_source_name                          AS leadSourceName,        /* 9  */
          cl.is_existing_lead                         AS isExistingLead,        /* 10 */
          cl.has_lead_contacted                       AS hasLeadContacted,      /* 11 */
          COALESCE(cls.status_name, cl.status_name)   AS statusName,            /* 12 — live name */
          cl.has_proposal_sent                        AS hasProposalSent,       /* 13 */
          cl.remarks                                  AS remarks,               /* 14 */
          cl.lead_source_id                           AS leadSourceId,          /* 15 */
          cl.date_created                             AS dateCreated,           /* 16 */
          cl.date_updated                             AS dateUpdated,           /* 17 */
          cl.created_by                               AS createdBy,             /* 18 */
          cl.updated_by                               AS updatedBy,             /* 19 */
          COALESCE(cls.status_color_for_ui_cell,
                   cl.status_color_for_ui_cell)       AS statusColorForUiCell,  /* 20 — live colour */
          cl.status_id                                AS statusId,              /* 21 */
          cl.star_rating                              AS starRating,            /* 22 */
          cl.created_by_emp_id                        AS createdByEmpId,        /* 23 */
          cl.updated_by_emp_id                        AS updatedByEmpId,        /* 24 */
          cl.form_name                                AS formName,              /* 25 */
          cl.crm_lead_form_setting_id                 AS crmLeadFormSettingId,  /* 26 */
          cl.is_lead_to_customer                      AS isLeadToCustomer,      /* 27 */
          clr.reminder_title                          AS reminderTitle,         /* 28 */
          ld.full_name                                AS fullName,              /* 29 */
          ld.email                                    AS email,                 /* 30 */
          ld.mobile_no                                AS mobileNo,              /* 31 */
          COALESCE(cln.notesCount, 0)                 AS totalNotes,            /* 32 */
          cl.stage_status_name                        AS stageStatusName,       /* 33 */

          /* next scheduled activity */
          nxa.title                                   AS nextActivityTitle,     /* 34 */
          nxa.activity_type                           AS nextActivityType,      /* 35 */
          nxa.scheduled_at                            AS nextActivityScheduledAt,/* 36 */
          nxa.assigned_to_emp_name                    AS nextActivityAssignedTo, /* 37 */

          COALESCE(bant.score, 0)                     AS bantScore,             /* 38 */
          COALESCE(cl.lead_score, ''Cold'')            AS leadScore,             /* 39 */
          cl.is_converted                             AS isConverted,           /* 40 */
          cl.converted_at                             AS convertedAt,           /* 41 */
          cl.company_name                             AS companyName,           /* 42 */
          cl.competitor                               AS competitor,            /* 43 */

          /* last activity from crm_lead_activity */
          la.change_description                       AS lastActivity,          /* 44 */
          la.date_created                             AS lastActivityDate       /* 45 */
      FROM crm_lead cl
          /* live status name + colour */
          LEFT JOIN crm_lead_status cls
              ON cls.lead_status_id = cl.status_id
              AND cls.rid = cl.rid

          LEFT JOIN crm_lead_reminder clr
              ON cl.crm_lead_id = clr.crm_lead_id

          LEFT JOIN (
              SELECT crm_lead_id, COUNT(*) AS notesCount
              FROM crm_lead_notes
              GROUP BY crm_lead_id
          ) cln ON cl.crm_lead_id = cln.crm_lead_id

          LEFT JOIN crm_lead_emp_assigned clea
              ON cl.crm_lead_id = clea.crm_lead_id

          LEFT JOIN crm_lead_form_setting clfs
              ON cl.crm_lead_form_setting_id = clfs.crm_lead_form_setting_id

          LEFT JOIN (
              SELECT crm_lead_id,
                  MAX(CASE WHEN label = "Full Name"  THEN value END) AS full_name,
                  MAX(CASE WHEN label = "Email"      THEN value END) AS email,
                  MAX(CASE WHEN label = "Mobile No." THEN value END) AS mobile_no
              FROM crm_lead_detail
              GROUP BY crm_lead_id
          ) ld ON cl.crm_lead_id = ld.crm_lead_id

          /* next upcoming scheduled activity per lead */
          LEFT JOIN (
              SELECT sa.entity_id,
                     sa.title,
                     sa.activity_type,
                     sa.scheduled_at,
                     sa.assigned_to_emp_name
              FROM crm_scheduled_activity sa
              INNER JOIN (
                  SELECT entity_id, MIN(scheduled_at) AS min_scheduled_at
                  FROM crm_scheduled_activity
                  WHERE entity_type = ''LEAD''
                    AND status      = ''SCHEDULED''
                    AND scheduled_at > NOW()
                  GROUP BY entity_id
              ) nxt ON sa.entity_id       = nxt.entity_id
                    AND sa.scheduled_at   = nxt.min_scheduled_at
                    AND sa.entity_type    = ''LEAD''
          ) nxa ON cl.crm_lead_id = nxa.entity_id

          /* BANT */
          LEFT JOIN crm_lead_bant bant
              ON cl.crm_lead_id = bant.crm_lead_id

          /* latest activity from crm_lead_activity */
          LEFT JOIN (
              SELECT crm_lead_id, change_description, date_created                                                                                                                 
              FROM (
                  SELECT crm_lead_id, change_description, date_created,
                         ROW_NUMBER() OVER (PARTITION BY crm_lead_id ORDER BY date_created DESC) AS rn
                  FROM crm_lead_activity
              ) ranked
              WHERE rn = 1
          ) la ON la.crm_lead_id = cl.crm_lead_id

          WHERE ';

      SET @stmt1 = CONCAT(
          @stmt,
          whereClause,
          ' ORDER BY cl.date_updated DESC LIMIT ',
          pageSize,
          ' OFFSET ',
          pageNumber * pageSize
      );

      PREPARE stmt2 FROM @stmt1;
      EXECUTE stmt2;
      DEALLOCATE PREPARE stmt2;
      DROP TEMPORARY TABLE IF EXISTS temp_ids;
  END$$

DELIMITER ;
;

  CREATE TABLE `alpide-crm`.crm_config (
      crm_config_id       BIGINT      NOT NULL AUTO_INCREMENT PRIMARY KEY,
      rid                 BIGINT      NOT NULL UNIQUE,          -- one row per tenant
      stale_days_for_lead INT         DEFAULT NULL,
      created_by_emp_id   BIGINT      DEFAULT NULL,
      created_by_emp      VARCHAR(100) DEFAULT NULL,
      date_created        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_by_emp_id   BIGINT      DEFAULT NULL,
      updated_by_emp      VARCHAR(100) DEFAULT NULL,
      date_updated        TIMESTAMP   DEFAULT NULL,
      INDEX idx_rid (rid)
  );