-- dbt/models/marts/dimensions/dim_sellers.sql
with base as (
  select
    s.seller_id,
    s.seller_city,
    s.seller_state,
    g.geolocation_lat,
    g.geolocation_lng,
    row_number() over (partition by s.seller_id order by s.seller_id desc) as rn
  from {{ ref('stg_sellers') }} s
  left join {{ ref('stg_geolocation') }} g
    on s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
)


select
  seller_id as seller_key,
  seller_city,
  seller_state,
  geolocation_lat,
  geolocation_lng
from base
where rn = 1 