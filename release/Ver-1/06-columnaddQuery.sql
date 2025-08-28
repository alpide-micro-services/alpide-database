ALTER TABLE `alpide-inventory`.`inventory_item` ADD COLUMN customer_sku VARCHAR(200) DEFAULT NULL;
ALTER TABLE `alpide-commerce`.`ecom_blog_master` ADD COLUMN alt_tag VARCHAR(250) DEFAULT NULL;