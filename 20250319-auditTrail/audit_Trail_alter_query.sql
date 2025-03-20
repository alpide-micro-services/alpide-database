ALTER TABLE `alpide-sales`.audit_trail_sales
ADD COLUMN customer_name VARCHAR(255) NULL,
ADD COLUMN transaction_number VARCHAR(255) NULL;


ALTER TABLE `alpide-purchase`.audit_trail_sales
ADD COLUMN customer_name VARCHAR(255) NULL,
ADD COLUMN transaction_number VARCHAR(255) NULL;