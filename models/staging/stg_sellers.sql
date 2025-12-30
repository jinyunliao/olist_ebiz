-- dbt/models/staging/stg_sellers.sql
select
  seller_id,
  seller_zip_code_prefix,
  seller_city,
  seller_state
from {{ source('olist_raw', 'olist_sellers') }}
where seller_id is not null