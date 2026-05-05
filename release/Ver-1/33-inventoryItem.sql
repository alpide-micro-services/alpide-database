ALTER TABLE `alpide-inventory`.`inventory_item` 
ADD COLUMN `is_active` INT NULL DEFAULT 1 AFTER `is_service_product`;