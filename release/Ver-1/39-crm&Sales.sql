USE `alpide-manufacturing`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `alpide-manufacturing`.`v_so_production_tracking` AS with `so_wo_stats` as (select `wo`.`so_master_id` AS `so_master_id`,`wo`.`rid` AS `rid`,count(`wo`.`work_order_id`) AS `total_wo`,sum((case when (upper(`wo`.`status`) = 'COMPLETED') then 1 else 0 end)) AS `completed_wo`,round(((sum((case when (upper(`wo`.`status`) = 'COMPLETED') then 1 else 0 end)) / nullif(count(`wo`.`work_order_id`),0)) * 100),0) AS `progress_pct`,max(`wo`.`date_updated`) AS `date_updated` from `alpide-manufacturing`.`mrp_work_order` `wo` where ((`wo`.`order_type` = 'Production') and (upper(`wo`.`status`) <> 'CANCELLED')) group by `wo`.`so_master_id`,`wo`.`rid`), `so_scpo_stats` as (select `wo`.`so_master_id` AS `so_master_id`,`wo`.`rid` AS `rid`,count(distinct `sc`.`sc_po_master_id`) AS `open_sc_po`,count(distinct (case when (`sc`.`delivery_due_date` < curdate()) then `sc`.`sc_po_master_id` end)) AS `delayed_sc_po` from (`alpide-purchase`.`subcontract_po_master` `sc` join `alpide-manufacturing`.`mrp_work_order` `wo` on(((`wo`.`work_order_id` = `sc`.`work_order_id`) and (`wo`.`rid` = `sc`.`rid`)))) where ((`wo`.`order_type` = 'Production') and (lower(`sc`.`status`) not in ('closed','cancelled'))) group by `wo`.`so_master_id`,`wo`.`rid`), `so_item_count` as (select `sod`.`sales_order_master_id` AS `sales_order_master_id`,`sod`.`rid` AS `rid`,count(distinct `sod`.`item_id`) AS `item_count` from `alpide-sales`.`customer_sales_order_details` `sod` group by `sod`.`sales_order_master_id`,`sod`.`rid`) select `som`.`so_number` AS `so_number`,`som`.`customer_name` AS `customer`,cast(`som`.`sales_order_date` as date) AS `order_date`,cast(`som`.`sales_order_due_date` as date) AS `delivery_due`,(to_days(`som`.`sales_order_due_date`) - to_days(curdate())) AS `days_left`,(case when ((to_days(`som`.`sales_order_due_date`) - to_days(curdate())) < 0) then concat(abs((to_days(`som`.`sales_order_due_date`) - to_days(curdate()))),'d overdue') else concat((to_days(`som`.`sales_order_due_date`) - to_days(curdate())),'d') end) AS `days_left_label`,coalesce(`sic`.`item_count`,0) AS `items`,coalesce(`wos`.`total_wo`,0) AS `work_orders`,coalesce(`wos`.`completed_wo`,0) AS `completed_work_orders`,coalesce(`scp`.`open_sc_po`,0) AS `open_sc_pos`,coalesce(`scp`.`delayed_sc_po`,0) AS `delayed_sc_pos`,coalesce(`wos`.`progress_pct`,0) AS `progress_pct`,(case when ((to_days(`som`.`sales_order_due_date`) - to_days(`som`.`sales_order_date`)) = 0) then 100 else round(least((((to_days(curdate()) - to_days(`som`.`sales_order_date`)) / nullif((to_days(`som`.`sales_order_due_date`) - to_days(`som`.`sales_order_date`)),0)) * 100),100),0) end) AS `time_elapsed_pct`,(case when (lower(`som`.`status`) = 'fulfilled') then 'Completed' when (((to_days(`som`.`sales_order_due_date`) - to_days(curdate())) < 0) and (lower(`som`.`status`) <> 'fulfilled')) then 'Delayed' when (coalesce(`wos`.`progress_pct`,0) < ((case when ((to_days(`som`.`sales_order_due_date`) - to_days(`som`.`sales_order_date`)) = 0) then 100 else round(least((((to_days(curdate()) - to_days(`som`.`sales_order_date`)) / nullif((to_days(`som`.`sales_order_due_date`) - to_days(`som`.`sales_order_date`)),0)) * 100),100),0) end) - 20)) then 'At risk' else 'On track' end) AS `so_status`,`som`.`status` AS `raw_so_status`,`som`.`sales_order_master_id` AS `so_master_id`,`som`.`rid` AS `rid`,`som`.`order_priority` AS `priority`,greatest(coalesce(`som`.`date_updated`,'1970-01-01'),coalesce(`wos`.`date_updated`,'1970-01-01')) AS `date_updated` from (((`alpide-sales`.`customer_sales_order_master` `som` left join `so_item_count` `sic` on(((`sic`.`sales_order_master_id` = `som`.`sales_order_master_id`) and (`sic`.`rid` = `som`.`rid`)))) left join `so_wo_stats` `wos` on(((`wos`.`so_master_id` = `som`.`sales_order_master_id`) and (`wos`.`rid` = `som`.`rid`)))) left join `so_scpo_stats` `scp` on(((`scp`.`so_master_id` = `som`.`sales_order_master_id`) and (`scp`.`rid` = `som`.`rid`)))) where ((`som`.`status` not in ('Cancelled','cancelled')) and (`som`.`is_production_sales_order` = 1)) order by field((case when (lower(`som`.`status`) = 'fulfilled') then 'Completed' when ((to_days(`som`.`sales_order_due_date`) - to_days(curdate())) < 0) then 'Delayed' when (coalesce(`wos`.`progress_pct`,0) < ((case when ((to_days(`som`.`sales_order_due_date`) - to_days(`som`.`sales_order_date`)) = 0) then 100 else round(least((((to_days(curdate()) - to_days(`som`.`sales_order_date`)) / nullif((to_days(`som`.`sales_order_due_date`) - to_days(`som`.`sales_order_date`)),0)) * 100),100),0) end) - 20)) then 'At risk' else 'On track' end),'Delayed','At risk','On track','Completed'),`som`.`sales_order_due_date`;


