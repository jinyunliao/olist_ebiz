-- dbt/models/marts/dimensions/dim_customers.sql
with base as (
  select
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    g.geolocation_lat,
    g.geolocation_lng,
    row_number() over (partition by c.customer_id order by c.customer_id desc) as rn
  from {{ ref('stg_customers') }} c
  left join {{ ref('stg_geolocation') }} g
    on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
)
select
  customer_id as customer_key,
  customer_unique_id,
  customer_city,
  customer_state,
  geolocation_lat,
  geolocation_lng
from base
where rn=1