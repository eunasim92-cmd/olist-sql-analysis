CREATE TABLE `ecommerce_analytics`.`customers` (
  `customer_id` VARCHAR(32) NOT NULL,
  `customer_unique_id` VARCHAR(32) NOT NULL,
  `customer_zip_code_prefix` VARCHAR(5) NULL,
  `customer_city` VARCHAR(45) NULL,
  `customer_state` CHAR(2) NULL,
  PRIMARY KEY (`customer_id`));
