select *
from 
    {{ref('fact_orders')}}
where
    discount_percentage>1