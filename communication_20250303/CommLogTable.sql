   

  CREATE TABLE `alpide_communication_email_failure` (
  `alpide_communication_email_failure_id` bigint NOT NULL AUTO_INCREMENT,
  `rid` bigint DEFAULT NULL,
  `provider_name` varchar(255) DEFAULT NULL,
  `provider_type` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `body` varchar(2000) DEFAULT NULL,
  `event` varchar(255) DEFAULT NULL,
  `transaction_name` varchar(255) DEFAULT NULL,
  `transaction_data` longtext,
  `date_created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `date_updated` timestamp NULL DEFAULT NULL,
  `customer_id` bigint DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `entity_id` bigint DEFAULT NULL,
  `from_email` varchar(255) DEFAULT NULL,
  `smtp_host` varchar(255) DEFAULT NULL,
  `smtp_password` varchar(255) DEFAULT NULL,
  `smtp_port` varchar(255) DEFAULT NULL,
  `supplier_id` bigint DEFAULT NULL,
  `to_email` varchar(255) DEFAULT NULL,
  `transaction_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`alpide_communication_email_failure_id`)
);

    

 CREATE TABLE `alpide_communication_email_success` (
  `alpide_communication_email_success_id` bigint NOT NULL AUTO_INCREMENT,
  `rid` bigint DEFAULT NULL,
  `provider_name` varchar(255) DEFAULT NULL,
  `provider_type` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `body` varchar(2000) DEFAULT NULL,
  `event` varchar(255) DEFAULT NULL,
  `transaction_name` varchar(255) DEFAULT NULL,
  `transaction_data` longtext,
  `date_created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `date_updated` timestamp NULL DEFAULT NULL,
  `from_email` varchar(255) DEFAULT NULL,
  `smtp_host` varchar(255) DEFAULT NULL,
  `smtp_password` varchar(255) DEFAULT NULL,
  `smtp_port` varchar(255) DEFAULT NULL,
  `to_email` varchar(255) DEFAULT NULL,
  `customer_id` bigint DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `entity_id` bigint DEFAULT NULL,
  `supplier_id` bigint DEFAULT NULL,
  `transaction_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`alpide_communication_email_success_id`)
);

    


   CREATE TABLE `alpide_communication_sms_failure` (
  `alpide_communication_message_failure_id` bigint NOT NULL AUTO_INCREMENT,
  `rid` bigint DEFAULT NULL,
  `header` varchar(255) DEFAULT NULL,
  `transaction_data` longtext,
  `date_created` datetime(6) DEFAULT NULL,
  `date_updated` datetime(6) DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(6),
  `api_key` varchar(255) DEFAULT NULL,
  `error_description` varchar(255) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `sender_id` varchar(255) DEFAULT NULL,
  `to_mobile` varchar(255) DEFAULT NULL,
  `provider_name` varchar(255) DEFAULT NULL,
  `event` varchar(255) DEFAULT NULL,
  `transaction_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`alpide_communication_message_failure_id`)
);

    
    CREATE TABLE `alpide_communication_sms_success` (
  `alpide_communication_sms_success_id` bigint NOT NULL AUTO_INCREMENT,
  `rid` bigint DEFAULT NULL,
  `transaction_data` longtext,
  `date_created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `date_updated` timestamp NULL DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `sender_id` varchar(255) DEFAULT NULL,
  `to_mobile` varchar(255) DEFAULT NULL,
  `provider_name` varchar(255) DEFAULT NULL,
  `api_key` varchar(255) DEFAULT NULL,
  `transaction_name` varchar(255) DEFAULT NULL,
  `event` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`alpide_communication_sms_success_id`)
);

  