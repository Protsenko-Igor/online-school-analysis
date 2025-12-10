-- 01_er_diagram.sql
-- SQL для создания таблиц структуры данных онлайн-школы
-- Используется для понимания связей между таблицами

-- Таблица рекламных кампаний
CREATE TABLE campaigns (
    campaign_id VARCHAR(50) PRIMARY KEY,
    source VARCHAR(50),  -- yandex, vk, telegram, influence, partners
    medium VARCHAR(50),  -- cpc, ads, cpa, organic
    campaign_name VARCHAR(255),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(15, 2)
);

-- Таблица кликов по рекламе
CREATE TABLE clicks (
    click_id VARCHAR(50) PRIMARY KEY,
    campaign_id VARCHAR(50) REFERENCES campaigns(campaign_id),
    user_id VARCHAR(50),
    timestamp TIMESTAMP,
    cost DECIMAL(10, 2),
    INDEX idx_clicks_campaign (campaign_id),
    INDEX idx_clicks_user (user_id)
);

-- Таблица заявок (лидов)
CREATE TABLE leads (
    lead_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    campaign_id VARCHAR(50) REFERENCES campaigns(campaign_id),
    created_at TIMESTAMP,
    email VARCHAR(255),
    phone VARCHAR(20),
    landing_page VARCHAR(500),
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    INDEX idx_leads_campaign (campaign_id),
    INDEX idx_leads_user (user_id),
    INDEX idx_leads_created (created_at)
);

-- Таблица взаимодействий с лидами
CREATE TABLE interactions (
    interaction_id VARCHAR(50) PRIMARY KEY,
    lead_id VARCHAR(50) REFERENCES leads(lead_id),
    type VARCHAR(50),  -- zoom_meeting, chatbot, phone_call, email
    status VARCHAR(50),  -- scheduled, completed, cancelled
    created_at TIMESTAMP,
    completed_at TIMESTAMP,
    duration_seconds INT,
    INDEX idx_interactions_lead (lead_id),
    INDEX idx_interactions_created (created_at)
);

-- Таблица продаж
CREATE TABLE sales (
    sale_id VARCHAR(50) PRIMARY KEY,
    lead_id VARCHAR(50) REFERENCES leads(lead_id),
    user_id VARCHAR(50),
    campaign_id VARCHAR(50) REFERENCES campaigns(campaign_id),
    product_name VARCHAR(255),
    amount DECIMAL(10, 2),
    sale_date TIMESTAMP,
    INDEX idx_sales_lead (lead_id),
    INDEX idx_sales_campaign (campaign_id),
    INDEX idx_sales_user (user_id),
    INDEX idx_sales_date (sale_date)
);

-- Таблица активности студентов
CREATE TABLE student_activity (
    activity_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    sale_id VARCHAR(50) REFERENCES sales(sale_id),
    activity_date DATE,
    lessons_completed INT,
    homework_submitted BOOLEAN,
    test_score INT,
    INDEX idx_activity_user (user_id),
    INDEX idx_activity_sale (sale_id),
    INDEX idx_activity_date (activity_date)
);

-- Комментарии к таблицам для документации
COMMENT ON TABLE campaigns IS 'Рекламные кампании с атрибуцией по источникам и каналам';
COMMENT ON TABLE clicks IS 'Клики по рекламе с стоимостью и временными метками';
COMMENT ON TABLE leads IS 'Заявки от потенциальных клиентов с UTM-метками';
COMMENT ON TABLE interactions IS 'Взаимодействия с лидами (звонки, встречи, письма)';
COMMENT ON TABLE sales IS 'Совершенные продажи курсов';
COMMENT ON TABLE student_activity IS 'Активность студентов после покупки курса';

-- Основные связи (уже указаны через REFERENCES выше)
-- Дополнительные связи через user_id
-- clicks.user_id -> leads.user_id
-- leads.user_id -> sales.user_id
