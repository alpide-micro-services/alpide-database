CREATE TABLE IF NOT EXISTS `alpide-sales`.customer_opening_balance_coa_tx (
                                                                              customer_opening_balance_coa_tx_id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                                                              customer_opening_balance_id BIGINT,
                                                                              relationship_id BIGINT,
                                                                              customer_id BIGINT,
                                                                              customer_name VARCHAR(255),
    currency_code VARCHAR(10),
    tx_type VARCHAR(50),
    tx_date VARCHAR(50),
    fy_start_date VARCHAR(50),
    fy_end_date VARCHAR(50),
    created_by_user_id BIGINT,
    amount DECIMAL(19,2),
    remarks VARCHAR(500),
    accounting_entry VARCHAR(10),
    ledger_account_id BIGINT,
    FOREIGN KEY (customer_opening_balance_id) REFERENCES `alpide-sales`.customer_opening_balance(opening_balance_id)
    );

CREATE TABLE IF NOT EXISTS `alpide-purchase`.supplier_opening_balance_coa_tx (
                                                                                 supplier_opening_balance_coa_tx_id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                                                                 supplier_opening_balance_id BIGINT,
                                                                                 relationship_id BIGINT,
                                                                                 supplier_id BIGINT,
                                                                                 supplier_name VARCHAR(255),
    currency_code VARCHAR(10),
    tx_type VARCHAR(50),
    tx_date VARCHAR(50),
    fy_start_date VARCHAR(50),
    fy_end_date VARCHAR(50),
    created_by_user_id BIGINT,
    amount DECIMAL(19,2),
    remarks VARCHAR(500),
    accounting_entry VARCHAR(10),
    ledger_account_id BIGINT,
    FOREIGN KEY (supplier_opening_balance_id) REFERENCES `alpide-purchase`.supplier_opening_balance(opening_balance_id)
    );


ALTER TABLE `alpide-purchase`.supplier_invoice_master ADD COLUMN invoice_source VARCHAR(50) DEFAULT NULL;