-- 11_purchase_frequency.sql
-- 목적: delivered 기준 고객(customer_unique_id)별 구매 횟수 분포
-- 검산: 고객 합 93,358 / 주문 합 96,478 / 2건 이상 고객 2,801

WITH cust AS (
    SELECT c.customer_unique_id,
           COUNT(*) AS cnt
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT cnt AS 주문횟수,
       COUNT(*) AS 고객수,
       ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS 비중_pct
FROM cust
GROUP BY cnt
ORDER BY cnt;