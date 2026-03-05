
ALTER TABLE `alpide-inventory`.`inventory_item`
    ADD COLUMN `is_finish_product` int DEFAULT '0';

ALTER TABLE `alpide-inventory`.`inventory_item`
    ADD COLUMN `is_purchased_part` int DEFAULT '0';

ALTER TABLE `alpide-inventory`.`inventory_item`
    ADD COLUMN `is_raw_material` int DEFAULT '0';

ALTER TABLE `alpide-inventory`.`inventory_item`
    ADD COLUMN `is_subassembly` INT NULL DEFAULT '0' AFTER `is_raw_material`;
