Assessment_Q1: 

 i used INNER JOIN between savings_data and investment_data to ensure only customers with both plan types are included.

then, handled withdrawals by subtracting amount_withdrawn from confirmed_amount to get net deposits.

i then excluded inactive accounts to focus on valid customers.

finally used DISTINCT in COUNT to avoid double-counting plans with multiple transactions.



Assessment_Q2:

Join users_customuser with savings_savingsaccount using owner_id to link customers to their transactions.

Use a subquery to calculate total transactions and time span per customer.

Compute the average transactions per month.

Categorize customers based on the average and aggregate the counts by category.



Assessment_Q3:

i took time to read and comprehend the question

i designed the query logic - Identify Active Accounts, Identify Savings and Investment Plans, Check Transactions, calculate Inactivity etc.

then proceeded to construct the SQL query



Assessment_Q4:

my first approach is to take time to understand the question and prepare my queries.

Calculated avg_profit_per_transaction = 0.001 * (total_transaction_value / total_transactions).

Applied the CLV formula: (total_transactions / adjusted_tenure) * 12 * avg_profit_per_transaction.

Handled zero transactions with a CASE statement to return CLV = 0.

Concatenating first_name and last_name could provide a full name.

A fallback was needed to handle cases where all name fields are NULL


