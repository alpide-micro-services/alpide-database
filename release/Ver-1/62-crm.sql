    CREATE TABLE IF NOT EXISTS `alpide-crm`.`crm_view_preference` (
        `preference_id`              BIGINT       NOT NULL AUTO_INCREMENT,
        `rid`                        BIGINT       NOT NULL COMMENT 'relationshipId (tenant key)',
       `emp_id`                     BIGINT       NOT NULL COMMENT 'Employee whose preference this is',
       `emp_name`                   VARCHAR(200) NULL,
       `entity_type`                VARCHAR(20)  NOT NULL COMMENT 'LEAD | OPPORTUNITY',
  
       -- Kanban column visibility
       `kanban_hidden_stage_ids`    TEXT         NULL COMMENT 'JSON array of stage IDs hidden in Kanban, e.g. [1,3]',
       `kanban_hidden_status_ids`   TEXT         NULL COMMENT 'JSON array of sub-status IDs hidden in Kanban, e.g. [10,12]',
  
       `date_created`               TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
       `date_updated`               TIMESTAMP    NULL     ON UPDATE CURRENT_TIMESTAMP,
  
       PRIMARY KEY (`preference_id`),
       UNIQUE KEY  `uq_view_pref_emp_entity` (`rid`, `emp_id`, `entity_type`),
       INDEX       `idx_view_pref_lookup`    (`rid`, `emp_id`, `entity_type`)
  
   );



   
   
   -- ============================================================
--  Lead list procedures – v2
--  Fixes applied:
--    1. searchedStr OR block wrapped in parentheses (was breaking all AND
--       conditions before the OR via SQL precedence).
--    2. statusName filter added to get_crm_leads_list (was only in count).
--    3. Filter order made identical between both procedures.
--    4. fetchActiveLead=1 is now self-contained in the SP:
--         is_active=1, is_converted=0, excluded stage_status_ids from config
--       matching exactly what /v1/lead-report/summary counts as "active".
-- ============================================================

USE `alpide-crm`;
DROP PROCEDURE IF EXISTS `get_crm_leads_list`;

DELIMITER $$

