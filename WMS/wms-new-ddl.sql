CREATE TABLE `alpide-inventory`.`wms_batch` (
  `batch_id` bigint NOT NULL AUTO_INCREMENT,
  `created_by_user_id` bigint DEFAULT NULL,
  `date_created` timestamp NULL DEFAULT NULL,
  `date_updated` timestamp NULL DEFAULT NULL,
  `updated_by_user_id` bigint DEFAULT NULL,
  `attributes` json DEFAULT NULL,
  `batch_number` varchar(255) NOT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `is_coo_print` bit(1) NOT NULL,
  `is_deleted` bit(1) DEFAULT NULL,
  `is_item_name_print` bit(1) NOT NULL,
  `is_mfg_date_print` bit(1) NOT NULL,
  `is_sku_print` bit(1) NOT NULL,
  `is_sled_print` bit(1) NOT NULL,
  `item_name` varchar(255) DEFAULT NULL,
  `mfg_date` timestamp NULL DEFAULT NULL,
  `origin_of_country` varchar(255) DEFAULT NULL,
  `rid` bigint DEFAULT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `sled` timestamp NULL DEFAULT NULL,
  `version` bigint NOT NULL,
  `created_by_emp_id` int DEFAULT NULL,
  `date_deleted` datetime(6) DEFAULT NULL,
  `date_inactivated` datetime(6) DEFAULT NULL,
  `deleted_by_emp_id` int DEFAULT NULL,
  `inactivated_by_emp_id` int DEFAULT NULL,
  `updated_by_emp_id` int DEFAULT NULL,
  PRIMARY KEY (`batch_id`),
  UNIQUE KEY `UK_bm6je971b5mksf1jvictlinp7` (`batch_number`)
);

CREATE TABLE `alpide-inventory`.`wms_packing_unit` (
  `package_unit_id` bigint NOT NULL AUTO_INCREMENT,
  `created_by_user_id` bigint DEFAULT NULL,
  `date_created` datetime(6) DEFAULT NULL,
  `date_updated` datetime(6) DEFAULT NULL,
  `updated_by_user_id` bigint DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `dimension` varchar(255) DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `is_deleted` bit(1) DEFAULT NULL,
  `package_name` varchar(255) DEFAULT NULL,
  `rid` bigint DEFAULT NULL,
  `version` bigint NOT NULL,
  `weight` varchar(255) DEFAULT NULL,
  `dimension_unit` varchar(255) DEFAULT NULL,
  `weight_unit` varchar(255) DEFAULT NULL,
  `created_by_emp_id` int DEFAULT NULL,
  `date_deleted` datetime(6) DEFAULT NULL,
  `date_inactivated` datetime(6) DEFAULT NULL,
  `deleted_by_emp_id` int DEFAULT NULL,
  `inactivated_by_emp_id` int DEFAULT NULL,
  `updated_by_emp_id` int DEFAULT NULL,
  PRIMARY KEY (`package_unit_id`)
);

CREATE TABLE `alpide-inventory`.`wms_picking_strategy_config` (
  `picking_strategy_config_id` bigint NOT NULL AUTO_INCREMENT,
  `item_id` bigint DEFAULT NULL,
  `priority_level` int NOT NULL,
  `status` bit(1) NOT NULL,
  `strategy_type` enum('BIN_PRIORITY','FEFO','FIFO','FIXED_BIN','NEAREST_BIN') NOT NULL,
  `warehouse_id` bigint NOT NULL,
  `rid` bigint NOT NULL,
  PRIMARY KEY (`picking_strategy_config_id`)
);


CREATE TABLE `alpide-inventory`.`wms_storage_type` (
  `storage_type_id` bigint NOT NULL AUTO_INCREMENT,
  `created_by_user_id` bigint DEFAULT NULL,
  `date_created` datetime(6) DEFAULT NULL,
  `date_updated` datetime(6) DEFAULT NULL,
  `updated_by_user_id` bigint DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `is_deleted` bit(1) DEFAULT NULL,
  `max_capacity` int DEFAULT NULL,
  `rid` bigint DEFAULT NULL,
  `storage_type_name` varchar(255) DEFAULT NULL,
  `version` bigint NOT NULL,
  `warehouse_master_id` bigint DEFAULT '0',
  `warehouse_name` varchar(45) DEFAULT NULL,
  `created_by_emp_id` int DEFAULT NULL,
  `date_deleted` datetime(6) DEFAULT NULL,
  `date_inactivated` datetime(6) DEFAULT NULL,
  `deleted_by_emp_id` int DEFAULT NULL,
  `inactivated_by_emp_id` int DEFAULT NULL,
  `updated_by_emp_id` int DEFAULT NULL,
  PRIMARY KEY (`storage_type_id`)
);

