-- 99_checks.sql : 보고서 숫자를 재현·검증하는 점검 쿼리 모음
-- 각 쿼리를 실행해서 '기대값'과 같은지 확인한다.

-- [1] 모집단: 고객 수 / 기대값 96,096
SELECT COUNT(DISTINCT customer_unique_id) FROM customers;

-- [2] 재구매 고객 수 (delivered 기준) / 기대값 2,801
SELECT COUNT(*)
FROM (
    SELECT c.customer_unique_id
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
    HAVING COUNT(*) >= 2
) t;

-- [3] 재구매율 분모·분자 두 기준 / 기대값 3.00% (2,801/93,358), 3.12% (2,997/96,096)
WITH delivered_cust AS (
    SELECT c.customer_unique_id,
           COUNT(*) AS cnt
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
all_cust AS (
    SELECT c.customer_unique_id,
           COUNT(*) AS cnt
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT 'delivered 기준'                          AS 기준,
       SUM(cnt >= 2)                            AS 재구매_고객,
       COUNT(*)                                 AS 분모,
       ROUND(SUM(cnt >= 2) / COUNT(*) * 100, 2) AS 재구매율_pct
FROM delivered_cust
UNION ALL
SELECT '전체 주문 기준',
       SUM(cnt >= 2),
       COUNT(*),
       ROUND(SUM(cnt >= 2) / COUNT(*) * 100, 2)
FROM all_cust;

-- [4] 196명 차이 분해 / 기대값 delivered 1건 178명, 0건 18명
WITH cust AS (
    SELECT c.customer_unique_id,
           COUNT(*) AS total_cnt,
           SUM(o.order_status = 'delivered') AS deliv_cnt
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT deliv_cnt, COUNT(*) AS 고객수
FROM cust
WHERE total_cnt >= 2 AND deliv_cnt < 2
GROUP BY deliv_cnt;

-- [5] 상품 행 없는 주문의 상태 분포 / 기대값 합 775, delivered 0건
SELECT o.order_status, COUNT(*) AS 주문수
FROM orders o
LEFT JOIN order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL
GROUP BY o.order_status
ORDER BY 주문수 DESC;

-- [6] 매출 기준 비교 (상품+배송비 vs 결제) / 기대값 15,419,630.29 vs 15,422,461.77, 차이 2,831.48
WITH it AS (
    SELECT order_id,
           SUM(price)         AS price_sum,
           SUM(freight_value) AS freight_sum
    FROM order_items
    GROUP BY order_id
),
pay AS (
    SELECT order_id,
           SUM(payment_value) AS pay_sum
    FROM order_payments
    GROUP BY order_id
)
SELECT COUNT(*)                              AS 주문수,
       ROUND(SUM(it.price_sum), 2)            AS price합,
       ROUND(SUM(it.freight_sum), 2)          AS 배송비합,
       ROUND(SUM(it.price_sum + it.freight_sum), 2) AS 상품plus배송비,
       ROUND(SUM(pay.pay_sum), 2)             AS 결제합
FROM orders o
JOIN it  ON o.order_id = it.order_id
JOIN pay ON o.order_id = pay.order_id
WHERE o.order_status = 'delivered';

-- [6-2] 주문 단위 금액 일치 / 기대값 일치 95,908 · 결제가 큼 362 · 상품이 큼 207
WITH it AS (
    SELECT order_id, SUM(price + freight_value) AS item_sum
    FROM order_items GROUP BY order_id
),
pay AS (
    SELECT order_id, SUM(payment_value) AS pay_sum
    FROM order_payments GROUP BY order_id
)
SELECT CASE
         WHEN it.item_sum = pay.pay_sum THEN '일치'
         WHEN pay.pay_sum > it.item_sum THEN '결제가 큼'
         ELSE '상품이 큼'
       END AS 구분,
       COUNT(*) AS 주문수
FROM orders o
JOIN it  ON o.order_id = it.order_id
JOIN pay ON o.order_id = pay.order_id
WHERE o.order_status = 'delivered'
GROUP BY 구분;

-- [7] 월별 상태 비중 / 기대값 99,441 = delivered 96,478 + 미완료 1,729 + 취소·불가 1,234
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS ym,
       COUNT(*) AS 전체주문,
       SUM(order_status = 'delivered') AS delivered,
       SUM(order_status IN ('shipped','invoiced','processing','created','approved')) AS 미완료,
       SUM(order_status IN ('canceled','unavailable')) AS 취소불가,
       ROUND(SUM(order_status = 'delivered') / COUNT(*) * 100, 1) AS delivered_pct
FROM orders
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY ym;

-- [7-2] 월별 상태 전체 합계 / 기대값 전체 99,441 = delivered 96,478 + 미완료 1,729 + 취소불가 1,234
SELECT COUNT(*) AS 전체주문,
       SUM(order_status = 'delivered') AS delivered,
       SUM(order_status IN ('shipped','invoiced','processing','created','approved')) AS 미완료,
       SUM(order_status IN ('canceled','unavailable')) AS 취소불가
FROM orders;

-- [8] 카테고리 합계 확인 / 기대값 매출 15,419,773.75, 카테고리 74개, 임시항목 203,353.84
WITH base AS (
    SELECT
        CASE
            WHEN p.product_category_name IS NULL THEN '(카테고리 NULL)'
            WHEN t.product_category_name IS NULL
                THEN CONCAT('(번역 누락) ', p.product_category_name)
            ELSE t.product_category_name_english
        END AS 카테고리,
        oi.price + oi.freight_value AS 매출
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN category_translation t
           ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
),
agg AS (
    SELECT 카테고리, SUM(매출) AS 매출 FROM base GROUP BY 카테고리
)
SELECT ROUND(SUM(매출), 2) AS 매출합계,
       COUNT(*) AS 카테고리수,
       SUM(CASE WHEN 카테고리 LIKE '(%' THEN 매출 ELSE 0 END) AS 임시항목매출
FROM agg;