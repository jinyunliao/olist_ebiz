-- dbt/models/staging/stg_geolocation.sql
select
  geolocation_zip_code_prefix,
  geolocation_city,
  geolocation_state,
  geolocation_lat,
  geolocation_lng
from {{ source('olist_raw', 'olist_geolocation') }}
