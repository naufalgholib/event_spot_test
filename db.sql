-- -----------------------------------------------------
-- Database EventSpot
-- -----------------------------------------------------
CREATE DATABASE IF NOT EXISTS `event_spot` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `event_spot`;

-- -----------------------------------------------------
-- Table `users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `phone_number` VARCHAR(20) NULL,
  `profile_picture` VARCHAR(255) NULL,
  `bio` TEXT NULL,
  `user_type` ENUM('admin', 'user', 'promotor') NOT NULL DEFAULT 'user',
  `is_verified` TINYINT(1) NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `email_verified_at` TIMESTAMP NULL,
  `remember_token` VARCHAR(100) NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `users_email_unique` (`email` ASC)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `promotor_details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `promotor_details` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `company_name` VARCHAR(255) NULL,
  `company_logo` VARCHAR(255) NULL,
  `description` TEXT NULL,
  `website` VARCHAR(255) NULL,
  `social_media` JSON NULL,
  `verification_status` ENUM('pending', 'verified', 'rejected') NOT NULL DEFAULT 'pending',
  `verification_document` VARCHAR(255) NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_promotor_details_users_idx` (`user_id` ASC),
  CONSTRAINT `fk_promotor_details_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `categories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `categories` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `icon` VARCHAR(255) NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `categories_slug_unique` (`slug` ASC)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `events`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `events` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `is_ai_generated` TINYINT(1) NOT NULL DEFAULT 0,
  `poster_image` VARCHAR(255) NULL,
  `promotor_id` BIGINT UNSIGNED NOT NULL,
  `category_id` BIGINT UNSIGNED NOT NULL,
  `location_name` VARCHAR(255) NOT NULL,
  `address` TEXT NOT NULL,
  `latitude` DECIMAL(10,8) NULL,
  `longitude` DECIMAL(11,8) NULL,
  `start_date` DATETIME NOT NULL,
  `end_date` DATETIME NOT NULL,
  `registration_start` DATETIME NOT NULL,
  `registration_end` DATETIME NOT NULL,
  `is_free` TINYINT(1) NOT NULL DEFAULT 1,
  `price` DECIMAL(10,2) NULL DEFAULT 0.00,
  `max_attendees` INT NULL,
  `is_published` TINYINT(1) NOT NULL DEFAULT 1,
  `is_featured` TINYINT(1) NOT NULL DEFAULT 0,
  `is_approved` TINYINT(1) NOT NULL DEFAULT 1,
  `views_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `events_slug_unique` (`slug` ASC),
  INDEX `fk_events_promotor_idx` (`promotor_id` ASC),
  INDEX `fk_events_category_idx` (`category_id` ASC),
  INDEX `events_start_date_idx` (`start_date` ASC),
  INDEX `events_end_date_idx` (`end_date` ASC),
  INDEX `events_is_published_idx` (`is_published` ASC),
  CONSTRAINT `fk_events_promotor`
    FOREIGN KEY (`promotor_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_events_category`
    FOREIGN KEY (`category_id`)
    REFERENCES `categories` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `event_attendees`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `event_attendees` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `registration_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('registered', 'attended', 'cancelled', 'pending_payment') NOT NULL DEFAULT 'registered',
  `ticket_code` VARCHAR(100) NULL,
  `check_in_time` TIMESTAMP NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_event_user` (`event_id` ASC, `user_id` ASC),
  INDEX `fk_event_attendees_event_idx` (`event_id` ASC),
  INDEX `fk_event_attendees_user_idx` (`user_id` ASC),
  CONSTRAINT `fk_event_attendees_event`
    FOREIGN KEY (`event_id`)
    REFERENCES `events` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_event_attendees_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `event_images`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `event_images` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `image_path` VARCHAR(255) NOT NULL,
  `is_primary` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_event_images_event_idx` (`event_id` ASC),
  CONSTRAINT `fk_event_images_event`
    FOREIGN KEY (`event_id`)
    REFERENCES `events` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `comments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `comments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `content` TEXT NOT NULL,
  `is_approved` TINYINT(1) NOT NULL DEFAULT 1,
  `parent_id` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_comments_event_idx` (`event_id` ASC),
  INDEX `fk_comments_user_idx` (`user_id` ASC),
  INDEX `fk_comments_parent_idx` (`parent_id` ASC),
  CONSTRAINT `fk_comments_event`
    FOREIGN KEY (`event_id`)
    REFERENCES `events` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_comments_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_comments_parent`
    FOREIGN KEY (`parent_id`)
    REFERENCES `comments` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `bookmarks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `bookmarks` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_user_event_bookmark` (`user_id` ASC, `event_id` ASC),
  INDEX `fk_bookmarks_user_idx` (`user_id` ASC),
  INDEX `fk_bookmarks_event_idx` (`event_id` ASC),
  CONSTRAINT `fk_bookmarks_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_bookmarks_event`
    FOREIGN KEY (`event_id`)
    REFERENCES `events` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `followers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `followers` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `promotor_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_user_promotor` (`user_id` ASC, `promotor_id` ASC),
  INDEX `fk_followers_user_idx` (`user_id` ASC),
  INDEX `fk_followers_promotor_idx` (`promotor_id` ASC),
  CONSTRAINT `fk_followers_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_followers_promotor`
    FOREIGN KEY (`promotor_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `category_subscriptions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `category_subscriptions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `category_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_user_category` (`user_id` ASC, `category_id` ASC),
  INDEX `fk_category_subscriptions_user_idx` (`user_id` ASC),
  INDEX `fk_category_subscriptions_category_idx` (`category_id` ASC),
  CONSTRAINT `fk_category_subscriptions_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_category_subscriptions_category`
    FOREIGN KEY (`category_id`)
    REFERENCES `categories` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `notifications`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `content` TEXT NOT NULL,
  `type` VARCHAR(50) NOT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `data` JSON NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_notifications_user_idx` (`user_id` ASC),
  INDEX `notifications_is_read_idx` (`is_read` ASC),
  CONSTRAINT `fk_notifications_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `payments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `payments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `attendee_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `payment_method` VARCHAR(100) NOT NULL,
  `transaction_id` VARCHAR(255) NULL,
  `status` ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
  `payment_date` TIMESTAMP NULL,
  `midtrans_snap_token` VARCHAR(255) NULL,
  `midtrans_order_id` VARCHAR(255) NULL,
  `payment_details` JSON NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_payments_attendee_idx` (`attendee_id` ASC),
  CONSTRAINT `fk_payments_attendee`
    FOREIGN KEY (`attendee_id`)
    REFERENCES `event_attendees` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `statistics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `statistics` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `page_views` INT UNSIGNED NOT NULL DEFAULT 0,
  `unique_visitors` INT UNSIGNED NOT NULL DEFAULT 0,
  `engagement_rate` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `click_through_rate` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `data_date` DATE NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_event_date` (`event_id` ASC, `data_date` ASC),
  INDEX `fk_statistics_event_idx` (`event_id` ASC),
  CONSTRAINT `fk_statistics_event`
    FOREIGN KEY (`event_id`)
    REFERENCES `events` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `user_preferences`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `user_preferences` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `email_notifications` TINYINT(1) NOT NULL DEFAULT 1,
  `push_notifications` TINYINT(1) NOT NULL DEFAULT 1,
  `event_reminders` TINYINT(1) NOT NULL DEFAULT 1,
  `preferred_categories` JSON NULL,
  `preferred_locations` JSON NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `user_preferences_user_id_unique` (`user_id` ASC),
  CONSTRAINT `fk_user_preferences_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `failed_jobs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` VARCHAR(255) NOT NULL,
  `connection` TEXT NOT NULL,
  `queue` TEXT NOT NULL,
  `payload` LONGTEXT NOT NULL,
  `exception` LONGTEXT NOT NULL,
  `failed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `failed_jobs_uuid_unique` (`uuid` ASC)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `password_reset_tokens`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `email` VARCHAR(255) NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`email`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `personal_access_tokens`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `personal_access_tokens` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tokenable_type` VARCHAR(255) NOT NULL,
  `tokenable_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `token` VARCHAR(64) NOT NULL,
  `abilities` TEXT NULL,
  `last_used_at` TIMESTAMP NULL,
  `expires_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `personal_access_tokens_token_unique` (`token` ASC),
  INDEX `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type` ASC, `tokenable_id` ASC)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `event_tags`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `event_tags` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `event_tags_slug_unique` (`slug` ASC)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `event_tag_relations`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `event_tag_relations` (
  `event_id` BIGINT UNSIGNED NOT NULL,
  `tag_id` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`event_id`, `tag_id`),
  INDEX `fk_event_tag_relations_tag_idx` (`tag_id` ASC),
  CONSTRAINT `fk_event_tag_relations_event`
    FOREIGN KEY (`event_id`)
    REFERENCES `events` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_event_tag_relations_tag`
    FOREIGN KEY (`tag_id`)
    REFERENCES `event_tags` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;