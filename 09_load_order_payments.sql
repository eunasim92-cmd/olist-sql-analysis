-- 실행 전 SET GLOBAL local_infile = 1; 필요 (CSV 경로는 본인 환경에 맞게 수정)
LOAD DATA LOCAL INFILE '<CSV 폴더>/olist_orders_dataset.csv'
INTO TABLE order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, payment_sequential, payment_type, payment_installments, payment_value);