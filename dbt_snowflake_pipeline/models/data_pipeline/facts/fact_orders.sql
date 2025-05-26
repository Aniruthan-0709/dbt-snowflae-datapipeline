select 
    o.order_key,
    l.order_item_key,
    l.quantity,
    l.extended_price,
    l.discount_percentage,
    l.tax_rate,
    {{ discounted_price('extended_price', 'discount_percentage') }} as discounted_price,
    {{ price_after_tax(discounted_price('extended_price', 'discount_percentage'), 'tax_rate') }} as price_after_tax
from 
    {{ ref('stg_tpch_orders') }} as o
inner join 
    {{ ref('stg_tpch_line_items') }} as l 
    on l.order_key = o.order_key
