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
