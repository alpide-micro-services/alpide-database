USE `alpide-crm`;

-- Territory Master Table
CREATE TABLE territory_master (
    territory_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    territory_name VARCHAR(255) NOT NULL,
    description TEXT,
    rid INT,
    in_built INT DEFAULT 0,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    user_created VARCHAR(100),
    user_updated VARCHAR(100),
    deleted_by VARCHAR(100),
    is_deleted INT DEFAULT 0,
    INDEX idx_territory_rid (rid),
    INDEX idx_territory_deleted (is_deleted)
);

-- Competitor Master Table
CREATE TABLE competitor_master (
    competitor_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    competitor_name VARCHAR(255) NOT NULL,
    description TEXT,
    rid INT,
    in_built INT DEFAULT 0,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    user_created VARCHAR(100),
    user_updated VARCHAR(100),
    deleted_by VARCHAR(100),
    is_deleted INT DEFAULT 0,
    INDEX idx_competitor_rid (rid),
    INDEX idx_competitor_deleted (is_deleted)
);