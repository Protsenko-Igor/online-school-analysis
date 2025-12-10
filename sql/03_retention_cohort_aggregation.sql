-- 03_retention_cohort_aggregation.sql
-- Когортный анализ retention и вовлеченности студентов
-- Расчет по неделям для каждой месячной когорты

INSERT INTO `online-school-analytics`.`aggregated/retention_report/`
WITH (
    format = 'csv_with_names'
)
-- 4. Финальный отчет с Retention
SELECT 
    wa.cohort,
    wa.product_name,
    wa.week_number,
    wa.active_students,
    cs.cohort_size,
    (wa.active_students * 100.0 / cs.cohort_size) as retention_pct,
    wa.avg_lessons,
    wa.homework_rate
FROM (
-- Шаг 3. Активность по неделям
SELECT 
    cohort,
    product_name,
    week_number,
    COUNT(DISTINCT user_id) as active_students,
    AVG(lessons_completed) as avg_lessons,
    AVG(CAST(homework_submitted AS DOUBLE)) * 100 as homework_rate
FROM (
-- Шаг 2 - Оставляем только первые 90 дней и формируем когорты
SELECT 
    user_id,
    product_name,
    sale_date,
    activity_date,
    lessons_completed,
    homework_submitted,
    test_score,
    days_from_start,
    week_number,
    -- Когорта: год-месяц
    CAST(DateTime::GetYear(sale_date) AS String) || '-' || 
    CASE 
        WHEN DateTime::GetMonth(sale_date) < 10 
        THEN '0' || CAST(DateTime::GetMonth(sale_date) AS String)
        ELSE CAST(DateTime::GetMonth(sale_date) AS String)
    END as cohort
FROM (
    -- Шаг 1 - Делаем все временные расчеты по прохождению уроков
    SELECT 
        s.user_id as user_id,
        s.product_name as product_name,
        s.sale_date as sale_date,
        sa.activity_date as activity_date,
        sa.lessons_completed as lessons_completed,
        sa.homework_submitted as homework_submitted,
        sa.test_score as test_score,
        CAST((sa.activity_date - s.sale_date) / 86400000000 AS Int64) as days_from_start,
        CAST((sa.activity_date - s.sale_date) / 86400000000 / 7 AS Int64) as week_number
    FROM sales_df s
    JOIN student_activity_df sa ON s.sale_id = sa.sale_id
    WHERE CAST((sa.activity_date - s.sale_date) AS Int64) >= 0)
    WHERE days_from_start <= 90)
WHERE week_number BETWEEN 0 AND 12  -- 12 недель
GROUP BY cohort, product_name, week_number
ORDER BY cohort, product_name, week_number) as wa
JOIN (
    -- Считаем размер когорт
    SELECT 
        cohort,
        product_name,
        COUNT(DISTINCT user_id) as cohort_size
    FROM (
        SELECT DISTINCT 
            user_id,
            product_name,
            CAST(DateTime::GetYear(sale_date) AS String) || '-' || 
            CASE 
                WHEN DateTime::GetMonth(sale_date) < 10 
                THEN '0' || CAST(DateTime::GetMonth(sale_date) AS String)
                ELSE CAST(DateTime::GetMonth(sale_date) AS String)
            END as cohort
        FROM sales_df
    )
    GROUP BY cohort, product_name
) cs ON wa.cohort = cs.cohort AND wa.product_name = cs.product_name
ORDER BY wa.cohort, wa.product_name, wa.week_number;
