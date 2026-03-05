ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_master`
    ADD COLUMN `is_approval_required` INT NULL DEFAULT '0' AFTER `grn_source`;