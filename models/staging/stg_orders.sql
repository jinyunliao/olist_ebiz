-- dbt/models/staging/stg_orders.sql
with src as (
  select
    order_id,
    customer_id,
    order_status,
    cast(order_purchase_timestamp as timestamp) as order_purchase_ts,
    cast(order_approved_at as timestamp)        as order_approved_ts,
    cast(order_delivered_carrier_date as timestamp) as delivered_carrier_ts,
    cast(order_delivered_customer_date as timestamp) as delivered_customer_ts,
    cast(order_estimated_delivery_date as date)  as estimated_delivery_dt
  from {{ source('olist_raw', 'olist_order') }}
)
select
  order_id,
  customer_id,
  lower(order_status) as order_status,
  order_purchase_ts,
  order_approved_ts,
  delivered_carrier_ts,
  delivered_customer_ts,
  estimated_delivery_dt
from src
where order_id is not null
