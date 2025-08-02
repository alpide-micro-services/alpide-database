
ALTER TABLE `alpide-sales`.`customer_amend_sales_order_master` ADD COLUMN status VARCHAR(200) DEFAULT NULL;

ALTER TABLE `alpide-sales`.`customer_amend_sales_order_master` ADD COLUMN status_color_inbound_delivery VARCHAR(200) DEFAULT NULL;

ALTER TABLE `alpide-sales`.`customer_amend_sales_order_master` ADD COLUMN status_inbound_delivery VARCHAR(200) DEFAULT NULL;

ALTER TABLE `alpide-purchase`.`audit_trail_purchase_order` ADD COLUMN amend_sales_order_master_id BIGINT DEFAULT NULL;
ALTER TABLE `alpide-sales`.`customer_amend_sales_order_master` ADD COLUMN is_consigment_shipped int DEFAULT 0;
ALTER TABLE `alpide-sales`.`customer_amend_sales_order_master` ADD COLUMN is_consigment_invoiced int DEFAULT 0 ;


ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_details` ADD COLUMN aso_number VARCHAR(200) DEFAULT NULL;
ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_details` ADD COLUMN amend_sales_order_master_id BIGINT DEFAULT NULL;


ALTER TABLE `alpide-sales`.`customer_credit_memo_master` ADD COLUMN aso_number VARCHAR(200) DEFAULT NULL;
ALTER TABLE `alpide-sales`.`customer_credit_memo_master` ADD COLUMN amend_sales_order_master_id BIGINT DEFAULT NULL;


ALTER TABLE `alpide-sales`.`customer_credit_memo_master` ADD COLUMN return_credit int DEFAULT 0;

ALTER TABLE `alpide-sales`.`customer_amend_sales_order_details` ADD COLUMN quantity_credit double DEFAULT 0;

ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_master` ADD COLUMN aso_number VARCHAR(200) DEFAULT NULL;
ALTER TABLE `alpide-purchase`.`supplier_inbound_delivery_master` ADD COLUMN amend_sales_order_master_id BIGINT DEFAULT NULL;



ALTER TABLE `alpide-purchase`.`tx_conversion_po_to_id_ref` ADD COLUMN amend_sales_order_master_id BIGINT DEFAULT NULL;
