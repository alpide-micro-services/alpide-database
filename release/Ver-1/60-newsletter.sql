  CREATE TABLE `alpide-communication`.`alpide_form_builder` (
      alpide_form_builder_id INT AUTO_INCREMENT PRIMARY KEY,
      rid INT,
      template_content TEXT,
      template_type VARCHAR(100),
      event_time VARCHAR(100),
      template_name VARCHAR(255),
      template_function_ref TEXT,
      child_index VARCHAR(255),
      fundraising_campaign_id INT DEFAULT 0,
      created_by_user_id INT,
      event_hosted_by VARCHAR(255),
      event_date TIMESTAMP NULL,
      event_title VARCHAR(255),
      event_street1 VARCHAR(255),
      event_street2 VARCHAR(255),
      event_city VARCHAR(255),
      event_state VARCHAR(255),
      event_zip VARCHAR(50),
      version INT DEFAULT 0,
      date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE `alpide-communication`.`alpide_event_rsvp` (
      alpide_event_rsvp_id INT AUTO_INCREMENT PRIMARY KEY,
      rid INT,
      alpide_form_builder_id INT,
      adult_attending INT DEFAULT 0,
      child_attending INT DEFAULT 0,
      is_declined INT DEFAULT 0,
      is_tentative INT DEFAULT 0,
      date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );