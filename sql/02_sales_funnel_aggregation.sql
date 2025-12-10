-- 02_sales_funnel_aggregation.sql
-- Агрегация данных для построения воронки продаж и расчета ROMI
-- Используется в Yandex Query (YQL) с адаптацией под синтаксис

INSERT INTO `online-school-analytics`.`aggregated/sales_funnel/`
WITH (
    format = 'csv_with_names'
)
SELECT 
    cm.start_date,
    cm.source,
    cm.medium,
    cm.campaign_name,
    COUNT(DISTINCT c.click_id) as clicks,
    COUNT(DISTINCT l.lead_id) as leads,
    COUNT(DISTINCT s.sale_id) as sales,
    SUM(s.amount) as revenue,
    SUM(c.cost) as cost
FROM campaigns_df as cm
LEFT JOIN clicks_df as c ON cm.campaign_id = c.campaign_id
LEFT JOIN leads_df as l ON cm.campaign_id = l.campaign_id
LEFT JOIN sales_df as s ON l.lead_id = s.lead_id
GROUP BY 
    cm.start_date,
    cm.source,
    cm.medium,
    cm.campaign_name;
