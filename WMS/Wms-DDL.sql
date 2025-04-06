CREATE TABLE `alpide-inventory`.wms_storage_type (
    storage_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    version BIGINT NOT NULL DEFAULT 0,
    rid BIGINT,
    storage_type_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    max_capacity INT,
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by_user_id BIGINT,
    updated_by_user_id BIGINT
);

CREATE TABLE `alpide-inventory`.wms_storage_bin (
    storage_bin_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    version BIGINT NOT NULL DEFAULT 0,
    rid BIGINT,
    storage_bin_name VARCHAR(255) NOT NULL,
    storage_bin_type VARCHAR(255),
    capacity INT,
    bin_location VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    storage_type_id BIGINT NOT NULL,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by_user_id BIGINT,
    updated_by_user_id BIGINT,
    FOREIGN KEY (storage_type_id) REFERENCES wms_storage_type(storage_type_id) ON DELETE CASCADE
);


CREATE TABLE `alpide-inventory`.wms_packing_unit (
    package_unit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    version BIGINT NOT NULL DEFAULT 0,
    rid BIGINT,
    package_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    dimension VARCHAR(255),
    weight VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by_user_id BIGINT,
    updated_by_user_id BIGINT
);


CREATE TABLE `alpide-inventory`.wms_batch (
    batch_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    version BIGINT NOT NULL DEFAULT 0,
    rid BIGINT,
    batch_number VARCHAR(255) NOT NULL UNIQUE,
    sku VARCHAR(255),
    is_sku_print BOOLEAN DEFAULT FALSE,
    item_name VARCHAR(255),
    is_item_name_print BOOLEAN DEFAULT FALSE,
    sled DATE,
    is_sled_print BOOLEAN DEFAULT FALSE,
    mfg_date DATE,
    is_mfg_date_print BOOLEAN DEFAULT FALSE,
    origin_of_country VARCHAR(255),
    is_coo_print BOOLEAN DEFAULT FALSE,
    attributes JSON,
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by_user_id BIGINT,
    updated_by_user_id BIGINT
);