select 
    order_key,
    sum(extended_price) as actual_order_value,
    sum(price_after_tax) as sale_order_value,
    sum(price_after_tax)-sum(extended_price) as profit
from 
    {{ref('fact_orders')}}
    group by order_key
    

