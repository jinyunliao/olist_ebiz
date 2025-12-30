-- dbt/models/intermediate/int_order_items_summary.sql

with order_items as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        price,
        freight_value
    from {{ ref('stg_order_items') }}

),

aggregated as (

    select
        order_id,
        count(order_item_id) as item_count,
        sum(price) as total_price,
        sum(freight_value) as total_freight,
        avg(price) as avg_price,
        max(price) as max_price,
        min(price) as min_price
    from order_items
    group by order_id

)

select * from aggregated;
