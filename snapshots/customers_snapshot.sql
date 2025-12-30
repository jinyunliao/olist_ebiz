-- dbt/snapshots/customers_snapshot.sql
{% snapshot customers_snapshot %}
{{
  config(
    target_database=target.database,
    target_schema=var('snapshots_schema', 'public'),     
    unique_key='customer_id',
    strategy='timestamp',
    updated_at='order_purchase_ts'
  )
}}
select
  c.customer_id,
  c.customer_unique_id,
  c.customer_city,
  c.customer_state
from {{ ref('stg_customers') }} c
{% endsnapshot %}


-- target_schema=var('snapshots_schema', 'analytics_snap'),