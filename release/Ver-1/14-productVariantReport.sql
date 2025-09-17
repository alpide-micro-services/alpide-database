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