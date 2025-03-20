
CREATE TABLE `alpide-sales`.audit_trail_sales (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    version_number INT NOT NULL,
    entity_name VARCHAR(255) NOT NULL,
    entity_id BIGINT NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    rid BIGINT,
    customer_id BIGINT,
    transaction_data LONGTEXT,
    event_timestamp DATETIME(6) NOT NULL,
    updated_by BIGINT,
    created_by BIGINT
);


CREATE TABLE `alpide-purchase`.audit_trail_purchase (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    version_number INT NOT NULL,
    entity_name VARCHAR(255) NOT NULL,
    entity_id BIGINT NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    rid BIGINT,
    customer_id BIGINT,
    supplier_id BIGINT,
    transaction_data LONGTEXT,
    event_timestamp DATETIME(6) NOT NULL,
    updated_by BIGINT,
    created_by BIGINT
);

CREATE TABLE `alpide-inventory`.audit_trail_inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    version_number INT NOT NULL,
    entity_name VARCHAR(255) NOT NULL,
    entity_id BIGINT NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    rid BIGINT,
    warehouse_master_id BIGINT,
    transaction_data LONGTEXT,
    event_timestamp DATETIME(6) NOT NULL,
    updated_by BIGINT,
    created_by BIGINT
);


-- `alpide-sales`.alpide_sequence definition

CREATE TABLE `alpide_sequence` (
  `version` int NOT NULL,
  `alpide_sequence_id` bigint NOT NULL AUTO_INCREMENT,
  `rid` bigint DEFAULT NULL,
  `tx_id` bigint DEFAULT NULL,
  `tx_name` varchar(255) DEFAULT NULL,
  `tx_name_prefix` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`alpide_sequence_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


