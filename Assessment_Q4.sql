WITH TransactionCounts AS (
    -- Count inflows from savings_savingsaccount for regular savings plans
    SELECT 
        s.owner_id,
        COUNT(*) AS transaction_count,
        COALESCE(SUM(s.confirmed_amount), 0) AS transaction_value
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE p.is_regular_savings = 1
    GROUP BY s.owner_id

    UNION ALL

    -- Count withdrawals from withdrawals_withdrawal
    SELECT 
        w.owner_id,
        COUNT(*) AS transaction_count,
        COALESCE(SUM(w.amount_withdrawn), 0) AS transaction_value
    FROM withdrawals_withdrawal w
    GROUP BY w.owner_id
),
AggregatedTransactions AS (
    -- Aggregate inflows and withdrawals per customer
    SELECT 
        owner_id,
        SUM(transaction_count) AS total_transactions,
        SUM(transaction_value) AS total_transaction_value
    FROM TransactionCounts
    GROUP BY owner_id
),
CustomerMetrics AS (
    SELECT 
        u.id AS customer_id,
        -- CONCAT for first_name and last_name, 'Null' if both are NULL
        COALESCE(
            u.name,
            CONCAT(u.first_name, ' ', u.last_name),
            'Null'
        ) AS name,
        -- Calculate tenure in months
        ROUND(
            DATEDIFF(CURRENT_DATE, u.date_joined) / 30.0, 
            2
        ) AS tenure_months,
        -- Handle zero tenure
        GREATEST(
            ROUND(DATEDIFF(CURRENT_DATE, u.date_joined) / 30.0, 2), 
            1
        ) AS adjusted_tenure,
        COALESCE(t.total_transactions, 0) AS total_transactions,
        COALESCE(t.total_transaction_value, 0) AS total_transaction_value
    FROM users_customuser u
    LEFT JOIN AggregatedTransactions t ON u.id = t.owner_id
    WHERE u.date_joined IS NOT NULL 
      AND u.date_joined <= CURRENT_DATE
      AND u.is_account_deleted = 0
)
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    -- CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction
    -- avg_profit_per_transaction = 0.001 * (total_transaction_value / total_transactions)
    CASE 
        WHEN total_transactions = 0 THEN 0
        ELSE ROUND(
            (total_transactions / adjusted_tenure) * 12 * 
            (0.001 * total_transaction_value / total_transactions),
            2
        )
    END AS estimated_clv
FROM CustomerMetrics
ORDER BY estimated_clv DESC;