CREATE DEFINER=`alpide`@`%` PROCEDURE `get_crm_leads_list`(
    IN p_rid                INT,
    IN searchedStr          VARCHAR(45),
    IN projectName          VARCHAR(45),
    IN crmLeadFormSettingId INT,
    IN leadAssignTo         VARCHAR(255),
    IN sourceName           VARCHAR(45),
    IN statusName           VARCHAR(45),
    IN startDate            TIMESTAMP,
    IN endDate              TIMESTAMP,
    IN reminderType         VARCHAR(45),
    IN pageNumber           INT,
    IN pageSize             INT,
    IN isActive             INT,
    IN stageStatusName      VARCHAR(100),
    IN startUpdateDate      TIMESTAMP,
    IN endUpdateDate        TIMESTAMP,
    IN isConverted          INT,
    IN leadScore            VARCHAR(200),
    IN leadStatusId         INT,
    IN isStale              INT,
    IN leadStageStatusId    INT,
    IN fetchActiveLead      INT
)
BEGIN
    DECLARE whereClause    TEXT;
    DECLARE idList         VARCHAR(255);
    DECLARE v_stale_days   INT DEFAULT 30;
    DECLARE v_excluded_ids VARCHAR(500) DEFAULT NULL;

    -- ── Load config values ────────────────────────────────────────────────────
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

    IF (fetchActiveLead = 1) THEN
        SELECT COALESCE(excluded_lead_status_ids, '')
        INTO   v_excluded_ids
        FROM   crm_config
        WHERE  rid = p_rid
        LIMIT  1;
    END IF;

    -- ── Base WHERE ────────────────────────────────────────────────────────────
    SET whereClause = CONCAT('cl.rid=', p_rid);

    -- fetchActiveLead=1 enforces is_active=1 inside the SP regardless of param
    IF (fetchActiveLead = 1) THEN
        SET whereClause = CONCAT(whereClause, ' AND cl.is_active=1');
    ELSE
        SET whereClause = CONCAT(whereClause, ' AND cl.is_active=''', isActive, '''');
    END IF;

    -- ── Filters (identical order to count procedure) ──────────────────────────

    IF (leadStatusId IS NOT NULL AND leadStatusId > 0) THEN
        SET whereClause = CONCAT(whereClause, ' AND cl.status_id=', leadStatusId);
    END IF;

    -- FIX: wrap in parentheses so OR does not escape the AND chain
    IF (searchedStr IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause,
            " AND (cl.lead_name LIKE '%", searchedStr, "%'",
            " OR ld.email LIKE '%",      searchedStr, "%'",
            " OR ld.mobile_no LIKE '%",  searchedStr, "%')");
    END IF;

    IF (projectName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND pm.project_name='", projectName, "'");
    END IF;

    IF (leadScore IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.lead_score='", leadScore, "'");
    END IF;

    IF (crmLeadFormSettingId IS NOT NULL AND crmLeadFormSettingId > 0) THEN
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

    IF (sourceName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.lead_source_name='", sourceName, "'");
    END IF;

    -- FIX: was missing from list SP (present in count SP)
    IF (statusName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.status_name='", statusName, "'");
    END IF;

    -- fetchActiveLead=1 forces is_converted=0; otherwise use the passed value
    IF (fetchActiveLead = 1) THEN
        SET whereClause = CONCAT(whereClause, ' AND cl.is_converted=0');
    ELSEIF (isConverted IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.is_converted='", isConverted, "'");
    END IF;

    IF (stageStatusName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.stage_status_name='", stageStatusName, "'");
    END IF;

    IF (leadStageStatusId IS NOT NULL AND leadStageStatusId > 0) THEN
        SET whereClause = CONCAT(whereClause, ' AND cl.stage_status_id=', leadStageStatusId);
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
            ' AND cl.is_converted=0',
            ' AND DATEDIFF(CURDATE(), DATE(COALESCE(cl.date_updated, cl.date_created, CURDATE()))) > ',
            v_stale_days);
    END IF;

    -- fetchActiveLead: exclude stage_status_ids from config
    -- Matches exactly: is_active=1, is_converted=0, stage_status_id NOT IN (excluded)
    -- which is what /v1/lead-report/summary uses for "active leads".
    IF (fetchActiveLead = 1 AND v_excluded_ids IS NOT NULL AND LENGTH(TRIM(v_excluded_ids)) > 0) THEN
        SET whereClause = CONCAT(whereClause,
            ' AND (cl.stage_status_id IS NULL OR cl.stage_status_id NOT IN (',
            v_excluded_ids,
            '))');
    END IF;

    -- ── Main SELECT ───────────────────────────────────────────────────────────
    SET @stmt = '
    SELECT DISTINCT
        cl.crm_lead_id                              AS crmLeadId,
        cl.rid                                      AS relationshipId,
        cl.lead_name                                AS leadName,
        cl.is_active                                AS isActive,
        cl.industry_code                            AS industryCode,
        cl.industry_name                            AS industryName,
        cl.company_type_code                        AS companyTypeCode,
        cl.company_type_name                        AS companyTypeName,
        cl.website                                  AS website,
        cl.lead_source_name                         AS leadSourceName,
        cl.is_existing_lead                         AS isExistingLead,
        cl.has_lead_contacted                       AS hasLeadContacted,
        COALESCE(cls.status_name, cl.status_name)   AS statusName,
        cl.has_proposal_sent                        AS hasProposalSent,
        cl.remarks                                  AS remarks,
        cl.lead_source_id                           AS leadSourceId,
        cl.date_created                             AS dateCreated,
        cl.date_updated                             AS dateUpdated,
        cl.created_by                               AS createdBy,
        cl.updated_by                               AS updatedBy,
        COALESCE(cls.status_color_for_ui_cell,
                 cl.status_color_for_ui_cell)       AS statusColorForUiCell,
        cl.status_id                                AS statusId,
        cl.star_rating                              AS starRating,
        cl.created_by_emp_id                        AS createdByEmpId,
        cl.updated_by_emp_id                        AS updatedByEmpId,
        cl.form_name                                AS formName,
        cl.crm_lead_form_setting_id                 AS crmLeadFormSettingId,
        cl.is_lead_to_customer                      AS isLeadToCustomer,
        clr.reminder_title                          AS reminderTitle,
        ld.full_name                                AS fullName,
        ld.email                                    AS email,
        ld.mobile_no                                AS mobileNo,
        COALESCE(cln.notesCount, 0)                 AS totalNotes,
        cl.stage_status_name                        AS stageStatusName,
        nxa.title                                   AS nextActivityTitle,
        nxa.activity_type                           AS nextActivityType,
        nxa.scheduled_at                            AS nextActivityScheduledAt,
        nxa.assigned_to_emp_name                    AS nextActivityAssignedTo,
        COALESCE(bant.score, 0)                     AS bantScore,
        COALESCE(cl.lead_score, ''Cold'')           AS leadScore,
        cl.is_converted                             AS isConverted,
        cl.converted_at                             AS convertedAt,
        cl.company_name                             AS companyName,
        cl.competitor                               AS competitor,
        la.change_description                       AS lastActivity,
        la.date_created                             AS lastActivityDate,
        cl.stage_status_id                          AS stageStatusId
    FROM crm_lead cl
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
            ) nxt ON sa.entity_id     = nxt.entity_id
                  AND sa.scheduled_at = nxt.min_scheduled_at
                  AND sa.entity_type  = ''LEAD''
        ) nxa ON cl.crm_lead_id = nxa.entity_id
        LEFT JOIN crm_lead_bant bant
            ON cl.crm_lead_id = bant.crm_lead_id
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

-- ============================================================

USE `alpide-crm`;
DROP PROCEDURE IF EXISTS `count_crm_leads_list`;

DELIMITER $$

CREATE DEFINER=`alpide`@`%` PROCEDURE `count_crm_leads_list`(
    IN p_rid                INT,
    IN searchedStr          VARCHAR(45),
    IN projectName          VARCHAR(45),
    IN crmLeadFormSettingId INT,
    IN leadAssignTo         VARCHAR(45),
    IN sourceName           VARCHAR(45),
    IN statusName           VARCHAR(45),
    IN startDate            TIMESTAMP,
    IN endDate              TIMESTAMP,
    IN reminderType         VARCHAR(45),
    IN startUpdateDate      TIMESTAMP,
    IN endUpdateDate        TIMESTAMP,
    IN isActive             INT,
    IN stageStatusName      VARCHAR(100),
    IN isConverted          INT,
    IN leadScore            VARCHAR(200),
    IN leadStatusId         INT,
    IN isStale              INT,
    IN leadStageStatusId    INT,
    IN fetchActiveLead      INT
)
BEGIN
    DECLARE whereClause    TEXT;
    DECLARE idList         VARCHAR(255);
    DECLARE v_stale_days   INT DEFAULT 30;
    DECLARE v_excluded_ids VARCHAR(500) DEFAULT NULL;

    -- ── Load config values ────────────────────────────────────────────────────
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

    IF (fetchActiveLead = 1) THEN
        SELECT COALESCE(excluded_lead_status_ids, '')
        INTO   v_excluded_ids
        FROM   crm_config
        WHERE  rid = p_rid
        LIMIT  1;
    END IF;

    -- ── Base WHERE ────────────────────────────────────────────────────────────
    SET whereClause = CONCAT('cl.rid=', p_rid);

    IF (fetchActiveLead = 1) THEN
        SET whereClause = CONCAT(whereClause, ' AND cl.is_active=1');
    ELSE
        SET whereClause = CONCAT(whereClause, ' AND cl.is_active=''', isActive, '''');
    END IF;

    -- ── Filters (identical order to list procedure) ───────────────────────────

    IF (leadStatusId IS NOT NULL AND leadStatusId > 0) THEN
        SET whereClause = CONCAT(whereClause, ' AND cl.status_id=', leadStatusId);
    END IF;

    -- FIX: wrap in parentheses so OR does not escape the AND chain
    IF (searchedStr IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause,
            " AND (cl.lead_name LIKE '%", searchedStr, "%'",
            " OR ld.email LIKE '%",      searchedStr, "%'",
            " OR ld.mobile_no LIKE '%",  searchedStr, "%')");
    END IF;

    IF (projectName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND pm.project_name='", projectName, "'");
    END IF;

    IF (leadScore IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.lead_score='", leadScore, "'");
    END IF;

    IF (crmLeadFormSettingId IS NOT NULL AND crmLeadFormSettingId > 0) THEN
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

    IF (sourceName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.lead_source_name='", sourceName, "'");
    END IF;

    IF (statusName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.status_name='", statusName, "'");
    END IF;

    IF (fetchActiveLead = 1) THEN
        SET whereClause = CONCAT(whereClause, ' AND cl.is_converted=0');
    ELSEIF (isConverted IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.is_converted='", isConverted, "'");
    END IF;

    IF (stageStatusName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.stage_status_name='", stageStatusName, "'");
    END IF;

    IF (leadStageStatusId IS NOT NULL AND leadStageStatusId > 0) THEN
        SET whereClause = CONCAT(whereClause, ' AND cl.stage_status_id=', leadStageStatusId);
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
            ' AND cl.is_converted=0',
            ' AND DATEDIFF(CURDATE(), DATE(COALESCE(cl.date_updated, cl.date_created, CURDATE()))) > ',
            v_stale_days);
    END IF;

    IF (fetchActiveLead = 1 AND v_excluded_ids IS NOT NULL AND LENGTH(TRIM(v_excluded_ids)) > 0) THEN
        SET whereClause = CONCAT(whereClause,
            ' AND (cl.stage_status_id IS NULL OR cl.stage_status_id NOT IN (',
            v_excluded_ids,
            '))');
    END IF;

    -- ── Count SELECT ──────────────────────────────────────────────────────────
    SET @stmt = 'SELECT COUNT(DISTINCT cl.crm_lead_id) AS total_count
                FROM crm_lead cl
                    LEFT JOIN crm_lead_reminder clr
                        ON cl.crm_lead_id = clr.crm_lead_id
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
                WHERE ';

    SET @stmt1 = CONCAT(@stmt, whereClause);
    PREPARE stmt2 FROM @stmt1;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
    DROP TEMPORARY TABLE IF EXISTS temp_ids;
END$$

DELIMITER ;

  