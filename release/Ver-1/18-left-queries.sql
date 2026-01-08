CREATE TABLE `alpide-logistics`.`seller_champ_creds` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `relationship_id` BIGINT NOT NULL COMMENT 'Customer relationship ID (foreign key reference)',
  `api_key` VARCHAR(500) NOT NULL COMMENT 'SellerChamp API key',
  `last_data_fetch_date` DATETIME DEFAULT NULL COMMENT 'Last time data was fetched from SellerChamp',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
  `updated_at` DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_relationship_id` (`relationship_id`),
  INDEX `idx_relationship_id` (`relationship_id`)
);

ALTER TABLE `alpide-sales`.`customer_invoice_details` 
ADD COLUMN `batch_rid` VARCHAR(255) NULL DEFAULT NULL AFTER `variant_attributes`;

ALTER TABLE `alpide-inventory`.`inventory_batch` 
ADD COLUMN `relationship_id` BIGINT DEFAULT NULL;