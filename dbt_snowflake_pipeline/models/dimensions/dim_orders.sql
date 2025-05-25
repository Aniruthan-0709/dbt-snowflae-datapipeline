select 
    order_key,
    customer_key,
    status_code,
    order_date
from
    {{ref('stg_tpch_orders')}}