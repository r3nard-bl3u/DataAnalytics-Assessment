-- Replaced u.name with COALESCE(u.name, TRIM(CONCAT(u.first_name, ' ', u.last_name)), 'Null')

WITH Savings AS (
    SELECT 
        s.owner_id,
        COUNT(*) as savings_count,
        SUM(s.amount) as savings_amount
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE p.is_regular_savings = true
    AND s.amount > 0
    GROUP BY s.owner_id
),
Investments AS (
    SELECT 
        p.owner_id,
        COUNT(*) as investment_count,
        SUM(p.amount) as investment_amount
    FROM plans_plan p
    WHERE (p.is_fixed_investment = true OR p.is_managed_portfolio = true)
    AND p.amount > 0
    GROUP BY p.owner_id
)
SELECT 
    u.id as owner_id,
    COALESCE(u.name, TRIM(CONCAT(u.first_name, ' ', u.last_name)), 'Null') as name,
    s.savings_count,
    i.investment_count,
    COALESCE(s.savings_amount, 0) + COALESCE(i.investment_amount, 0) as total_deposits
FROM users_customuser u
JOIN Savings s ON u.id = s.owner_id
JOIN Investments i ON u.id = i.owner_id
WHERE u.is_account_deleted = false
AND u.is_account_disabled = false
ORDER BY total_deposits DESC;
