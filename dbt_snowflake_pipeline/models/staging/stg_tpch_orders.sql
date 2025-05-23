select 
 o_orderkey as order_key,
 o_custkey as status_key,
 o_orderstatus as status_code,
 o_orderdate as order_date
from 
{{ source('tpch','orders')}}