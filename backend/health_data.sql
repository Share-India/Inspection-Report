-- SAMPLE INITIAL DATA

-- 1. Companies
INSERT INTO health_company (id, name, logo_url) VALUES 
(1, 'HDFC Ergo', '/assets/logos/hdfc.png'),
(2, 'Star Health', '/assets/logos/star.png'),
(3, 'Care Health', '/assets/logos/care.png')
ON CONFLICT DO NOTHING;

-- 2. Age Bands
INSERT INTO health_age_band (id, min_age, max_age) VALUES
(1, 18, 35),
(2, 36, 45),
(3, 46, 55),
(4, 56, 100)
ON CONFLICT DO NOTHING;

-- 3. Sum Insured Configs
INSERT INTO health_sum_insured (id, amount) VALUES
(1, 500000.00),
(2, 1000000.00),
(3, 2000000.00)
ON CONFLICT DO NOTHING;

-- 4. Products
INSERT INTO health_product (id, company_id, name, type) VALUES
(1, 1, 'Optima Restore', 'Floater'),
(2, 2, 'Comprehensive', 'Floater'),
(3, 3, 'Care Advantage', 'Floater')
ON CONFLICT DO NOTHING;

-- 5. Premium Matrix (Mock Logic)
INSERT INTO health_premium_matrix (product_id, sum_insured_id, age_band_id, city_tier, members, premium) VALUES
(1, 1, 1, 'Tier 1', '1A', 6000.00),
(1, 1, 1, 'Tier 2', '1A', 5400.00),
(1, 1, 1, 'Tier 3', '1A', 4800.00),
(1, 2, 1, 'Tier 1', '1A', 7500.00),
(1, 2, 1, 'Tier 2', '1A', 6750.00),
(1, 2, 1, 'Tier 3', '1A', 6000.00),
(1, 3, 1, 'Tier 1', '1A', 10500.00),
(1, 1, 1, 'Tier 1', '2A', 8500.00),
(1, 1, 1, 'Tier 2', '2A', 7650.00),
(1, 1, 1, 'Tier 3', '2A', 6800.00),
(1, 2, 1, 'Tier 1', '2A', 10500.00),
(1, 2, 1, 'Tier 2', '2A', 9450.00),
(1, 2, 1, 'Tier 3', '2A', 8400.00),
(1, 3, 1, 'Tier 1', '2A', 14500.00),
(1, 1, 1, 'Tier 1', '2A1C', 10200.00),
(1, 2, 1, 'Tier 1', '2A1C', 12500.00),
(1, 1, 2, 'Tier 1', '1A', 7800.00),
(1, 2, 2, 'Tier 1', '1A', 9750.00),
(1, 1, 2, 'Tier 1', '2A', 11050.00),
(1, 2, 2, 'Tier 1', '2A', 13650.00),
(2, 1, 1, 'Tier 1', '1A', 5800.00),
(2, 1, 1, 'Tier 2', '1A', 5220.00),
(2, 1, 1, 'Tier 3', '1A', 4640.00),
(2, 2, 1, 'Tier 1', '1A', 7200.00),
(2, 1, 1, 'Tier 1', '2A', 8200.00),
(2, 2, 1, 'Tier 1', '2A', 10100.00),
(2, 1, 1, 'Tier 1', '2A1C', 9800.00),
(2, 1, 2, 'Tier 1', '1A', 7500.00),
(2, 2, 2, 'Tier 1', '1A', 9300.00),
(2, 1, 2, 'Tier 1', '2A', 10600.00),
(2, 2, 2, 'Tier 1', '2A', 13100.00),
(3, 1, 1, 'Tier 1', '1A', 5500.00),
(3, 1, 1, 'Tier 2', '1A', 4950.00),
(3, 1, 1, 'Tier 3', '1A', 4400.00),
(3, 2, 1, 'Tier 1', '1A', 6900.00),
(3, 1, 1, 'Tier 1', '2A', 7900.00),
(3, 2, 1, 'Tier 1', '2A', 9800.00),
(3, 1, 2, 'Tier 1', '1A', 7100.00),
(3, 2, 2, 'Tier 1', '1A', 8900.00),
(3, 1, 2, 'Tier 1', '2A', 10200.00),
(3, 2, 2, 'Tier 1', '2A', 12700.00);