USE `alpide-manufacturing`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `alpide-manufacturing`.`v_work_order_planning_view` AS
    SELECT 
        `wo`.`work_order_id` AS `work_order_id`,
        `wo`.`order_number` AS `wo_number`,
        `wo`.`item_description` AS `item_description`,
        `wo`.`sku` AS `item_sku`,
        `wo`.`quantity` AS `planned_qty`,
        `wo`.`start_date` AS `start_date`,
        `wo`.`due_date` AS `due_date`,
        `wo`.`status` AS `wo_status`, 
        `wo`.`work_center` AS `work_center`,
        `wo`.`item_id` AS `item_id`,
        `wo`.`uom` AS `uom`,
        `wo`.`so_master_id` AS `so_master_id`,
        `wo`.`rid` AS `rid`,
        `som`.`so_number` AS `so_number`,
        `som`.`customer_name` AS `customer_name`,
        `som`.`order_priority` AS `priority`,
        `som`.`sales_order_date` AS `sales_order_date`,
        `som`.`sales_order_due_date` AS `sales_order_due_date`,
        `som`.`status` AS `so_status`,
        COALESCE(CONVERT( `sod`.`item_name` USING UTF8MB4),
                `wo`.`item_description`) AS `item_name`,
        COALESCE(`sod`.`quantity`, `wo`.`quantity`) AS `so_quantity`,
        COALESCE(CONVERT( `sod`.`uom_name` USING UTF8MB4),
                `wo`.`uom`) AS `uom_name`,
        (TO_DAYS(`wo`.`due_date`) - TO_DAYS(`wo`.`start_date`)) AS `lead_time_days`,
        (CASE
            WHEN (`wo`.`status` = 'COMPLETED') THEN 'Ready'
            WHEN (`wo`.`status` = 'PRODUCTION') THEN 'Partial'
            ELSE 'Pending'
        END) AS `rm_status`,
        `wo`.`date_updated` AS `date_updated`
    FROM
        ((`alpide-manufacturing`.`mrp_work_order` `wo`
        LEFT JOIN `alpide-sales`.`customer_sales_order_master` `som` ON (((`wo`.`so_master_id` = `som`.`sales_order_master_id`)
            AND (`wo`.`rid` = `som`.`rid`))))
        LEFT JOIN `alpide-sales`.`customer_sales_order_details` `sod` ON (((`wo`.`so_master_id` = `sod`.`sales_order_master_id`)
            AND (`wo`.`item_id` = `sod`.`item_id`)
            AND (`wo`.`rid` = `sod`.`rid`))))
    WHERE
        ((`wo`.`order_type` = 'Production')
            AND (`wo`.`status` <> 'Cancelled'))
    ORDER BY `wo`.`start_date` DESC , `wo`.`order_number` DESC;


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
    IN isConverted INT
)
BEGIN
    DECLARE whereClause TEXT;
    DECLARE idList VARCHAR(255);

    SET whereClause = CONCAT("cl.rid=", p_rid);
    SET whereClause = CONCAT(whereClause, " AND cl.is_active='", isActive, "'");

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
        cl.company_name                            AS companyName

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

