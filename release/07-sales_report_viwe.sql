

CREATE
    SQL SECURITY DEFINER
VIEW `alpide-sales`.`v_invoice_sales_summary` AS
    SELECT
        YEAR(`invdet`.`invoice_date`) AS `year`,
        MONTHNAME(`invdet`.`invoice_date`) AS `month`,
        `itm`.`sku` AS `sku`,
        `itm`.`ean` AS `ean`,
        `br`.`brand_name` AS `brand`,
        `cat`.`category_name` AS `category`,
        `itm`.`description` AS `description`,
        SUM(`invdet`.`quantity`) AS `qty`,
        SUM((`invdet`.`quantity` * `invdet`.`item_sale_price`)) AS `value`
    FROM
        (((`alpide-sales`.`customer_invoice_details` `invdet`
        JOIN `alpide-inventory`.`inventory_item` `itm` ON ((`invdet`.`item_id` = `itm`.`item_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` ON ((`itm`.`brand_id` = `br`.`inventory_item_brand_id`)))
        LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` ON ((`itm`.`category_id` = `cat`.`inventory_item_category_id`)))
    GROUP BY YEAR(`invdet`.`invoice_date`) , MONTHNAME(`invdet`.`invoice_date`) , `itm`.`sku` , `itm`.`ean` , `br`.`brand_name` , `cat`.`category_name` , `itm`.`description`

-------

CREATE OR REPLACE VIEW `alpide-sales`.invoice_sales_report_vw AS
SELECT
    invdet.invoice_details_id as id,
    YEAR(`invdet`.`invoice_date`) AS year,
    MONTHNAME(`invdet`.`invoice_date`) AS month,
    `itm`.`sku` AS `sku`,
    `itm`.`ean` AS `ean`,
    `br`.`brand_name` AS `brand`,
    `cat`.`category_name` AS category,
    `itm`.`description` AS description,
    `invdet`.`quantity` AS qty,
    (`invdet`.`quantity` * `invdet`.`item_sale_price`) AS `value`,
    `inv`.`invoice_number` AS `invoice_no`,
    `c`.`company_name` AS `customer_name`,
    `l`.`city_name` AS `location`
FROM `alpide-sales`.`customer_invoice_details` `invdet`
JOIN `alpide-sales`.`customer_invoice_master` `inv`
    ON `invdet`.`invoice_master_id` = `inv`.`invoice_master_id`
JOIN `alpide-inventory`.`inventory_item` `itm` 
    ON `invdet`.`item_id` = `itm`.`item_id`
LEFT JOIN `alpide-inventory`.`inventory_item_brand` `br` 
    ON `itm`.`brand_id` = `br`.`inventory_item_brand_id`
LEFT JOIN `alpide-inventory`.`inventory_item_category` `cat` 
    ON `itm`.`category_id` = `cat`.`inventory_item_category_id`
LEFT JOIN `alpide-sales`.`customers` `c`
    ON `inv`.`customer_id` = `c`.`customer_id`
LEFT JOIN `alpide-sales`.`bo_location` `l`
    ON `c`.`customer_id` = `l`.`customer_id`;


-------

CREATE OR REPLACE VIEW `alpide-sales`.sales_details_report_with_attri_vw AS 
SELECT
    invdet.invoice_details_id as id,
    YEAR(invdet.invoice_date) AS year,
    MONTHNAME(invdet.invoice_date) AS month,
    itm.sku AS sku,
    itm.ean AS ean,
    br.brand_name AS brand,
    cat.category_name AS category,
    itm.description AS description,
    invdet.quantity AS qty,
    (invdet.quantity * invdet.item_sale_price) AS value,
    inv.invoice_number AS invoice_no,
    c.company_name AS customer_name,
    l.city_name AS location,
    invdet.attribute_value1 AS color,
    invdet.attribute_value2 AS size,
    invdet.attribute_value3 AS shape
FROM `alpide-sales`.`customer_invoice_details` invdet
JOIN `alpide-sales`.`customer_invoice_master` inv 
    ON invdet.invoice_master_id = inv.invoice_master_id
JOIN `alpide-inventory`.inventory_item itm 
    ON invdet.item_id = itm.item_id
LEFT JOIN `alpide-inventory`.inventory_item_brand br 
    ON itm.brand_id = br.inventory_item_brand_id
LEFT JOIN `alpide-inventory`.inventory_item_category cat 
    ON itm.category_id = cat.inventory_item_category_id
LEFT JOIN `alpide-sales`.`customers` c 
    ON inv.customer_id = c.customer_id
LEFT JOIN `alpide-sales`.`bo_location` l 
    ON c.customer_id = l.customer_id;


--------

CREATE OR REPLACE VIEW `alpide-sales`.invoice_sales_gender_report_vw AS
SELECT
    invdet.invoice_details_id as id,
    YEAR(invdet.invoice_date) AS year,
    MONTHNAME(invdet.invoice_date) AS month,
    itm.sku AS sku,
    itm.ean AS ean,
    br.brand_name AS brand,
    cat.category_name AS category,
    itm.description AS description,
    invdet.quantity AS qty,
    (invdet.quantity * invdet.item_sale_price) AS value,
    SUM(CASE WHEN cc.gender = 'Female' THEN 1 ELSE 0 END) AS female,
    SUM(CASE WHEN cc.gender = 'Male' THEN 1 ELSE 0 END) AS male
FROM `alpide-sales`.`customer_invoice_details` invdet
JOIN `alpide-sales`.`customer_invoice_master` inv 
    ON invdet.invoice_master_id = inv.invoice_master_id
JOIN `alpide-inventory`.inventory_item itm 
    ON invdet.item_id = itm.item_id
LEFT JOIN `alpide-inventory`.inventory_item_brand br 
    ON itm.brand_id = br.inventory_item_brand_id
LEFT JOIN `alpide-inventory`.inventory_item_category cat 
    ON itm.category_id = cat.inventory_item_category_id
LEFT JOIN `alpide-sales`.customers c 
    ON inv.customer_id = c.customer_id
LEFT JOIN `alpide-sales`.bo_location l 
    ON c.customer_id = l.customer_id
LEFT JOIN `alpide-sales`.`customer_contact` cc
    ON c.customer_id = cc.customer_id
   AND cc.is_primary_contact = 1
GROUP BY 
    YEAR(invdet.invoice_date),
    MONTHNAME(invdet.invoice_date),
    itm.sku, itm.ean, br.brand_name, cat.category_name, itm.description,
    invdet.quantity, (invdet.quantity * invdet.item_sale_price);


---------


CREATE OR REPLACE VIEW `alpide-sales`.shipment_sales_report_vw AS
SELECT
    sd.customer_so_shipment_details_id AS id,
    YEAR(sm.shipment_date) AS year,
    MONTHNAME(sm.shipment_date) AS month,
    sd.sku AS sku,
    itm.ean AS ean,
    br.brand_name AS brand,
    cat.category_name AS category,
    itm.description AS description,
    sd.quantity AS sold_qty,
    sm.shipment_number AS shipment_number
FROM `alpide-sales`.`customer_so_shipment_master` sm
JOIN `alpide-sales`.`customer_so_shipment_details` sd 
    ON sm.shipment_master_id = sd.shipment_master_id
JOIN `alpide-inventory`.inventory_item itm 
    ON sd.item_id = itm.item_id
LEFT JOIN `alpide-inventory`.inventory_item_brand br 
    ON itm.brand_id = br.inventory_item_brand_id
LEFT JOIN `alpide-inventory`.inventory_item_category cat 
    ON itm.category_id = cat.inventory_item_category_id
LEFT JOIN `alpide-sales`.customers c 
    ON sm.customer_id = c.customer_id
GROUP BY 
    sd.customer_so_shipment_details_id,
    YEAR(sm.shipment_date),
    MONTHNAME(sm.shipment_date),
    sd.sku, itm.ean, br.brand_name, cat.category_name, itm.description,
    sd.quantity, sm.shipment_number;