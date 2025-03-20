ALTER TABLE `alpide-commerce`.`ecom_setting` ADD COLUMN website_content text;

ALTER TABLE `alpide-commerce`.`ecom_setting`
CHANGE COLUMN `website_sequence_data` `website_sequence_data` MEDIUMTEXT NULL DEFAULT NULL ;


ALTER TABLE `alpide-education`.`org_registration_form_setting_permissions` ADD COLUMN first_name varchar(140) default null;
ALTER TABLE `alpide-education`.`org_registration_form_setting_permissions` ADD COLUMN last_name varchar(140) default null;
