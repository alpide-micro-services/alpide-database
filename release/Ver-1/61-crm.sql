-- ============================================================
--  Lead list procedures – v2
--  New params added (at end of each signature to stay backward-safe):
--    leadStageStatusId  INT       – filter by cl.stage_status_id
--    fetchActiveLead    INT       – 1 = active leads only
--                                   (not converted + is_active=1
--                                    + excluded_lead_status_ids from crm_config)
-- ============================================================

USE `alpide-crm`;
DROP PROCEDURE IF EXISTS `get_crm_leads_list`;

DELIMITER $$

CREATE  PROCEDURE `get_crm_leads_list`(
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
    IN leadStageStatusId    INT,        -- NEW: filter by stage_status_id
    IN fetchActiveLead      INT         -- NEW: 1 = active leads only
)
BEGIN
    DECLARE whereClause      TEXT;
    DECLARE idList           VARCHAR(255);
    DECLARE v_stale_days     INT DEFAULT 30;
    DECLARE v_excluded_ids   VARCHAR(500) DEFAULT NULL;

    -- ── Stale threshold from config ───────────────────────────────────────────
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

    -- ── Excluded status IDs from config (for fetchActiveLead) ─────────────────
    IF (fetchActiveLead = 1) THEN
        SELECT COALESCE(excluded_lead_status_ids, '')
        INTO   v_excluded_ids
        FROM   crm_config
        WHERE  rid = p_rid
        LIMIT  1;
    END IF;

    -- ── Base WHERE ────────────────────────────────────────────────────────────
    SET whereClause = CONCAT('cl.rid=', p_rid);
    SET whereClause = CONCAT(whereClause, ' AND cl.is_active=''', isActive, '''');

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

    IF (sourceName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.lead_source_name='", sourceName, "'");
    END IF;

    IF (isConverted IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.is_converted='", isConverted, "'");
    END IF;

    IF (stageStatusName IS NOT NULL) THEN
        SET whereClause = CONCAT(whereClause, " AND cl.stage_status_name='", stageStatusName, "'");
    END IF;

    -- ── NEW: filter by stage_status_id ────────────────────────────────────────
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
            " AND cl.is_converted = 0",
            " AND DATEDIFF(CURDATE(), DATE(COALESCE(cl.date_updated, cl.date_created, CURDATE()))) > ",
            v_stale_days);
    END IF;

    -- ── NEW: fetchActiveLead – exclude converted, disqualified, excluded statuses
    IF (fetchActiveLead = 1) THEN
        -- is_converted=0 and is_active=1 are already enforced by the Java layer
        -- via the isActive and isConverted params above; here we only add the
        -- config-driven excluded status IDs.
        IF v_excluded_ids IS NOT NULL AND LENGTH(TRIM(v_excluded_ids)) > 0 THEN
            SET whereClause = CONCAT(whereClause,
                ' AND (cl.stage_status_id IS NULL OR cl.stage_status_id NOT IN (',
                v_excluded_ids,
                '))');
        END IF;
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
        COALESCE(cl.lead_score, ''Cold'')            AS leadScore,
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
            ) nxt ON sa.entity_id       = nxt.entity_id
                  AND sa.scheduled_at   = nxt.min_scheduled_at
                  AND sa.entity_type    = ''LEAD''
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
--  count_crm_leads_list – v2
-- ============================================================

USE `alpide-crm`;
DROP PROCEDURE IF EXISTS `count_crm_leads_list`;

DELIMITER $$

CREATE PROCEDURE `count_crm_leads_list`(
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
    IN leadStageStatusId    INT,        -- NEW
    IN fetchActiveLead      INT         -- NEW
)
BEGIN
    DECLARE whereClause    TEXT;
    DECLARE idList         VARCHAR(255);
    DECLARE v_stale_days   INT DEFAULT 30;
    DECLARE v_excluded_ids VARCHAR(500) DEFAULT NULL;

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

    -- ── NEW: filter by stage_status_id ────────────────────────────────────────
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
            " AND cl.is_converted = 0",
            " AND DATEDIFF(CURDATE(), DATE(COALESCE(cl.date_updated, cl.date_created, CURDATE()))) > ",
            v_stale_days);
    END IF;

    -- ── NEW: fetchActiveLead ──────────────────────────────────────────────────
    IF (fetchActiveLead = 1) THEN
        IF v_excluded_ids IS NOT NULL AND LENGTH(TRIM(v_excluded_ids)) > 0 THEN
            SET whereClause = CONCAT(whereClause,
                ' AND (cl.stage_status_id IS NULL OR cl.stage_status_id NOT IN (',
                v_excluded_ids,
                '))');
        END IF;
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


   ALTER TABLE `alpide-crm`.`crm_reminder`
       ADD COLUMN  `notify_before_minutes` INT        NOT NULL DEFAULT 15           AFTER `remind_at`,
       ADD COLUMN  `notify_via_whatsapp`   TINYINT(1) NOT NULL DEFAULT 1            AFTER `notify_before_minutes`,
       ADD COLUMN `notify_via_email`      TINYINT(1) NOT NULL DEFAULT 1            AFTER `notify_via_whatsapp`,
       ADD COLUMN  `email_template_id`     BIGINT     NULL                          AFTER `notify_via_email`;