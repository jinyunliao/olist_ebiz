-- dbt/models/staging/stg_customers.sql
select
  customer_id,
  customer_unique_id,
  customer_zip_code_prefix,
  customer_city,
  customer_state
from {{ source('olist_raw', 'olist_customers') }}
where customer_id is not null

