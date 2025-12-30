-- dbt/models/marts/dimensions/dim_products.sql
select
  product_id as product_key,
  product_category_name,
  product_weight_g,
  product_length_cm,
  product_height_cm,
  product_width_cm
from {{ ref('stg_products') }}