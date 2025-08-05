
CREATE TABLE `alpide-purchase`.`master_po_line_item_closure_reasons` (
    closure_reason_master_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    version INT NOT NULL,
    rid BIGINT,
    reason_code VARCHAR(100) NOT NULL,
    status BOOLEAN NOT NULL,
    reason_name VARCHAR(255) NOT NULL,
    impact_type VARCHAR(100) NOT NULL,
    description TEXT,
    created_by_user_id BIGINT,
    updated_by_user_id BIGINT,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE `alpide-sales`.`master_item_condition` (
    item_condition_master_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    version INT NOT NULL,
    rid BIGINT,
    condition_name VARCHAR(255) NOT NULL,
    condition_code VARCHAR(100) NOT NULL,
    status BOOLEAN NOT NULL,
    value_percentage INT NOT NULL CHECK (value_percentage >= 0 AND value_percentage <= 100),
    description TEXT,
    badge_color VARCHAR(50),
    sort_order INT,
    resale_eligible VARCHAR(50),
    inspection_required VARCHAR(50),
    created_by_user_id BIGINT,
    updated_by_user_id BIGINT,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);