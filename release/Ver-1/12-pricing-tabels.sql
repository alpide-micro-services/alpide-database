CREATE TABLE `alpide-inventory`.`inventory_item_variant_prize` (
    variant_prize_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    inventory_item_variant_id BIGINT DEFAULT null,
    rid BIGINT DEFAULT null,
    currency_code VARCHAR(10) DEFAULT 'USD',
    purchased_price DOUBLE DEFAULT 0,
    wholesale_price DOUBLE DEFAULT 0,
    max_retail_price DOUBLE DEFAULT 0,
    retail_price DOUBLE DEFAULT 0,
    b2b_price DOUBLE DEFAULT 0,
    online_prize DOUBLE DEFAULT 0
);

CREATE TABLE `alpide-inventory`.`supplier_inventory_items` (
    supplier_inventory_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    inventory_item_variant_id BIGINT default null,
    item_id BIGINT default null,
    rid BIGINT default null,
    currency_code VARCHAR(10) NOT NULL,
    purchased_price DOUBLE DEFAULT 0,
    item_name VARCHAR(1000) default null,
    supplier_id BIGINT default null,
    turn_around_time DOUBLE DEFAULT 0
);

ALTER TABLE `alpide-inventory`.`inventory_item_variant` ADD COLUMN b2b_price  Double DEFAULT 0.0;

ALTER TABLE `alpide-inventory`.`inventory_item_variant` ADD COLUMN online_prize  Double DEFAULT 0.0;

ALTER TABLE `alpide-inventory`.`inventory_item` ADD COLUMN sells_online  int DEFAULT 1;

ALTER TABLE `alpide-inventory`.`inventory_item` ADD COLUMN is_fragile  int DEFAULT 0;

ALTER TABLE `alpide-inventory`.`inventory_item` ADD COLUMN is_hazardous_material  int DEFAULT 0;

ALTER TABLE `alpide-inventory`.`inventory_item` ADD COLUMN country_of_origin  varchar(255) DEFAULT null;


CREATE TABLE `alpide-purchase`.`supplier_exchande_rate` (
    supplier_exchande_rate_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    supplier_id BIGINT  DEFAULT null,
    rid BIGINT  DEFAULT null,
    exchange_rate DOUBLE  DEFAULT 0.0,
    currency_code VARCHAR(10)  DEFAULT null
);