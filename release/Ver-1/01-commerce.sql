ALTER TABLE `alpide-commerce`.`ecom_setting` ADD COLUMN website_content text;

ALTER TABLE `alpide-commerce`.`ecom_setting` ADD COLUMN website_sequence_data text;

ALTER TABLE `alpide-commerce`.`ecom_usp_meta` ADD COLUMN type varchar(200) default null;
