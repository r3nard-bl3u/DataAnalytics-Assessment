WITH AllTransactions AS (
    -- Savings transactions
    SELECT 
        owner_id,
        transaction_date
    FROM savings_savingsaccount
    WHERE transaction_date IS NOT NULL
    UNION ALL
    -- Withdrawal transactions
    SELECT 
        owner_id,
        transaction_date
    FROM withdrawals_withdrawal
    WHERE transaction_date IS NOT NULL
),
TransactionsPerMonth AS (
    -- Count transactions per customer per month
    SELECT 
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m-01') AS transaction_month,
        COUNT(*) AS transaction_count
    FROM AllTransactions
    GROUP BY owner_id, DATE_FORMAT(transaction_date, '%Y-%m-01')
),
AvgTransactions AS (
    -- Calculate average transactions per month per customer
    SELECT 
        owner_id,
        AVG(transaction_count) AS avg_transactions_per_month
    FROM TransactionsPerMonth
    GROUP BY owner_id
),
FrequencyCategories AS (
    -- Categorize customers based on average transactions
    SELECT 
        owner_id,
        avg_transactions_per_month,
        CASE 
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM AvgTransactions
)
-- Aggregate results by frequency category
SELECT 
    frequency_category,
    COUNT(DISTINCT owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM FrequencyCategories
GROUP BY frequency_category
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        WHEN frequency_category = 'Low Frequency' THEN 3
    END;