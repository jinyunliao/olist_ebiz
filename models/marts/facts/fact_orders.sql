-- dbt/models/marts/facts/fact_orders.sql
with orders as (
  select * from {{ ref('stg_orders') }}
),
items as (
  select * from {{ ref('stg_order_items') }}
),
agg_items as (
  select
    order_id,
    sum(price)         as total_price,
    sum(freight_value) as total_freight,
    count(*)           as item_count
  from items
  group by order_id
),
joined as (
  select
    o.order_id                              as order_key,
    o.customer_id                           as customer_key,
    -- 事实表只保留key，维度字段在维表
    min(o.order_purchase_ts)                as order_purchase_ts,
    min(o.delivered_customer_ts)            as delivered_customer_ts,
    min(o.order_approved_ts)                as order_approved_ts,
    min(o.estimated_delivery_dt)            as estimated_delivery_dt,
    a.total_price,
    a.total_freight,
    a.item_count,
    o.order_status
  from orders o
  left join agg_items a using(order_id)
  group by o.order_id, o.customer_id, a.total_price, a.total_freight, a.item_count, o.order_status
), 
ranked as (
    select *,
           row_number() over (partition by order_key order by order_key desc) as rn
    from joined
)


-- dbt/models/marts/facts/fact_orders.sql

select
    j.order_key,
    j.customer_key,
    j.order_purchase_ts,
    j.delivered_customer_ts,
    j.order_approved_ts,
    j.estimated_delivery_dt,
    j.total_price,
    j.total_freight,
    j.item_count,
    j.order_status
from ranked j
where j.order_status in (
    {% for s in var('order_status_valid') %}
        '{{ s }}'
        {% if not loop.last %},{% endif %}
    {% endfor %}
)
and rn = 1