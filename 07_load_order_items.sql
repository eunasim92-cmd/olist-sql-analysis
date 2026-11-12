-- 07_load_order_items.sql
-- 목적: order_items 테이블 적재 (적재 후 별도 저장하지 않아 재작성한 기록용 쿼리)
-- 대상: olist_order_items_dataset.csv -> ecommerce_analytics.order_items
-- 줄 끝 확인: PowerShell (Get-Content '<CSV 경로>' -Raw).Contains("`r`n") 결과 False -> '\n' 사용
-- 처음 '\r\n'으로 실행했을 때는 에러 없이 0행이 적재됨, '\n'으로 수정 후 Records 112650, Skipped 0, Warnings 0
-- seller_id는 sellers 테이블을 적재하지 않아 @seller_id 변수로 받고 버림
-- 검산값: COUNT(*) 112,650 / SUM(price) 13,591,643.70 / SUM(freight_value) 2,251,909.54
-- 주의: 이미 적재된 테이블에 다시 실행하면 기본키 중복 에러가 남
-- 실행 전 local_infile 설정 필요, CSV 경로는 본인 환경에 맞게 수정

LOAD DATA LOCAL INFILE '<CSV 폴더>/olist_order_items_dataset.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, order_item_id, product_id, @seller_id,
 shipping_limit_date, price, freight_value);