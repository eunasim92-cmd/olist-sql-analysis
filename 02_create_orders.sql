-- 실행 전 SET GLOBAL local_infile = 1; 필요 (CSV 경로는 본인 환경에 맞게 수정)
LOAD DATA LOCAL INFILE '<CSV 폴더>/olist_orders_dataset.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_status,
 @purchase, @approved, @carrier, @customer_date, @estimated)
SET
  order_purchase_timestamp      = NULLIF(@purchase, ''),
  order_approved_at             = NULLIF(@approved, ''),
  order_delivered_carrier_date  = NULLIF(@carrier, ''),
  order_delivered_customer_date = NULLIF(@customer_date, ''),
  order_estimated_delivery_date = NULLIF(@estimated, '');