USE `alpide-sales`;
CREATE OR REPLACE
    ALGORITHM = UNDEFINED
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`sales_details_report_with_attri_vw` AS
SELECT
    MIN(invdet.invoice_details_id) AS id,   
    invdet.rid AS rid,
    YEAR(inv.invoice_date) AS year,
    MONTHNAME(inv.invoice_date) AS month,
    itm.sku AS sku,
    itm.ean AS ean,
    COALESCE(br.brand_name, '') AS brand,
    COALESCE(cat.category_name, '') AS category,
    COALESCE(itm.description, '') AS description,
    SUM(invdet.quantity) AS qty,
    SUM(invdet.quantity * invdet.item_sale_price) AS value,
    MAX(inv.invoice_number) AS invoice_no,
    COALESCE(c.company_name, '') AS customer_name,
    COALESCE(loc_info.location, '') AS location,
    COALESCE(loc_info.street_address1, '') AS street_address1,
    COALESCE(loc_info.state, '') AS state,
    COALESCE(invdet.attribute_name1, v.attribute_name1, '') AS attribute_name1,
    COALESCE(invdet.attribute_name2, v.attribute_name2, '') AS attribute_name2,
    COALESCE(invdet.attribute_name3, v.attribute_name3, '') AS attribute_name3,
    COALESCE(invdet.attribute_value1, '') AS attribute_value1,
    COALESCE(invdet.attribute_value2, '') AS attribute_value2,
    COALESCE(invdet.attribute_value3, '') AS attribute_value3
FROM `alpide-sales`.customer_invoice_details invdet
JOIN `alpide-sales`.customer_invoice_master inv
  ON invdet.invoice_master_id = inv.invoice_master_id
JOIN `alpide-inventory`.inventory_item itm
  ON invdet.item_id = itm.item_id
LEFT JOIN `alpide-inventory`.inventory_item_brand br
  ON itm.brand_id = br.inventory_item_brand_id
LEFT JOIN `alpide-inventory`.inventory_item_category_ref catref
  ON itm.item_id = catref.item_id
LEFT JOIN `alpide-inventory`.inventory_item_category cat
  ON cat.inventory_item_category_id = catref.inventory_item_category_id
LEFT JOIN `alpide-sales`.customers c
  ON inv.customer_id = c.customer_id
LEFT JOIN (
    SELECT
        bl.customer_id,
        COALESCE(
            MAX(CASE WHEN bl.location_type = 'ShippingAddress' AND bl.is_default = 1 THEN bl.city_name END),
            MAX(bl.city_name)
        ) AS location,
        COALESCE(
            MAX(CASE WHEN bl.location_type = 'ShippingAddress' AND bl.is_default = 1 THEN bl.street_address_1 END),
            MAX(bl.street_address_1)
        ) AS street_address1,
        COALESCE(
            MAX(CASE WHEN bl.location_type = 'ShippingAddress' AND bl.is_default = 1 THEN bl.state_name END),
            MAX(bl.state_name)
        ) AS state
    FROM `alpide-sales`.bo_location bl
    GROUP BY bl.customer_id
) loc_info
  ON loc_info.customer_id = c.customer_id
LEFT JOIN `alpide-inventory`.inventory_item_variant v
  ON v.item_id = invdet.item_id AND v.rid = invdet.rid
WHERE inv.status IS NOT NULL
  AND LOWER(inv.status) <> 'void'      
GROUP BY invdet.rid, YEAR(inv.invoice_date), MONTHNAME(inv.invoice_date), itm.sku, itm.ean, v.attribute_name1, v.attribute_name2, v.attribute_name3, invdet.attribute_name1, invdet.attribute_name2, invdet.attribute_name3;



ALTER TABLE `alpide-purchase`.`supplier_po_master` ADD COLUMN is_consignment_order int DEFAULT 0;


USE `alpide-purchase`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
   
    SQL SECURITY DEFINER
