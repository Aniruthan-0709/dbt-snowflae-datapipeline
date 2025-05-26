# dbt\_snowflake\_pipeline

An end-to-end **dbt + Snowflake** pipeline using TPC-H sample data. This project demonstrates a clean implementation of the modern data stack: staged transformations, dimensional modeling, reusable macros, and test-driven development.

---

## 🔧 Setup Overview

### Step 1: Snowflake Admin Setup

```sql
CREATE WAREHOUSE dbt_wh;
CREATE DATABASE dbt_db;
CREATE ROLE dbt_role;
CREATE USER ani;

GRANT USAGE ON WAREHOUSE dbt_wh TO ROLE dbt_role;
GRANT ALL ON DATABASE dbt_db TO ROLE dbt_role;
GRANT ROLE dbt_role TO USER ani;
```

### Step 2: Python Virtual Environment & Install

```bash
python -m venv venv
./venv/Scripts/activate
pip install dbt-core dbt-snowflake
```

### Step 3: Project Initialization

```bash
dbt init dbt_snowflake_pipeline
```

Follow prompts to create Snowflake profile interactively.

### Step 4: dbt Project Config (`dbt_project.yml`)

Models are grouped and materialized as:

```yaml
models:
  staging: { +materialized: view }
  dimensions: { +materialized: table }
  facts: { +materialized: table }
  marts: { +materialized: table }
```

### Step 5: Install dbt-utils

```yaml
# packages.yml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
```

```bash
dbt deps
```

---

## 🧱 Modeling Layers

### Step 6: Staging Layer

Creates clean views from Snowflake sample data.

```sql
-- stg_tpch_orders.sql
select o_orderkey as order_key, o_custkey as customer_key ...
from {{ source('tpch', 'orders') }}

-- stg_tpch_line_items.sql
select {{ dbt_utils.generate_surrogate_key(...) }} as order_item_key, ...
```

### Step 7: Dimensions

```sql
-- dim_orders.sql
select order_key, customer_key, status_code, order_date
from {{ ref('stg_tpch_orders') }}

-- dim_line_items.sql
select order_item_key, part_key, line_number
from {{ ref('stg_tpch_line_items') }}
```

### Step 8: Fact Table

Joins orders and line items + pricing logic using macros:

```sql
-- fact_orders.sql
select o.order_key, l.order_item_key, ...
  {{ discounted_price(...) }} as discounted_price,
  {{ price_after_tax(...) }} as price_after_tax
from {{ ref('stg_tpch_orders') }} o
join {{ ref('stg_tpch_line_items') }} l on o.order_key = l.order_key
```

### Step 8.5: Macros Used

```sql
{% macro discounted_price(p, d) %} ({{ p }} * (1 - {{ d }})) {% endmacro %}
{% macro price_after_tax(p, t) %} ({{ p }} * (1 + {{ t }})) {% endmacro %}
```

### Step 9: Mart - Order Profit Summary

```sql
-- mart_orders_profit.sql
select order_key,
  sum(extended_price) as actual_order_value,
  sum(price_after_tax) as sale_order_value,
  sum(price_after_tax - extended_price) as profit
from {{ ref('fact_orders') }}
group by order_key
```

---

## 🧪 Tests

### Generic Tests (`schema.yml`)

```yaml
- name: dim_orders
  columns:
    - name: order_key
      tests: [not_null, unique]
```

### Singular Test (`tests/test_discount_percentage_limit.sql`)

```sql
select * from {{ ref('fact_orders') }} where discount_percentage > 1
```

---

## 🗺️ Star Schema Overview

```text
                    +----------------+
                    |  dim_orders    |
                    |----------------|
                    | order_key (PK) |
                    | status_code    |
                    | order_date     |
                    +----------------+
                            |
                            |
                            v
                    +---------------------+
                    |     fact_orders     |
                    |---------------------|
                    | order_key (FK)      |
                    | order_item_key (FK) |
                    | extended_price      |
                    | discount_percentage |
                    | price_after_tax     |
                    +---------------------+
                            ^
                            |
                            |
                    +----------------------+
                    |  dim_line_items      |
                    |----------------------|
                    | order_item_key (PK)  |
                    | part_key             |
                    +----------------------+
```

---

## ✅ Run the Project

```bash
dbt run        # builds all models
dbt test       # runs all tests
dbt docs serve # view documentation
```

---

## 📌 Notes

* Profile is configured via interactive `dbt init`
* `dbt_utils` provides reusable macros
* Staging models pull directly from Snowflake Sample Data (`tpch_sf1`)
