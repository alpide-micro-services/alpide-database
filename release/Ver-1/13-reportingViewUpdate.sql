USE `alpide-sales`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`v_invoice_sales_summary` AS
    SELECT 
        `t`.`id` AS `id`,
        `t`.`year` AS `year`,
        `t`.`month` AS `month`,
        `t`.`sku` AS `sku`, 
        `t`.`ean` AS `ean`,
        `t`.`brand` AS `brand`,
        GROUP_CONCAT(DISTINCT `cat`.`category_name`
            ORDER BY `cat`.`category_name` ASC
            SEPARATOR '_') AS `category`,
        `t`.`description` AS `description`,
        `t`.`rid` AS `rid`,
        `t`.`qty` AS `qty`,
        `t`.`value` AS `value`
    FROM
        (((SELECT 
            MIN(`invdet`.`invoice_details_id`) AS `id`,
                YEAR(`invm`.`invoice_date`) AS `year`,
                MONTHNAME(`invm`.`invoice_date`) AS `month`,
                `itm`.`sku` AS `sku`,
                `itm`.`ean` AS `ean`,
                `br`.`brand_name` AS `brand`,
                `itm`.`description` AS `description`,
                `invdet`.`rid` AS `rid`,
                SUM(`invdet`.`quantity`) AS `qty`,
                SUM((`invdet`.`quantity` * `invdet`.`item_sale_price`)) AS `value`
        FROM
            (((`alpide-sales`.`customer_invoice_details` `invdet`
        JOIN `alpide-sales`.`customer_invoice_master` `invm` ON ((`invdet`.`invoice_master_id` = `invm`.`invoice_master_id`)))
        JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`invdet`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        WHERE
            (LOWER(`invm`.`status`) <> 'void')
        GROUP BY YEAR(`invm`.`invoice_date`) , MONTHNAME(`invm`.`invoice_date`) , `itm`.`sku` , `itm`.`ean` , `br`.`brand_name` , `itm`.`description` , `invdet`.`rid`) `t`
        LEFT JOIN `alpide-inventory`.`inventory_item_category_ref` `cref` ON ((`t`.`sku` = (SELECT 
                `i2`.`sku`
            FROM
                `alpide-inventory`.`inventory_item` `i2`
            WHERE
                (`i2`.`item_id` = `cref`.`item_id`)
            LIMIT 1))))
        LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cref`.`inventory_item_category_id` = `cat`.`inventory_item_category_id`)))
    GROUP BY `t`.`id` , `t`.`year` , `t`.`month` , `t`.`sku` , `t`.`ean` , `t`.`brand` , `t`.`description` , `t`.`rid` , `t`.`qty` , `t`.`value`;
    
    
    -- 

    USE `alpide-sales`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`shipment_sales_report_vw` AS
    SELECT 
        CONCAT(`base`.`shipment_number`,
                '_',
                `base`.`sku`) AS `id`,
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
        `base`.`shipment_number` AS `shipment_number`
    FROM
        ((((SELECT 
            `sm`.`rid` AS `rid`,
                YEAR(`sm`.`shipment_date`) AS `year`,
                MONTHNAME(`sm`.`shipment_date`) AS `month`,
                `sd`.`sku` AS `sku`,
                `itm`.`ean` AS `ean`,
                `br`.`brand_name` AS `brand`,
                `itm`.`description` AS `description`,
                SUM(`sd`.`quantity`) AS `sold_qty`,
                `sm`.`shipment_number` AS `shipment_number`
        FROM
            (((`alpide-sales`.`customer_so_shipment_master` `sm`
        JOIN `alpide-sales`.`customer_so_shipment_details` `sd` ON ((`sm`.`shipment_master_id` = `sd`.`shipment_master_id`)))
        JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`sd`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        GROUP BY `sm`.`rid` , YEAR(`sm`.`shipment_date`) , MONTHNAME(`sm`.`shipment_date`) , `sd`.`sku` , `itm`.`ean` , `br`.`brand_name` , `itm`.`description` , `sm`.`shipment_number`) `base`
        LEFT JOIN `alpide-inventory`.`inventory_item` `i` ON ((`i`.`sku` = `base`.`sku`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category_ref` `catref` ON ((`i`.`item_id` = `catref`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cat`.`inventory_item_category_id` = `catref`.`inventory_item_category_id`)))
    GROUP BY `base`.`shipment_number` , `base`.`sku` , `base`.`rid` , `base`.`year` , `base`.`month` , `base`.`ean` , `base`.`brand` , `base`.`description` , `base`.`sold_qty`;


-- 



USE `alpide-sales`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`sales_details_report_with_attri_vw` AS
    SELECT 
        `invdet`.`invoice_details_id` AS `id`,
        `catref`.`rid` AS `rid`,
        YEAR(`invdet`.`invoice_date`) AS `year`,
        MONTHNAME(`invdet`.`invoice_date`) AS `month`,
        `itm`.`sku` AS `sku`,
        `itm`.`ean` AS `ean`,
        `br`.`brand_name` AS `brand`, 
        `cat`.`category_name` AS `category`,
        `itm`.`description` AS `description`,
        `invdet`.`quantity` AS `qty`,
        (`invdet`.`quantity` * `invdet`.`item_sale_price`) AS `value`,
        `inv`.`invoice_number` AS `invoice_no`,
        `c`.`company_name` AS `customer_name`,
        `loc`.`city_name` AS `location`,
        `invdet`.`attribute_value1` AS `color`,
        `invdet`.`attribute_value2` AS `size`,
        `invdet`.`attribute_value3` AS `shape`
    FROM
        (((((((`alpide-sales`.`customer_invoice_details` `invdet`
        JOIN `alpide-sales`.`customer_invoice_master` `inv` ON ((`invdet`.`invoice_master_id` = `inv`.`invoice_master_id`)))
        JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`invdet`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category_ref` `catref` ON ((`itm`.`item_id` = `catref`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cat`.`inventory_item_category_id` = `catref`.`inventory_item_category_id`)))
        LEFT JOIN `alpide-sales`.`customers` `c` ON ((`inv`.`customer_id` = `c`.`customer_id`)))
        LEFT JOIN (SELECT 
            `bl`.`customer_id` AS `customer_id`,
                COALESCE(MAX((CASE
                    WHEN
                        ((`bl`.`location_type` = 'ShippingAddress')
                            AND (`bl`.`is_default` = 1))
                    THEN
                        `bl`.`city_name`
                END)), MAX(`bl`.`city_name`)) AS `city_name`
        FROM
            `alpide-sales`.`bo_location` `bl`
        GROUP BY `bl`.`customer_id`) `loc` ON ((`loc`.`customer_id` = `c`.`customer_id`)));


-- 


USE `alpide-sales`;
CREATE  OR REPLACE 
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
        SUM(`base`.`qty`) AS `qty`,
        SUM(`base`.`value`) AS `value`,
        MAX(`base`.`customer_name`) AS `customer_name`,
        MAX(`base`.`location`) AS `location`,
        COALESCE(`base`.`street_address1`, '') AS `street_address1`,
        MAX(`base`.`state`) AS `state`
    FROM
        ((SELECT 
            `invdet`.`invoice_details_id` AS `id`,
                `invdet`.`rid` AS `rid`,
                YEAR(`inv`.`invoice_date`) AS `year`,
                MONTHNAME(`inv`.`invoice_date`) AS `month`,
                `itm`.`sku` AS `sku`,
                `itm`.`ean` AS `ean`,
                `br`.`brand_name` AS `brand`,
                `itm`.`description` AS `description`,
                `invdet`.`quantity` AS `qty`,
                (`invdet`.`quantity` * `invdet`.`item_sale_price`) AS `value`,
                `c`.`company_name` AS `customer_name`,
                `loc_info`.`location` AS `location`,
                `loc_info`.`street_address1` AS `street_address1`,
                `loc_info`.`state` AS `state`
        FROM
            (((((`alpide-sales`.`customer_invoice_details` `invdet`
        JOIN `alpide-sales`.`customer_invoice_master` `inv` ON ((`invdet`.`invoice_master_id` = `inv`.`invoice_master_id`)))
        JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`invdet`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        LEFT JOIN `alpide-sales`.`customers` `c` ON ((`inv`.`customer_id` = `c`.`customer_id`)))
        LEFT JOIN (SELECT 
            `bl`.`invoice_master_id` AS `invoice_master_id`,
                `bl`.`rid` AS `rid`,
                COALESCE(MAX((CASE
                    WHEN (`bl`.`location_type` = 'ShippingAddress') THEN `bl`.`city_name`
                END)), MAX(`bl`.`city_name`)) AS `location`,
                COALESCE(MAX((CASE
                    WHEN (`bl`.`location_type` = 'ShippingAddress') THEN `bl`.`street_address_1`
                END)), MAX(`bl`.`street_address_1`)) AS `street_address1`,
                COALESCE(MAX((CASE
                    WHEN (`bl`.`location_type` = 'ShippingAddress') THEN `bl`.`state_name`
                END)), MAX(`bl`.`state_name`)) AS `state`
        FROM
            `alpide-sales`.`bo_location_sales_invoice` `bl`
        GROUP BY `bl`.`invoice_master_id` , `bl`.`rid`) `loc_info` ON (((`loc_info`.`invoice_master_id` = `inv`.`invoice_master_id`)
            AND (`loc_info`.`rid` = `inv`.`rid`))))
        WHERE
            ((LOWER(`inv`.`status`) <> 'void')
                AND (`inv`.`status` IS NOT NULL))) `base`
        LEFT JOIN (SELECT 
            `i`.`sku` AS `sku`,
                GROUP_CONCAT(DISTINCT `cat`.`category_name`
                    ORDER BY `cat`.`category_name` ASC
                    SEPARATOR '_') AS `category`
        FROM
            ((`alpide-inventory`.`inventory_item` `i`
        LEFT JOIN `alpide-inventory`.`inventory_item_category_ref` `cref` ON ((`i`.`item_id` = `cref`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cref`.`inventory_item_category_id` = `cat`.`inventory_item_category_id`)))
        GROUP BY `i`.`sku`) `cat_info` ON ((`base`.`sku` = `cat_info`.`sku`)))
    GROUP BY `base`.`rid` , `base`.`year` , `base`.`month` , `base`.`sku` , `base`.`ean` , `base`.`brand` , COALESCE(`base`.`street_address1`, '');


-- 


USE `alpide-sales`;
CREATE  OR REPLACE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`invoice_sales_gender_report_vw` AS
    SELECT 
        `t`.`id` AS `id`,
        `t`.`year` AS `year`,
        `t`.`month` AS `month`, 
        `t`.`sku` AS `sku`,
        `t`.`ean` AS `ean`,
        `t`.`brand` AS `brand`,
        GROUP_CONCAT(DISTINCT `cat`.`category_name`
            ORDER BY `cat`.`category_name` ASC
            SEPARATOR '_') AS `category`,
        `t`.`description` AS `description`,
        `t`.`rid` AS `rid`,
        `t`.`qty` AS `qty`,
        `t`.`value` AS `value`,
        `t`.`female` AS `female`,
        `t`.`male` AS `male`
    FROM
        ((((SELECT 
            MIN(`invdet`.`invoice_details_id`) AS `id`,
                YEAR(`inv`.`invoice_date`) AS `year`,
                MONTHNAME(`inv`.`invoice_date`) AS `month`,
                `itm`.`sku` AS `sku`,
                `itm`.`ean` AS `ean`,
                `br`.`brand_name` AS `brand`,
                `itm`.`short_description` AS `description`,
                `invdet`.`rid` AS `rid`,
                SUM(`invdet`.`quantity`) AS `qty`,
                SUM((`invdet`.`quantity` * `invdet`.`item_sale_price`)) AS `value`,
                COUNT(DISTINCT (CASE
                    WHEN (`cc`.`gender` = 'Female') THEN `inv`.`invoice_master_id`
                END)) AS `female`,
                COUNT(DISTINCT (CASE
                    WHEN (`cc`.`gender` = 'Male') THEN `inv`.`invoice_master_id`
                END)) AS `male`
        FROM
            (((((`alpide-sales`.`customer_invoice_details` `invdet`
        JOIN `alpide-sales`.`customer_invoice_master` `inv` ON ((`invdet`.`invoice_master_id` = `inv`.`invoice_master_id`)))
        JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`invdet`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        LEFT JOIN `alpide-sales`.`customers` `c` ON ((`inv`.`customer_id` = `c`.`customer_id`)))
        LEFT JOIN `alpide-sales`.`customer_contact` `cc` ON (((`c`.`customer_id` = `cc`.`customer_id`)
            AND (`cc`.`is_primary_contact` = 1))))
        WHERE
            (LOWER(`inv`.`status`) <> 'void')
        GROUP BY YEAR(`inv`.`invoice_date`) , MONTHNAME(`inv`.`invoice_date`) , `itm`.`sku` , `itm`.`ean` , `br`.`brand_name` , `itm`.`short_description` , `invdet`.`rid`) `t`
        LEFT JOIN `alpide-inventory`.`inventory_item` `i` ON ((`i`.`sku` = `t`.`sku`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category_ref` `cref` ON ((`i`.`item_id` = `cref`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`cref`.`inventory_item_category_id` = `cat`.`inventory_item_category_id`)))
    GROUP BY `t`.`id` , `t`.`year` , `t`.`month` , `t`.`sku` , `t`.`ean` , `t`.`brand` , `t`.`description` , `t`.`rid` , `t`.`qty` , `t`.`value` , `t`.`female` , `t`.`male`;
