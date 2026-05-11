USE `alpide-sales`;

CREATE OR REPLACE
    ALGORITHM = UNDEFINED
    
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`sales_vs_purchase_supplier_report_vws_new` AS
    SELECT
        -- NULL-safe composite ID
        CONCAT(
            COALESCE(`c`.`rid`, 0),         '_',
            COALESCE(`c`.`year`, 0),        '_',
            COALESCE(`c`.`month_num`, 0),   '_',
            COALESCE(`c`.`sku`, 'UNKNOWN')
        )                                           AS `id`,

        `c`.`rid`                                   AS `rid`,
        `c`.`year`                                  AS `year`,
        `c`.`month`                                 AS `month`,
        `c`.`month_num`                             AS `month_num`,
        `c`.`sku`                                   AS `sku`,
        `c`.`ean`                                   AS `ean`,
        `c`.`product_name`                          AS `product_name`,
        `c`.`brand`                                 AS `brand`,
        `c`.`category`                              AS `category`,
        `c`.`description`                           AS `description`,

        -- "supplier_id:supplier_name, ..."
        GROUP_CONCAT(
            DISTINCT CONCAT(
                COALESCE(`c`.`supplier_id`, 0), ':',
                COALESCE(`c`.`supplier_name`, 'N/A')
            )
            ORDER BY `c`.`supplier_name` ASC
            SEPARATOR ', '
        )                                           AS `supplier_names`,

        -- "purchase_invoice_master_id:invoice_number, ..."
        GROUP_CONCAT(
            DISTINCT CONCAT(
                COALESCE(`c`.`purchase_invoice_master_id`, 0), ':',
                COALESCE(`c`.`purchase_invoice_number`, 'N/A')
            )
            ORDER BY `c`.`purchase_invoice_number` ASC
            SEPARATOR ', '
        )                                           AS `purchase_invoice_numbers`,

        -- "sales_invoice_master_id:invoice_number, ..."
        GROUP_CONCAT(
            DISTINCT CONCAT(
                COALESCE(`c`.`sales_invoice_master_id`, 0), ':',
                COALESCE(`c`.`sales_invoice_number`, 'N/A')
            )
            ORDER BY `c`.`sales_invoice_number` ASC
            SEPARATOR ', '
        )                                           AS `sales_invoice_numbers`,

        -- "customer_id:customer_name, ..."
        GROUP_CONCAT(
            DISTINCT CONCAT(
                COALESCE(`c`.`customer_id`, 0), ':',
                COALESCE(`c`.`customer_name`, 'N/A')
            )
            ORDER BY `c`.`customer_name` ASC
            SEPARATOR ', '
        )                                           AS `customer_names`,

        SUM(`c`.`purchase_qty`)                     AS `purchase_qty`,
        SUM(`c`.`sold_qty`)                         AS `sold_qty`,
        (SUM(`c`.`purchase_qty`) - SUM(`c`.`sold_qty`)) AS `remaining_qty`,
        SUM(`c`.`purchase_value`)                   AS `total_purchase_value`,
        SUM(`c`.`sales_value`)                      AS `total_sales_value`,
        SUM(`c`.`purchase_tax_value`)               AS `total_purchase_tax_value`,
        SUM(`c`.`purchase_discount_value`)          AS `total_purchase_discount_value`,
        SUM(`c`.`sales_tax_value`)                  AS `total_sales_tax_value`,
        SUM(`c`.`sales_discount_value`)             AS `total_sales_discount_value`

    FROM (

        -- =============================================
        -- PURCHASE SIDE
        -- =============================================
        SELECT
            `supdet`.`rid`                                                              AS `rid`,
            `supm`.`supplier_id`                                                        AS `supplier_id`,
            COALESCE(`supm`.`supplier_name`, `sup`.`supplier_company_name`, 'N/A')      AS `supplier_name`,
            `supm`.`invoice_master_id`                                                  AS `purchase_invoice_master_id`,
            NULL                                                                        AS `sales_invoice_master_id`,
            NULL                                                                        AS `customer_id`,
            YEAR(`supm`.`invoice_date`)                                                 AS `year`,
            MONTHNAME(`supm`.`invoice_date`)                                            AS `month`,
            MONTH(`supm`.`invoice_date`)                                                AS `month_num`,
            `itm`.`sku`                                                                 AS `sku`,
            `itm`.`ean`                                                                 AS `ean`,
            COALESCE(`itm`.`item_name`, `itm`.`description`, 'N/A')                    AS `product_name`,
            `br`.`brand_name`                                                           AS `brand`,
            COALESCE(`cat_info`.`category`, '')                                         AS `category`,
            `itm`.`description`                                                         AS `description`,
            `supm`.`invoice_number`                                                     AS `purchase_invoice_number`,
            NULL                                                                        AS `sales_invoice_number`,
            NULL                                                                        AS `customer_name`,
            SUM(`supdet`.`quantity`)                                                    AS `purchase_qty`,
            0                                                                           AS `sold_qty`,
            SUM(`supdet`.`quantity` * `supdet`.`item_purchase_price`)                   AS `purchase_value`,
            0                                                                           AS `sales_value`,
            COALESCE(SUM(`supcoa_agg`.`total_tax`), 0)                                  AS `purchase_tax_value`,
            COALESCE(SUM(`supcoa_agg`.`total_discount`), 0)                             AS `purchase_discount_value`,
            0                                                                           AS `sales_tax_value`,
            0                                                                           AS `sales_discount_value`

        FROM `alpide-purchase`.`supplier_invoice_details` `supdet`

        JOIN `alpide-purchase`.`supplier_invoice_master` `supm`
            ON `supdet`.`invoice_master_id` = `supm`.`invoice_master_id`
            AND `supdet`.`rid` = `supm`.`rid`

        LEFT JOIN `alpide-purchase`.`suppliers` `sup`
            ON `supm`.`supplier_id` = `sup`.`supplier_id`
            AND `supm`.`rid` = `sup`.`rid`

        JOIN `alpide-inventory`.`inventory_item` `itm`
            ON `supdet`.`item_id` = `itm`.`item_id`

        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br`
            ON `itm`.`brand_id` = `br`.`inventory_item_brand_id`

        LEFT JOIN (
            SELECT
                `cref`.`item_id`,
                GROUP_CONCAT(
                    DISTINCT `cat`.`category_name`
                    ORDER BY `cat`.`category_name` ASC
                    SEPARATOR '_'
                ) AS `category`
            FROM `alpide-inventory`.`inventory_item_category_ref` `cref`
            JOIN `alpide-inventory`.`inventory_item_category` `cat`
                ON `cref`.`inventory_item_category_id` = `cat`.`inventory_item_category_id`
            GROUP BY `cref`.`item_id`
        ) `cat_info` ON `itm`.`item_id` = `cat_info`.`item_id`

        LEFT JOIN (
            SELECT
                `invoice_details_id`,
                `rid`,
                SUM(CASE WHEN `tx_type` = 'tax'      THEN `amount` ELSE 0 END) AS `total_tax`,
                SUM(CASE WHEN `tx_type` = 'discount' THEN `amount` ELSE 0 END) AS `total_discount`
            FROM `alpide-purchase`.`supplier_coa_tx_invoice`
            GROUP BY `invoice_details_id`, `rid`
        ) `supcoa_agg`
            ON `supdet`.`invoice_details_id` = `supcoa_agg`.`invoice_details_id`
            AND `supdet`.`rid` = `supcoa_agg`.`rid`

        WHERE LOWER(`supm`.`status`) <> 'void'

        GROUP BY
            `supdet`.`rid`,
            `supm`.`supplier_id`,
            `supm`.`supplier_name`,
            `sup`.`supplier_company_name`,
            `supm`.`invoice_master_id`,
            `supm`.`invoice_number`,
            `year`, `month`, `month_num`,
            `itm`.`sku`, `itm`.`ean`,
            `itm`.`item_name`, `itm`.`description`,
            `br`.`brand_name`,
            `cat_info`.`category`

        UNION ALL

        -- =============================================
        -- SALES SIDE
        -- =============================================
        SELECT
            `invdet`.`rid`                                                              AS `rid`,
            NULL                                                                        AS `supplier_id`,
            NULL                                                                        AS `supplier_name`,
            NULL                                                                        AS `purchase_invoice_master_id`,
            `invm`.`invoice_master_id`                                                  AS `sales_invoice_master_id`,
            `invm`.`customer_id`                                                        AS `customer_id`,
            YEAR(`invm`.`invoice_date`)                                                 AS `year`,
            MONTHNAME(`invm`.`invoice_date`)                                            AS `month`,
            MONTH(`invm`.`invoice_date`)                                                AS `month_num`,
            `itm`.`sku`                                                                 AS `sku`,
            `itm`.`ean`                                                                 AS `ean`,
            COALESCE(`itm`.`item_name`, `itm`.`description`, 'N/A')                    AS `product_name`,
            `br`.`brand_name`                                                           AS `brand`,
            COALESCE(`cat_info`.`category`, '')                                         AS `category`,
            `itm`.`description`                                                         AS `description`,
            NULL                                                                        AS `purchase_invoice_number`,
            `invm`.`invoice_number`                                                     AS `sales_invoice_number`,
            `invm`.`customer_name`                                                      AS `customer_name`,
            0                                                                           AS `purchase_qty`,
            SUM(`invdet`.`quantity`)                                                    AS `sold_qty`,
            0                                                                           AS `purchase_value`,
            SUM(`invdet`.`quantity` * `invdet`.`item_sale_price`)                       AS `sales_value`,
            0                                                                           AS `purchase_tax_value`,
            0                                                                           AS `purchase_discount_value`,
            COALESCE(SUM(`custcoa_agg`.`total_tax`), 0)                                 AS `sales_tax_value`,
            COALESCE(SUM(`custcoa_agg`.`total_discount`), 0)                            AS `sales_discount_value`

        FROM `alpide-sales`.`customer_invoice_details` `invdet`

        JOIN `alpide-sales`.`customer_invoice_master` `invm`
            ON `invdet`.`invoice_master_id` = `invm`.`invoice_master_id`
            AND `invdet`.`rid` = `invm`.`rid`

        JOIN `alpide-inventory`.`inventory_item` `itm`
            ON `invdet`.`item_id` = `itm`.`item_id`

        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br`
            ON `itm`.`brand_id` = `br`.`inventory_item_brand_id`

        LEFT JOIN (
            SELECT
                `cref`.`item_id`,
                GROUP_CONCAT(
                    DISTINCT `cat`.`category_name`
                    ORDER BY `cat`.`category_name` ASC
                    SEPARATOR '_'
                ) AS `category`
            FROM `alpide-inventory`.`inventory_item_category_ref` `cref`
            JOIN `alpide-inventory`.`inventory_item_category` `cat`
                ON `cref`.`inventory_item_category_id` = `cat`.`inventory_item_category_id`
            GROUP BY `cref`.`item_id`
        ) `cat_info` ON `itm`.`item_id` = `cat_info`.`item_id`

        LEFT JOIN (
            SELECT
                `invoice_details_id`,
                `rid`,
                SUM(CASE WHEN `tx_type` = 'tax'      THEN `amount` ELSE 0 END) AS `total_tax`,
                SUM(CASE WHEN `tx_type` = 'discount' THEN `amount` ELSE 0 END) AS `total_discount`
            FROM `alpide-sales`.`customer_coa_tx_invoice`
            GROUP BY `invoice_details_id`, `rid`
        ) `custcoa_agg`
            ON `invdet`.`invoice_details_id` = `custcoa_agg`.`invoice_details_id`
            AND `invdet`.`rid` = `custcoa_agg`.`rid`

        WHERE LOWER(`invm`.`status`) <> 'void'

        GROUP BY
            `invdet`.`rid`,
            `invm`.`invoice_master_id`,
            `invm`.`customer_id`,
            `invm`.`invoice_number`,
            `invm`.`customer_name`,
            `year`, `month`, `month_num`,
            `itm`.`sku`, `itm`.`ean`,
            `itm`.`item_name`, `itm`.`description`,
            `br`.`brand_name`,
            `cat_info`.`category`

    ) `c`

    -- One row per rid + sku + year + month
    GROUP BY
        `c`.`rid`,
        `c`.`year`,
        `c`.`month`,
        `c`.`month_num`,
        `c`.`sku`,
        `c`.`ean`,
        `c`.`product_name`,
        `c`.`brand`,
        `c`.`category`,
        `c`.`description`

    ORDER BY
        `c`.`rid`,
        `c`.`year`,
        `c`.`month_num`,
        `c`.`sku`;