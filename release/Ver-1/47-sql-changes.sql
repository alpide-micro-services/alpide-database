ALTER TABLE `alpide-purchase`.subcontract_po_master
    ADD COLUMN operation_id BIGINT NOT NULL DEFAULT 0,
       ADD COLUMN execution_id BIGINT NOT NULL DEFAULT 0,
       ADD COLUMN routing_id BIGINT NOT NULL DEFAULT 0;

ALTER TABLE `alpide-purchase`.`inbound_delivery_sc_po_ref`
    RENAME TO  `alpide-purchase`.`tx_conversion_scpo_to_id_ref` ;