CREATE TABLE `alpide-inventory`.`wms_storage_bin` (
  `storage_bin_id` bigint NOT NULL AUTO_INCREMENT,
  `version` bigint NOT NULL DEFAULT '0',
  `rid` bigint DEFAULT NULL,
  `storage_bin_name` varchar(255) NOT NULL,
  `storage_bin_code` varchar(255) DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `bin_location` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  `storage_type_id` bigint NOT NULL,
  `date_created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `date_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by_user_id` bigint DEFAULT NULL,
  `updated_by_user_id` bigint DEFAULT NULL,
  `is_barcode_genrated` tinyint(1) DEFAULT '0',
  `created_by_emp_id` int DEFAULT NULL,
  `date_deleted` datetime(6) DEFAULT NULL,
  `date_inactivated` datetime(6) DEFAULT NULL,
  `deleted_by_emp_id` int DEFAULT NULL,
  `inactivated_by_emp_id` int DEFAULT NULL,
  `updated_by_emp_id` int DEFAULT NULL,
  PRIMARY KEY (`storage_bin_id`),
  KEY `storage_type_id` (`storage_type_id`),
  CONSTRAINT `wms_storage_bin_ibfk_1` FOREIGN KEY (`storage_type_id`) REFERENCES `wms_storage_type` (`storage_type_id`) ON DELETE CASCADE
);


-- sales service

CREATE TABLE `alpide-sales`.`wms_packing_slip_master` (
  `packing_slip_master_id` bigint NOT NULL AUTO_INCREMENT,
  `customer_id` bigint DEFAULT NULL,
  `packed_by_emp_id` bigint DEFAULT NULL,
  `packing_slip_number` varchar(30) NOT NULL,
  `packing_status` varchar(30) DEFAULT NULL,
  `rid` bigint NOT NULL,
  `remarks` text,
  `sales_order_master_id` bigint DEFAULT NULL,
  PRIMARY KEY (`packing_slip_master_id`),
  UNIQUE KEY `UK_8cb9u73sfaaeachd3wgcmuj1f` (`packing_slip_number`)
) ;

CREATE TABLE `alpide-sales`.`wms_packing_slip_details` (
  `packing_slip_detail_id` bigint NOT NULL AUTO_INCREMENT,
  `batch_id` bigint DEFAULT NULL,
  `bin_id` bigint DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_split_pick` bit(1) DEFAULT NULL,
  `item_id` bigint DEFAULT NULL,
  `line_status` varchar(255) DEFAULT NULL,
  `package_unit_id` bigint DEFAULT NULL,
  `picking_strategy` varchar(255) DEFAULT NULL,
  `qty_ordered` double DEFAULT NULL,
  `qty_to_pack` double DEFAULT NULL,
  `sales_order_detail_id` bigint DEFAULT NULL,
  `packing_slip_master_id` bigint NOT NULL,
  PRIMARY KEY (`packing_slip_detail_id`),
  KEY `FKgvqqyde3sf57295qqpeic5sog` (`packing_slip_master_id`),
  CONSTRAINT `FKgvqqyde3sf57295qqpeic5sog` FOREIGN KEY (`packing_slip_master_id`) REFERENCES `wms_packing_slip_master` (`packing_slip_master_id`)
) ;

CREATE TABLE `alpide-sales`.`wms_pick_task_master` (
  `pick_task_master_id` int NOT NULL AUTO_INCREMENT,
  `picker_emp_id` bigint DEFAULT NULL,
  `sales_order_id` int DEFAULT NULL,
  `rid` bigint NOT NULL,
  `pick_priority` varchar(30) DEFAULT NULL,
  `pick_status` varchar(30) DEFAULT NULL,
  `remarks` text,
  `customer_id` bigint DEFAULT NULL,
  `pick_task_number` varchar(30) NOT NULL,
  `sales_order_master_id` bigint DEFAULT NULL,
  `pick_by_emp_id` bigint DEFAULT NULL,
  PRIMARY KEY (`pick_task_master_id`),
  UNIQUE KEY `UK_a77ahnkqelndwa94t3siymrwx` (`pick_task_number`)
) ;

CREATE TABLE `alpide-sales`.`wms_pick_task_details` (
  `is_split_pick` bit(1) DEFAULT NULL,
  `pick_task_master_id` int DEFAULT NULL,
  `qty_ordered` double DEFAULT NULL,
  `qty_to_pick` double DEFAULT NULL,
  `bin_id` bigint DEFAULT NULL,
  `item_id` bigint DEFAULT NULL,
  `pick_task_detail_id` bigint NOT NULL AUTO_INCREMENT,
  `sales_order_detail_id` bigint DEFAULT NULL,
  `warehouse_id` bigint DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `line_status` varchar(255) DEFAULT NULL,
  `picking_strategy` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`pick_task_detail_id`),
  KEY `FKmuquwlr5kss0ebuw1nxn82dx4` (`pick_task_master_id`),
  CONSTRAINT `FKmuquwlr5kss0ebuw1nxn82dx4` FOREIGN KEY (`pick_task_master_id`) REFERENCES `wms_pick_task_master` (`pick_task_master_id`)
) ;

