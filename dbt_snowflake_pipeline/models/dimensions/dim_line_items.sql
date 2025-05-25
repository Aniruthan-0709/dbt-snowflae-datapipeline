select
    order_item_key,
    part_key,
    line_number
from
    {{ref('stg_tpch_line_items')}}