VIEW `alpide-purchase`.`grn_report_vm` AS
    SELECT 
        CONCAT(CONVERT( COALESCE(`base`.`inbound_delivery_number`, 'NA') USING UTF8MB3),
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
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`sales_vs_purchase_report_vw` AS
    SELECT 
        CONCAT(`c`.`rid`,
                '_', 
                `c`.`year`,
                '_',
                `c`.`month_num`,
                '_',
                COALESCE(`c`.`sku`, 'UNKNOWN')) AS `id`,
        `c`.`rid` AS `rid`,
        `c`.`year` AS `year`,
        `c`.`month` AS `month`,
        `c`.`month_num` AS `month_num`,
        `c`.`sku` AS `sku`,
        `c`.`ean` AS `ean`,
        `c`.`brand` AS `brand`,
        `c`.`category` AS `category`,
        `c`.`description` AS `description`,
        SUM(`c`.`purchase_qty`) AS `purchase_qty`,
        SUM(`c`.`sold_qty`) AS `sold_qty`,
        (SUM(`c`.`purchase_qty`) - SUM(`c`.`sold_qty`)) AS `remaining_qty`
    FROM
        (SELECT 
            `supdet`.`rid` AS `rid`,
                YEAR(`supm`.`invoice_date`) AS `year`,
                MONTHNAME(`supm`.`invoice_date`) AS `month`,
                MONTH(`supm`.`invoice_date`) AS `month_num`,
                `itm`.`sku` AS `sku`,
                `itm`.`ean` AS `ean`,
                `br`.`brand_name` AS `brand`,
                COALESCE(`cat_info`.`category`, '') AS `category`,
                `itm`.`description` AS `description`,
                SUM(`supdet`.`quantity`) AS `purchase_qty`,
                0 AS `sold_qty`
        FROM
            ((((`alpide-purchase`.`supplier_invoice_details` `supdet`
        JOIN `alpide-purchase`.`supplier_invoice_master` `supm` ON (((`supdet`.`invoice_master_id` = `supm`.`invoice_master_id`)
            AND (`supdet`.`rid` = `supm`.`rid`))))
        JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`supdet`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        LEFT JOIN (SELECT 
            `cref`.`item_id` AS `item_id`,
                GROUP_CONCAT(DISTINCT `cat`.`category_name`
                    ORDER BY `cat`.`category_name` ASC
                    SEPARATOR '_') AS `category`
        FROM
            (`alpide-inventory`.`inventory_item_category_ref` `cref`
        JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cref`.`inventory_item_category_id` = `cat`.`inventory_item_category_id`)))
        GROUP BY `cref`.`item_id`) `cat_info` ON ((`itm`.`item_id` = `cat_info`.`item_id`)))
        WHERE
            (LOWER(`supm`.`status`) <> 'void')
        GROUP BY `supdet`.`rid` , `year` , `month` , `month_num` , `itm`.`sku` , `itm`.`ean` , `br`.`brand_name` , `itm`.`description` , `cat_info`.`category` UNION ALL SELECT 
            `invdet`.`rid` AS `rid`,
                YEAR(`invm`.`invoice_date`) AS `year`,
                MONTHNAME(`invm`.`invoice_date`) AS `month`,
                MONTH(`invm`.`invoice_date`) AS `month_num`,
                `itm`.`sku` AS `sku`,
                `itm`.`ean` AS `ean`,
                `br`.`brand_name` AS `brand`,
                COALESCE(`cat_info`.`category`, '') AS `category`,
                `itm`.`description` AS `description`,
                0 AS `purchase_qty`,
                SUM(`invdet`.`quantity`) AS `sold_qty`
        FROM
            ((((`alpide-sales`.`customer_invoice_details` `invdet`
        JOIN `alpide-sales`.`customer_invoice_master` `invm` ON (((`invdet`.`invoice_master_id` = `invm`.`invoice_master_id`)
            AND (`invdet`.`rid` = `invm`.`rid`))))
        JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`invdet`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        LEFT JOIN (SELECT 
            `cref`.`item_id` AS `item_id`,
                GROUP_CONCAT(DISTINCT `cat`.`category_name`
                    ORDER BY `cat`.`category_name` ASC
                    SEPARATOR '_') AS `category`
        FROM
            (`alpide-inventory`.`inventory_item_category_ref` `cref`
        JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cref`.`inventory_item_category_id` = `cat`.`inventory_item_category_id`)))
        GROUP BY `cref`.`item_id`) `cat_info` ON ((`itm`.`item_id` = `cat_info`.`item_id`)))
        WHERE
            (LOWER(`invm`.`status`) <> 'void')
        GROUP BY `invdet`.`rid` , `year` , `month` , `month_num` , `itm`.`sku` , `itm`.`ean` , `br`.`brand_name` , `itm`.`description` , `cat_info`.`category`) `c`
    GROUP BY `c`.`rid` , `c`.`year` , `c`.`month` , `c`.`month_num` , `c`.`sku` , `c`.`ean` , `c`.`brand` , `c`.`category` , `c`.`description`
    ORDER BY `c`.`rid` , `c`.`year` , `c`.`month_num` , `c`.`sku`;
