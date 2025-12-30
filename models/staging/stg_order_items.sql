-- dbt/models/staging/stg_order_items.sql
select
  order_id,
  order_item_id,
  product_id,
  seller_id,
  cast(price as numeric)    as price,
  cast(freight_value as numeric) as freight_value
from {{ source('olist_raw', 'olist_order_items') }}
where order_id is not null and order_item_id is not null 