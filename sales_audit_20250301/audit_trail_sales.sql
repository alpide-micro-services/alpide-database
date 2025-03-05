CREATE TABLE `alpide-sales`.audit_trail_sales (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(255) NOT NULL,
    entity_id VARCHAR(100) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    changed_column VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    event_timestamp DATETIME NOT NULL,
    updated_by VARCHAR(100),
    created_by VARCHAR(100)
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


