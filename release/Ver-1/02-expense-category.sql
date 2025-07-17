CREATE TABLE `alpide-accounting`.`expense_category` (
                                                        `expense_category_id` bigint NOT NULL AUTO_INCREMENT,
                                                        `category_code` varchar(255) DEFAULT NULL,
                                                        `category_name` varchar(255) DEFAULT NULL,
                                                        `chart_of_account_details_id_cr` bigint DEFAULT NULL,
                                                        `chart_of_account_details_id_dr` bigint DEFAULT NULL,
                                                        `custom_fields` text,
                                                        `ledger_account_name_cr` varchar(255) DEFAULT NULL,
                                                        `ledger_account_name_dr` varchar(255) DEFAULT NULL,
                                                        `relationship_id` bigint DEFAULT '0',
                                                        `is_active` int DEFAULT '0',
                                                        `description` varchar(255) DEFAULT NULL,
                                                        PRIMARY KEY (`expense_category_id`)
);

CREATE TABLE `alpide-accounting`.`relationship_expense_category_form_data` (
                                                                               `expense_category_form_data_id` bigint NOT NULL AUTO_INCREMENT,
                                                                               `expense_category_id` bigint DEFAULT NULL,
                                                                               `expense_details_id` bigint DEFAULT NULL,
                                                                               `expense_master_id` bigint DEFAULT NULL,
                                                                               `field_name` varchar(255) DEFAULT NULL,
                                                                               `field_type` varchar(255) DEFAULT NULL,
                                                                               `field_value` varchar(255) DEFAULT NULL,
                                                                               `rid` bigint DEFAULT NULL,
                                                                               PRIMARY KEY (`expense_category_form_data_id`)
);

CREATE TABLE `alpide-accounting`.`relationship_expense_category_ref` (
                                                                         `id` bigint NOT NULL AUTO_INCREMENT,
                                                                         `expense_category_id` bigint DEFAULT NULL,
                                                                         `expense_master_id` bigint DEFAULT NULL,
                                                                         `rid` bigint DEFAULT NULL,
                                                                         PRIMARY KEY (`id`)
) ;

ALTER TABLE `alpide-accounting`.`relationship_expense_details`
    ADD COLUMN `expense_category_id` BIGINT NULL DEFAULT '0';