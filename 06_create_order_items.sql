CREATE TABLE `ecommerce_analytics`.`order_items` (
  `order_id` VARCHAR(32) NOT NULL,
  `order_item_id` INT NOT NULL,
  `product_id` VARCHAR(32) NOT NULL,
  `shipping_limit_date` DATETIME NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `freight_value` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`order_id`, `order_item_id`));
