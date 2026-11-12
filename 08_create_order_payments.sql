CREATE TABLE `ecommerce_analytics`.`order_payments` (
  `order_id` VARCHAR(32) NOT NULL,
  `payment_sequential` INT NOT NULL,
  `payment_type` VARCHAR(11) NOT NULL,
  `payment_installments` INT NOT NULL,
  `payment_value` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`order_id`, `payment_sequential`));
