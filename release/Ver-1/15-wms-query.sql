USE `alpide-sales`;

CREATE OR REPLACE
    ALGORITHM = UNDEFINED
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`invoice_sales_report_vw` AS
SELECT
    MIN(`base`.`id`) AS `id`,
    `base`.`rid` AS `rid`,
    `base`.`year` AS `year`,
    `base`.`month` AS `month`,
    `base`.`sku` AS `sku`,
    `base`.`ean` AS `ean`,
    `base`.`brand` AS `brand`,
    COALESCE(`cat_info`.`category`, '') AS `category`,
    MAX(`base`.`description`) AS `description`,
    GROUP_CONCAT(DISTINCT `base`.`invoice_number` ORDER BY `base`.`invoice_number` SEPARATOR ', ') AS `invoice_number`,
    SUM(`base`.`qty`) AS `qty`,
    SUM(`base`.`value`) AS `value`,
    MAX(`base`.`customer_name`) AS `customer_name`,
    MAX(`base`.`location`) AS `location`,
    COALESCE(`base`.`street_address1`, '') AS `street_address1`,
    MAX(`base`.`state`) AS `state`
FROM
    (
        SELECT
            `invdet`.`invoice_details_id` AS `id`,
            `invdet`.`rid` AS `rid`,
            YEAR(`inv`.`invoice_date`) AS `year`,
            MONTHNAME(`inv`.`invoice_date`) AS `month`,
            `itm`.`sku` AS `sku`,
            `itm`.`ean` AS `ean`,
            `br`.`brand_name` AS `brand`,
            `itm`.`description` AS `description`,
            `inv`.`invoice_number` AS `invoice_number`,
            `invdet`.`quantity` AS `qty`,
            (`invdet`.`quantity` * `invdet`.`item_sale_price`) AS `value`,
            `c`.`company_name` AS `customer_name`,
            `loc_info`.`location` AS `location`,
            `loc_info`.`street_address1` AS `street_address1`,
            `loc_info`.`state` AS `state`
        FROM
            (((((`alpide-sales`.`customer_invoice_details` `invdet`
                JOIN `alpide-sales`.`customer_invoice_master` `inv`
                    ON (`invdet`.`invoice_master_id` = `inv`.`invoice_master_id`))
                JOIN `alpide-inventory`.`inventory_item` `itm`
                    ON (`invdet`.`item_id` = `itm`.`item_id`))
                LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br`
                    ON (`itm`.`brand_id` = `br`.`inventory_item_brand_id`))
                LEFT JOIN `alpide-sales`.`customers` `c`
                    ON (`inv`.`customer_id` = `c`.`customer_id`))
                LEFT JOIN (
                    SELECT
                        `bl`.`invoice_master_id` AS `invoice_master_id`,
                        `bl`.`rid` AS `rid`,
                        COALESCE(
                            MAX(CASE WHEN (`bl`.`location_type` = 'ShippingAddress') THEN `bl`.`city_name` END),
                            MAX(`bl`.`city_name`)
                        ) AS `location`,
                        COALESCE(
                            MAX(CASE WHEN (`bl`.`location_type` = 'ShippingAddress') THEN `bl`.`street_address_1` END),
                            MAX(`bl`.`street_address_1`)
                        ) AS `street_address1`,
                        COALESCE(
                            MAX(CASE WHEN (`bl`.`location_type` = 'ShippingAddress') THEN `bl`.`state_name` END),
                            MAX(`bl`.`state_name`)
                        ) AS `state`
                    FROM
                        `alpide-sales`.`bo_location_sales_invoice` `bl`
                    GROUP BY `bl`.`invoice_master_id`, `bl`.`rid`
                ) `loc_info`
                ON ((`loc_info`.`invoice_master_id` = `inv`.`invoice_master_id`)
                    AND (`loc_info`.`rid` = `inv`.`rid`)))
        WHERE
            (LOWER(`inv`.`status`) <> 'void' AND `inv`.`status` IS NOT NULL)
    ) `base`
    LEFT JOIN (
        SELECT
            `i`.`sku` AS `sku`,
            GROUP_CONCAT(DISTINCT `cat`.`category_name` ORDER BY `cat`.`category_name` ASC SEPARATOR '_') AS `category`
        FROM
            ((`alpide-inventory`.`inventory_item` `i`
            LEFT JOIN `alpide-inventory`.`inventory_item_category_ref` `cref`
                ON (`i`.`item_id` = `cref`.`item_id`))
            LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat`
                ON (`cref`.`inventory_item_category_id` = `cat`.`inventory_item_category_id`))
        GROUP BY `i`.`sku`
    ) `cat_info`
    ON (`base`.`sku` = `cat_info`.`sku`)
GROUP BY
    `base`.`rid`,
    `base`.`year`,
    `base`.`month`,
    `base`.`sku`,
    `base`.`ean`,
    `base`.`brand`,
    COALESCE(`base`.`street_address1`, '');


-- Add new columns to inventory_warehouse_master table
ALTER TABLE `alpide-inventory`.inventory_warehouse_master 
ADD COLUMN warehouse_code VARCHAR(50),
ADD COLUMN warehouse_type_id BIGINT,
ADD COLUMN warehouse_type VARCHAR(100),
ADD COLUMN status VARCHAR(20) DEFAULT 'ACTIVE',
ADD COLUMN phone_number VARCHAR(20),
ADD COLUMN email VARCHAR(100),
ADD COLUMN total_area DECIMAL(10,2),
ADD COLUMN warehouse_height DECIMAL(10,2),
ADD COLUMN loading_docks INT,
ADD COLUMN storage_area DECIMAL(10,2),
ADD COLUMN max_weight_capacity DECIMAL(10,2),
ADD COLUMN parking_bays INT,
ADD COLUMN security_level VARCHAR(50),
ADD COLUMN operating_hours_id BIGINT,
ADD COLUMN operating_hours VARCHAR(100),
ADD COLUMN certifications TEXT,
ADD COLUMN description TEXT,
ADD COLUMN warehouse_capabilities JSON;

-- Update existing records with default values if needed
UPDATE inventory_warehouse_master 
SET status = 'ACTIVE' 
WHERE status IS NULL;


-- Remove the columns that are in BaseEntity
ALTER TABLE `alpide-inventory`.wms_storage_bin 
ADD COLUMN max_weight DECIMAL(10,2),
ADD COLUMN length DECIMAL(10,2),
ADD COLUMN width DECIMAL(10,2),
ADD COLUMN height DECIMAL(10,2),
ADD COLUMN warehouse_id BIGINT,
ADD COLUMN warehouse_name VARCHAR(255),
ADD COLUMN zone_id BIGINT,
ADD COLUMN zone_name VARCHAR(255),
ADD COLUMN aisle_id BIGINT,
ADD COLUMN aisle_name VARCHAR(255),
ADD COLUMN level VARCHAR(10),
ADD COLUMN sequence_number VARCHAR(10),
ADD COLUMN bin_type_id BIGINT,
ADD COLUMN bin_type_name VARCHAR(100),
ADD COLUMN bin_category_id BIGINT,
ADD COLUMN bin_category_name VARCHAR(100),
ADD COLUMN picking_priority VARCHAR(50),
ADD COLUMN picking_priority_name VARCHAR(100),
ADD COLUMN accessibility VARCHAR(100),
ADD COLUMN accessibility_name VARCHAR(100),
ADD COLUMN temperature_controlled BOOLEAN DEFAULT FALSE,
ADD COLUMN hazmat_certified BOOLEAN DEFAULT FALSE,
ADD COLUMN allow_mixed_items BOOLEAN DEFAULT FALSE,
ADD COLUMN barcode VARCHAR(255),
ADD COLUMN qr_code VARCHAR(255),
ADD COLUMN rfid_tag VARCHAR(255),
ADD COLUMN current_utilization VARCHAR(10) DEFAULT '0%',
ADD COLUMN status VARCHAR(50),
ADD COLUMN status_name VARCHAR(100);

ALTER TABLE `alpide-inventory`.wms_storage_bin 
ADD COLUMN storage_type_name VARCHAR(255);

ALTER TABLE `alpide-purchase`.supplier_inbound_delivery_details 
ADD column storage_bin_id BIGINT,
ADD COLUMN storage_bin_name VARCHAR(255);

ALTER TABLE `alpide-inventory`.wms_aisle_master 
ADD COLUMN aisle_name VARCHAR(255) DEFAULT null;

ALTER TABLE `alpide-inventory`.inventory_item_variant 
ADD COLUMN qty_receiving Double DEFAULT 0.0;

ALTER TABLE `alpide-inventory`.inventory_item_variant_stock 
ADD COLUMN qty_receiving Double DEFAULT 0.0,
add column receiving_bin_id bigint default null;


CREATE TABLE `alpide-inventory`.inventory_item_varaint_stock_storage_bin_ref (
    id BIGINT NOT NULL AUTO_INCREMENT,
    item_variant_stock_id BIGINT default null,
    quantity DOUBLE default 0.0,
    storage_bin_id BIGINT default null,
    inventory_item_variant_id BIGINT default null,
    item_id BIGINT default null,
    PRIMARY KEY (id)
);

ALTER TABLE `alpide-inventory`.`wms_storage_bin` 
ADD COLUMN `dimension_uom` VARCHAR(255) NULL DEFAULT 'null' AFTER `storage_type_name`;

ALTER TABLE `alpide-inventory`.`wms_storage_bin` 
ADD COLUMN `capacity_uom` VARCHAR(255) NULL AFTER `dimension_uom`;

ALTER TABLE `alpide-inventory`.`wms_batch` 
ADD COLUMN `variant_id` VARCHAR(45) NULL AFTER `deleted_by_user_id`;

ALTER TABLE `alpide-inventory`.`wms_storage_bin` 
ADD COLUMN `is_default` TINYINT(1) NULL DEFAULT '0' AFTER `capacity_uom`;

ALTER TABLE `alpide-inventory`.`wms_packing_unit` 
ADD COLUMN `is_default` TINYINT(1) NULL DEFAULT '0' AFTER `deleted_by_user_id`;


USE `alpide-sales`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`grn_report_vm` AS
    SELECT 
        CONCAT(CONVERT( CONVERT( COALESCE(`base`.`inbound_delivery_number`, 'NA') USING UTF8MB3) USING UTF8MB4),
                '_',
                COALESCE(`base`.`sku`, 'NA')) AS `id`,
        `base`.`rid` AS `rid`, 
        `base`.`year` AS `year`,
        `base`.`month` AS `month`,
        `base`.`sku` AS `sku`,
        `base`.`ean` AS `ean`,
        `base`.`brand` AS `brand`,
        GROUP_CONCAT(DISTINCT IFNULL(`cat`.`category_name`, '')
            ORDER BY `cat`.`category_name` ASC
            SEPARATOR '_') AS `category`,
        `base`.`description` AS `description`,
        `base`.`qty_received` AS `qty_received`,
        `base`.`inbound_delivery_number` AS `inbound_delivery_number`
    FROM
        (((SELECT 
            `sm`.`rid` AS `rid`,
                YEAR(`sm`.`inbound_delivery_date`) AS `year`,
                MONTHNAME(`sm`.`inbound_delivery_date`) AS `month`,
                `iv`.`sku` AS `sku`,
                `itm`.`ean` AS `ean`,
                `br`.`brand_name` AS `brand`,
                `itm`.`description` AS `description`,
                COALESCE(SUM(`sd`.`qty_received`), 0) AS `qty_received`,
                `sm`.`inbound_delivery_number` AS `inbound_delivery_number`
        FROM
            ((((`alpide-purchase`.`supplier_inbound_delivery_master` `sm`
        JOIN `alpide-purchase`.`supplier_inbound_delivery_details` `sd` ON ((`sm`.`inbound_delivery_master_id` = `sd`.`inbound_delivery_master_id`)))
        JOIN `alpide-inventory`.`inventory_item_variant` `iv` ON ((`sd`.`item_variant_id` = `iv`.`inventory_item_variant_id`)))
        JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`iv`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        GROUP BY `sm`.`rid` , YEAR(`sm`.`inbound_delivery_date`) , MONTHNAME(`sm`.`inbound_delivery_date`) , `iv`.`sku` , `itm`.`ean` , `br`.`brand_name` , `itm`.`description` , `sm`.`inbound_delivery_number`) `base`
        LEFT JOIN `alpide-inventory`.`inventory_item_category_ref` `catref` ON ((`base`.`sku` = (SELECT 
                `iv2`.`sku`
            FROM
                `alpide-inventory`.`inventory_item_variant` `iv2`
            WHERE
                (`iv2`.`item_id` = `catref`.`item_id`)
            LIMIT 1))))
        LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cat`.`inventory_item_category_id` = `catref`.`inventory_item_category_id`)))
    GROUP BY `base`.`inbound_delivery_number` , `base`.`sku` , `base`.`rid` , `base`.`year` , `base`.`month` , `base`.`ean` , `base`.`brand` , `base`.`description` , `base`.`qty_received`;

USE `alpide-sales`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`return_sales_report_vw` AS
    SELECT 
        CONCAT(`base`.`aso_number`, '_', `base`.`sku`) AS `id`,
        `base`.`rid` AS `rid`,
        `base`.`year` AS `year`,
        `base`.`month` AS `month`,
        `base`.`sku` AS `sku`, 
        `base`.`ean` AS `ean`,
        `base`.`brand` AS `brand`,
        GROUP_CONCAT(DISTINCT `cat`.`category_name`
            ORDER BY `cat`.`category_name` ASC
            SEPARATOR '_') AS `category`,
        `base`.`description` AS `description`,
        `base`.`sold_qty` AS `sold_qty`,
        `base`.`aso_number` AS `aso_number`
    FROM
        (((SELECT 
            `am`.`rid` AS `rid`,
                YEAR(`am`.`sales_order_date`) AS `year`,
                MONTHNAME(`am`.`sales_order_date`) AS `month`,
                `itm`.`sku` AS `sku`,
                `itm`.`ean` AS `ean`,
                `br`.`brand_name` AS `brand`,
                `itm`.`description` AS `description`,
                SUM(`dt`.`quantity`) AS `sold_qty`,
                `am`.`aso_number` AS `aso_number`,
                `itm`.`item_id` AS `item_id`
        FROM
            (((`alpide-sales`.`customer_amend_sales_order_master` `am`
        JOIN `alpide-sales`.`customer_amend_sales_order_details` `dt` ON ((`am`.`amend_sales_order_master_id` = `dt`.`amend_sales_order_master_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`dt`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        GROUP BY `am`.`rid` , YEAR(`am`.`sales_order_date`) , MONTHNAME(`am`.`sales_order_date`) , `itm`.`sku` , `itm`.`ean` , `br`.`brand_name` , `itm`.`description` , `am`.`aso_number` , `itm`.`item_id`) `base`
        LEFT JOIN `alpide-inventory`.`inventory_item_category_ref` `catref` ON ((`base`.`item_id` = `catref`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cat`.`inventory_item_category_id` = `catref`.`inventory_item_category_id`)))
    GROUP BY `base`.`aso_number` , `base`.`sku` , `base`.`rid` , `base`.`year` , `base`.`month` , `base`.`ean` , `base`.`brand` , `base`.`description` , `base`.`sold_qty`;

USE `alpide-sales`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`return_report_vm` AS
    SELECT 
        CONCAT(CONVERT( `dm`.`debit_memo_number` USING UTF8MB4),
                '_',
                `itm`.`sku`) AS `id`,
        `dm`.`rid` AS `rid`,
        YEAR(`dm`.`debit_memo_date`) AS `year`,
        MONTHNAME(`dm`.`debit_memo_date`) AS `month`,
        `itm`.`sku` AS `sku`, 
        `itm`.`ean` AS `ean`,
        `br`.`brand_name` AS `brand`,
        GROUP_CONCAT(DISTINCT `cat`.`category_name`
            ORDER BY `cat`.`category_name` ASC
            SEPARATOR '_') AS `category`,
        `itm`.`description` AS `description`,
        `dt`.`quantity` AS `qty_received`,
        `dm`.`debit_memo_number` AS `debit_memo_number`
    FROM
        (((((`alpide-purchase`.`supplier_debit_memo_master` `dm`
        JOIN `alpide-purchase`.`supplier_debit_memo_details` `dt` ON (((`dm`.`debit_memo_master_id` = `dt`.`debit_memo_master_id`)
            AND (`dm`.`rid` = `dt`.`rid`))))
        LEFT JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`dt`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category_ref` `catref` ON ((`itm`.`item_id` = `catref`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cat`.`inventory_item_category_id` = `catref`.`inventory_item_category_id`)))
    WHERE
        (`dm`.`is_update_inventory` = 1)
    GROUP BY `dm`.`debit_memo_number` , `itm`.`sku` , `dm`.`rid` , `year` , `month` , `itm`.`ean` , `br`.`brand_name` , `itm`.`description` , `dt`.`quantity`;

USE `alpide-purchase`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `alpide-purchase`.`return_report_vm` AS
    SELECT 
        CONCAT(CONVERT( `dm`.`debit_memo_number` USING UTF8MB4),
                '_',
                `itm`.`sku`) AS `id`,
        `dm`.`rid` AS `rid`,
        YEAR(`dm`.`debit_memo_date`) AS `year`,
        MONTHNAME(`dm`.`debit_memo_date`) AS `month`,
        `itm`.`sku` AS `sku`,
        `itm`.`ean` AS `ean`, 
        `br`.`brand_name` AS `brand`,
        GROUP_CONCAT(DISTINCT `cat`.`category_name`
            ORDER BY `cat`.`category_name` ASC
            SEPARATOR '_') AS `category`,
        `itm`.`description` AS `description`,
        `dt`.`quantity` AS `qty_received`,
        `dm`.`debit_memo_number` AS `debit_memo_number`
    FROM
        (((((`alpide-purchase`.`supplier_debit_memo_master` `dm`
        JOIN `alpide-purchase`.`supplier_debit_memo_details` `dt` ON (((`dm`.`debit_memo_master_id` = `dt`.`debit_memo_master_id`)
            AND (`dm`.`rid` = `dt`.`rid`))))
        LEFT JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`dt`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category_ref` `catref` ON ((`itm`.`item_id` = `catref`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cat`.`inventory_item_category_id` = `catref`.`inventory_item_category_id`)))
    WHERE
        (`dm`.`is_update_inventory` = 1)
    GROUP BY `dm`.`debit_memo_number` , `itm`.`sku` , `dm`.`rid` , `year` , `month` , `itm`.`ean` , `br`.`brand_name` , `itm`.`description` , `dt`.`quantity`;
