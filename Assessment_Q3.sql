WITH LastTransaction AS (
    -- Get the most recent transaction date for each plan from savings_savingsaccount
    SELECT 
        plan_id,
        owner_id,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0  -- Inflow transactions
    GROUP BY plan_id, owner_id
),
PlanDetails AS (
    -- Get active plans (savings or investment) that are not deleted or archived
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Unknown'
        END AS type,
        COALESCE(lt.last_transaction_date, p.created_on) AS last_transaction_date
    FROM plans_plan p
    LEFT JOIN LastTransaction lt ON p.id = lt.plan_id
    WHERE (p.is_regular_savings = 1 OR p.is_a_fund = 1)
        AND (p.is_deleted IS NULL OR p.is_deleted = 0)
        AND (p.is_archived IS NULL OR p.is_archived = 0)
)
SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days
FROM PlanDetails
WHERE DATEDIFF(CURDATE(), last_transaction_date) > 365
    OR last_transaction_date IS NULL
ORDER BY inactivity_days DESC;
