with customers as (
    select 
        ID as customer_id,
        first_name,
        last_name 
    from {{ source ('jaffle_shop', 'customers') }}
)

select * from customers