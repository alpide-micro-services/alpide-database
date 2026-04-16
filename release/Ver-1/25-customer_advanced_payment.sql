-- ============================================================
-- DDL: Advance Payment Feature
-- ============================================================

CREATE TABLE `alpide-sales`.customer_advance_payment (
                                                         advance_payment_id      BIGINT          NOT NULL AUTO_INCREMENT,
                                                         version                 INT             NOT NULL DEFAULT 0,

                                                         rid                     BIGINT          NOT NULL,
                                                         customer_id             BIGINT          NOT NULL,
                                                         customer_name           VARCHAR(255)    NULL,
                                                         customer_email          VARCHAR(255)    NULL,

                                                         advance_number          VARCHAR(100)    NOT NULL,
                                                         reference_no            VARCHAR(100)    NULL,
                                                         description             VARCHAR(500)    NULL,
                                                         remarks                 VARCHAR(500)    NULL,

                                                         advance_amount          DECIMAL(19,4)   NOT NULL DEFAULT 0,
                                                         utilized_amount         DECIMAL(19,4)   NOT NULL DEFAULT 0,
                                                         balance_amount          DECIMAL(19,4)   NOT NULL DEFAULT 0,

    -- OPEN | PARTIALLY_UTILIZED | FULLY_UTILIZED | CANCELLED
                                                         status                  VARCHAR(50)     NOT NULL DEFAULT 'OPEN',

                                                         payment_date            DATETIME        NULL,
                                                         payment_mode_id         BIGINT          NULL,
                                                         payment_mode_name       VARCHAR(100)    NULL,
                                                         payment_mode_detail     VARCHAR(255)    NULL,
                                                         payment_source          VARCHAR(100)    NULL,
                                                         transaction_id          VARCHAR(255)    NULL,

                                                         currency_code           VARCHAR(10)     NULL,
                                                         foreign_currency        VARCHAR(10)     NULL,
                                                         foreign_currency_icon   VARCHAR(20)     NULL,
                                                         is_multi_currency       TINYINT         NOT NULL DEFAULT 0,

                                                         cash_ledger_account_id      BIGINT      NULL,
                                                         advance_ledger_account_id   BIGINT      NULL,

                                                         fy_start_date           DATETIME        NULL,
                                                         fy_end_date             DATETIME        NULL,

                                                         created_by_user_id      BIGINT          NULL,
                                                         updated_by_user_id      BIGINT          NULL,
                                                         date_created            DATETIME       DEFAULT CURRENT_TIMESTAMP,
                                                         date_updated            DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                         PRIMARY KEY (advance_payment_id),
                                                         INDEX idx_cap_rid           (rid),
                                                         INDEX idx_cap_customer      (rid, customer_id),
                                                         INDEX idx_cap_status        (rid, customer_id, status),
                                                         INDEX idx_cap_balance       (rid, customer_id, balance_amount)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================

CREATE TABLE `alpide-sales`.customer_advance_utilization (
                                                             utilization_id          BIGINT          NOT NULL AUTO_INCREMENT,
                                                             version                 INT             NOT NULL DEFAULT 0,

                                                             advance_payment_id      BIGINT          NOT NULL,
                                                             rid                     BIGINT          NOT NULL,
                                                             customer_id             BIGINT          NOT NULL,

                                                             invoice_master_id       BIGINT          NOT NULL,
                                                             invoice_number          VARCHAR(100)    NULL,
                                                             applied_amount          DECIMAL(19,4)   NOT NULL DEFAULT 0,
                                                             application_date        DATETIME        NULL,

                                                             customer_payment_id     BIGINT          NULL,
                                                             advance_number          VARCHAR(100)    NULL,

                                                             created_by_user_id      BIGINT          NULL,
                                                             date_created            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                                             PRIMARY KEY (utilization_id),
                                                             INDEX idx_cau_advance       (advance_payment_id),
                                                             INDEX idx_cau_invoice       (invoice_master_id, rid),
                                                             INDEX idx_cau_customer      (rid, customer_id),

                                                             CONSTRAINT fk_cau_advance
                                                                 FOREIGN KEY (advance_payment_id)
                                                                     REFERENCES customer_advance_payment (advance_payment_id)
                                                                     ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE `alpide-sales`.customer_coa_tx_advance_payment (
                                                                advance_payment_coa_tx_id   BIGINT          NOT NULL AUTO_INCREMENT,
                                                                version                     INT             NOT NULL DEFAULT 0,

                                                                advance_payment_id          BIGINT          NOT NULL,
                                                                rid                         BIGINT          NOT NULL,
                                                                customer_id                 BIGINT          NULL,
                                                                customer_name               VARCHAR(255)    NULL,

                                                                advance_number              VARCHAR(100)    NULL,
                                                                tx_type                     VARCHAR(100)    NULL,
                                                                tx_date                     DATETIME        NULL,
                                                                ledger_account_id           BIGINT          NULL,
                                                                amount                      DECIMAL(19,4)   NOT NULL DEFAULT 0,
                                                                accouting_entry             VARCHAR(20)     NULL,  -- DEBIT / CREDIT

                                                                payment_mode                VARCHAR(100)    NULL,
                                                                payment_mode_id             BIGINT          NULL,
                                                                payment_mode_detail         VARCHAR(255)    NULL,
                                                                instrument_no               VARCHAR(100)    NULL,
                                                                instrument_date             DATETIME        NULL,
                                                                bank_date                   DATETIME        NULL,
                                                                remarks                     VARCHAR(500)    NULL,

                                                                fy_start_date               DATETIME        NULL,
                                                                fy_end_date                 DATETIME        NULL,

                                                                created_by_user_id          BIGINT          NULL,
                                                                updated_by_user_id          BIGINT          NULL,
                                                                date_created                DATETIME        DEFAULT CURRENT_TIMESTAMP,
                                                                date_updated                DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                                                                PRIMARY KEY (advance_payment_coa_tx_id),
                                                                INDEX idx_coa_adv_pay   (advance_payment_id, rid),

                                                                CONSTRAINT fk_coa_adv_pay
                                                                    FOREIGN KEY (advance_payment_id)
                                                                        REFERENCES customer_advance_payment (advance_payment_id)
                                                                        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
