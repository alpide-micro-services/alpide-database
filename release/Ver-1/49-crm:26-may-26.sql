  ALTER TABLE `alpide-crm`.`crm_pulse360_template`
      ADD COLUMN `lead_selections` TEXT NULL
          COMMENT '[{stageId,stageName,stageSelected,statusIds[],statuses[]}, ...]'
          AFTER `lead_stages`,
      ADD COLUMN `opp_selections`  TEXT NULL
          COMMENT '[{stageId,stageName,stageSelected,statusIds[],statuses[]}, ...]'
          AFTER `opp_stages`;
          

           ALTER TABLE `alpide-crm`.crm_manual_communication_log
    ADD COLUMN crm_lead_account_id BIGINT NULL AFTER crm_opportunity_id;