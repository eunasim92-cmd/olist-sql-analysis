-- 10_monthly_revenue.sql
-- 목적: delivered 주문의 월별 주문수·매출·객단가와 전월 대비·전년 동월 대비 증감
-- 대상: delivered 주문 / 매출 = order_items price + freight_value
-- 해석 구간: 전월 대비는 2017-02 이후, 전년 동월은 2018-01 이후 해석 (2016년은 주문 1·265·1건)
-- 검산: 주문수 합 96,478 / 매출 합 15,419,773.75
-- 참고: 2016-11은 주문이 없어 행이 없고, 이 달이 기준인 증감(2016-12 전월, 2017-11 전년 동월)은 NULL이다.

WITH it AS (
    SELECT order_id, SUM(price + freight_value) AS 주문매출
    FROM order_items
    GROUP BY order_id
),
monthly AS (
    SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS ym,
           COUNT(*) AS 주문수,
           SUM(it.주문매출) AS 매출
    FROM orders o
    JOIN it ON o.order_id = it.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01')
)
SELECT m.ym,
       m.주문수,
       ROUND(m.매출, 2) AS 매출,
       ROUND(m.매출 / m.주문수, 2) AS 객단가,
       ROUND(p1.매출, 2) AS 전월매출,
       ROUND((m.매출 / p1.매출 - 1) * 100, 1) AS 전월대비_pct,
       ROUND((m.매출 / p12.매출 - 1) * 100, 1) AS 전년동월대비_pct
FROM monthly m
LEFT JOIN monthly p1
       ON p1.ym = DATE_FORMAT(DATE_SUB(m.ym, INTERVAL 1 MONTH), '%Y-%m-01')
LEFT JOIN monthly p12
       ON p12.ym = DATE_FORMAT(DATE_SUB(m.ym, INTERVAL 12 MONTH), '%Y-%m-01')
ORDER BY m.ym;