-- 12_customer_segments.sql
-- 목적: 1회 구매 군과 재구매 군의 고객·매출 비중, 인당매출, 주문당 객단가 비교
-- 검산: 고객 90,557 + 2,801 / 주문 90,557 + 5,921 / 매출 합 15,419,773.75

WITH it AS (
    SELECT order_id,
           SUM(price + freight_value) AS 주문매출
    FROM order_items
    GROUP BY order_id
),
cust AS (
    SELECT c.customer_unique_id,
           COUNT(*) AS 주문수,
           SUM(it.주문매출) AS 고객매출,
           CASE WHEN COUNT(*) = 1 THEN '1회 구매' ELSE '재구매' END AS 고객군
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN it ON o.order_id = it.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 고객군,
       COUNT(*)                                                 AS 고객수,
       ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2)          AS 고객비중_pct,
       SUM(주문수)                                               AS 주문수,
       ROUND(SUM(고객매출), 2)                                   AS 매출,
       ROUND(SUM(고객매출) / SUM(SUM(고객매출)) OVER () * 100, 2) AS 매출비중_pct,
       ROUND(SUM(고객매출) / COUNT(*), 2)                        AS 인당매출,
       ROUND(SUM(고객매출) / SUM(주문수), 2)                     AS 주문당객단가,
       ROUND(MAX(고객매출), 2)                                   AS 최대고객매출,
       MAX(주문수)                                               AS 최대주문수
FROM cust
GROUP BY 고객군;