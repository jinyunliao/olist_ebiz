-- dbt/models/marts/dimensions/dim_geolocation.sql
with ranked as (
    select *,
           row_number() over (partition by geolocation_zip_code_prefix order by geolocation_lat desc) as rn
    from {{ ref('stg_geolocation') }}
)
select
    geolocation_zip_code_prefix as zip_key,
    geolocation_city,
    geolocation_state,
    geolocation_lat,
    geolocation_lng
from ranked
where rn = 1
