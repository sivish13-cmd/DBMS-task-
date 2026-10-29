# E-Commerce Intelligence Platform — DBMS Tasks IX–XV

**Database:** MySQL 8.0+  
**Engine:** InnoDB  
**Purpose:** One consistent e-commerce schema reused across analytics, advanced queries, database objects, transactions, security, AI feature extraction, and capstone validation.

## Files
- `DBMS_Tasks_IX_XV_MySQL8.sql` — schema, sample data, and runnable queries for Tasks IX–XV.

## How to run
1. Open MySQL Workbench or a MySQL 8.0+ CLI session.
2. Open the `.sql` file and execute it from the top.
3. Run it as a database administrator because the script creates a database, role, and local reporting user.
4. **Warning:** the first lines drop and recreate `ecommerce_intelligence`. Remove the `DROP DATABASE` statement if you must preserve an existing database with that name.
5. Replace the sample password for `report_user` before using this beyond a classroom demo.

## Schema overview
- `customers`: customer identity and city.
- `categories`: product categories.
- `products`: product prices and inventory.
- `orders`: customer orders and lifecycle status.
- `order_items`: products, quantities, and price snapshots at time of sale.
- `payments`: one payment record per order in this simplified model.
- `order_audit`: changes made by the sample order-item procedure.

Relationships: customers 1-to-many orders; orders 1-to-many order_items; products 1-to-many order_items; categories 1-to-many products; orders 1-to-zero-or-one payments; orders 1-to-many audit records.

## Task-by-task explanation

### Task IX — Sales and customer analytics
- Aggregate query returns product count, total inventory units, average price, minimum price, and maximum price.
- Order report calculates each order's line-item total and shows payment status.
- Top customers are sorted by total successful purchase amount.
- Best-selling products are ranked by units sold, with sales value as a tie-breaker.
- Category analysis groups item quantities and revenue by category.

### Task X — Advanced SQL
- A scalar subquery compares each product price to the average product price.
- A common table expression (CTE) calculates each customer's spend, then a nested aggregate returns the maximum spender(s).
- A nested query finds customers with an order above the average order value.
- Monthly reporting groups orders by calendar month and calculates order count and average order value.
- Another CTE compares customer spend to average spend across all customers.

### Task XI — Views, functions, and procedures
- `v_order_sales` exposes reusable order-level reporting.
- `v_category_sales` exposes category-level metrics.
- `fn_order_total(order_id)` calculates a single order's line-item total.
- `sp_get_customer_orders(customer_id)` lists one customer's orders.
- `sp_add_order_item(order_id, product_id, quantity)` checks quantity and stock, inserts an order line, reduces stock, and writes an audit record. Call it inside a transaction so the caller controls commit/rollback.

### Task XII — Transactions and ACID
- The successful demo starts a transaction, creates an order, adds a line, reduces inventory, records payment, updates status, and commits.
- The rollback demo makes a temporary order and stock adjustment, then rolls everything back; its follow-up query should return no order row.
- Atomicity: all related changes commit together or roll back together.
- Consistency: foreign keys, unique constraints, check constraints, and procedure validations reject invalid states.
- Isolation: InnoDB row locking (`SELECT ... FOR UPDATE`) helps prevent two concurrent order requests from overselling the same stock.
- Durability: committed changes persist according to MySQL/server storage configuration.

### Task XIII — Security and performance
- Creates a read-only reporting role and a local reporting account.
- Shows `GRANT` and `REVOKE`; the temporary direct product-table permission is revoked immediately.
- Adds a city index and uses `EXPLAIN` to inspect a customer-order query.
- Indexes can speed reads but consume storage and add write overhead. Production access should follow least privilege and secrets must not be stored in source files.

### Task XIV — BI and AI data preparation
- `RANK()` and `ROW_NUMBER()` rank products within each category.
- Customer segmentation creates interpretable labels (`VIP`, `LOYAL`, `NEW_OR_OCCASIONAL`, `NO_PURCHASE`) from purchase behavior.
- `v_customer_ai_features` creates one feature row per customer for downstream modeling.
- Product/category extraction generates numeric and categorical fields for analysis or machine-learning preparation.
- For real ML use, define a fixed analysis date, exclude leakage features, and document missing-value handling.

### Task XV — Capstone validation
- Row counts confirm the sample tables are populated.
- Revenue summary reports successful orders, purchasing customers, units sold, gross line-item value, and collected payment amounts.
- Low-stock query identifies products below the chosen threshold.
- Payment-vs-order check should return no rows when totals reconcile.
- ER relationship comments document the schema for an ER diagram.

## Sample data and expected behavior
The script seeds six customers, four categories, eight products, nine original orders, order lines, and successful payments. Queries return result sets rather than hard-coded output tables. Exact inventory and row counts after execution include the Task XII successful transaction: product 8 stock decreases by two, and one additional paid order is created. The rollback demo should leave no extra order and should not permanently reduce product 2 stock.

For the seeded records before the transaction demonstration:
- Product count: **8**.
- Total units initially in stock: **272**.
- Average product price: **9,543.75**.
- Minimum product price: **500.00**.
- Maximum product price: **65,000.00**.
- Highest-value customers should include Aarav Sharma and Kabir Singh due to their laptop orders; exact ranking is shown by Task IX query.
- The reconciliation query in Task XV should return **zero rows** for the supplied successful payment data.

## Important classroom / production caveats
- The sample `payments` table models one payment row per order. Real payment systems may have multiple attempts, partial captures, refunds, and separate payment events.
- The reporting account uses a placeholder password. Change it immediately; do not reuse this setup for production.
- MySQL stored functions and procedures can require `CREATE ROUTINE` privileges depending on deployment setup.
- The script uses `CREATE ROLE`, `CHECK`, window functions, and CTEs available in MySQL 8.0; use a current MySQL 8.0 release.
- For a real checkout system, use application-side validation, idempotency keys, secure payment-provider integration, explicit error handling, and tested concurrency controls.