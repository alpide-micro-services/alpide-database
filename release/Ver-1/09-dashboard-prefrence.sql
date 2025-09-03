CREATE TABLE `alpide-users`.dashboard_preferences (
    preference_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    version INT NOT NULL DEFAULT 0,
    rid BIGINT DEFAULT 0,
    client_user_account_id BIGINT DEFAULT 0,
    category_preference MEDIUMTEXT,
    tiles_preference TEXT,
    card_preference TEXT
);