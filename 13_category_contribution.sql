-- 13_category_contribution.sql
-- 목적: 카테고리별 매출·비중·누적 비중 (상품·번역 누락은 '미분류'로 포함)
-- 검산: 매출 합 15,419,773.75 / 카테고리 74개

WITH base AS (
    SELECT
        CASE
            WHEN p.product_category_name IS NULL THEN '(카테고리 NULL)'
            WHEN t.product_category_name IS NULL THEN CONCAT('(번역 누락) ', p.product_category_name)
            ELSE t.product_category_name_english
        END AS 카테고리,
        oi.order_id,
        oi.price + oi.freight_value AS 매출
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
),
agg AS (
    SELECT
        카테고리,
        COUNT(DISTINCT order_id) AS 주문수,
        SUM(매출) AS 매출
    FROM base
    GROUP BY 카테고리
)
SELECT
    RANK() OVER (ORDER BY 매출 DESC) AS 순위,
    카테고리,
    주문수,
    ROUND(매출, 2) AS 매출,
    ROUND(매출 / SUM(매출) OVER () * 100, 2) AS 비중_pct,
    ROUND(SUM(매출) OVER (ORDER BY 매출 DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(매출) OVER () * 100, 2) AS 누적비중_pct
FROM agg
ORDER BY 매출 DESC;