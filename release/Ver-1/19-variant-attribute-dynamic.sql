CREATE TABLE `alpide-inventory`.`inventory_item_variant_attribute_values`
(
    `variant_attribute_value_id` bigint NOT NULL AUTO_INCREMENT,
    `version`                    int          DEFAULT '0',
    `inventory_item_variant_id`  bigint NOT NULL,
    `rid`                        bigint NOT NULL,
    `attribute_id`               bigint       DEFAULT NULL,
    `attribute_name`             varchar(255) DEFAULT NULL,
    `attribute_value`            varchar(500) DEFAULT NULL,
    `display_order`              int          DEFAULT '0',
    `is_active`                  int          DEFAULT '1',
    `date_created`               timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `date_modified`              timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`variant_attribute_value_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

ALTER TABLE `alpide-sales`.`customer_sales_order_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL AFTER `exchange_rate`;
ALTER TABLE `alpide-sales`.`customer_amend_sales_order_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-sales`.`customer_credit_memo_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-sales`.`customer_inquiry_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-sales`.`customer_invoice_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-sales`.`customer_sales_quotation_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-sales`.`customer_so_package_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-sales`.`customer_so_shipment_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

-- Purchage table changes

ALTER TABLE `alpide-purchase`.`asn_order_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`git_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`lc_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`rfq_child_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`rfq_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`supplier_debit_memo_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`supplier_invoice_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`supplier_po_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`supplier_purchase_request_details`
    ADD COLUMN `variant_attributes` TEXT NULL DEFAULT NULL;


ALTER TABLE `alpide-inventory`.`inventory_item`
    ADD COLUMN `is_manufacturing_inventory` int DEFAULT '1';

ALTER TABLE `alpide-inventory`.inventory_item
    ADD COLUMN is_seller_inventory BIGINT DEFAULT 0;