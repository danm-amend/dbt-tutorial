with payments as (
    select * from {{ref('stg_payments')}}
),

pivoted as (
    select 
        order_id,

        {%- set payment_methods = ['bank_transfer', 'coupon', 'credit_card', 'gift_card'] -%}

        {% for method in payment_methods %}
        sum(case when payment_method = '{{ method }}' then amount else 0 end) as {{ method }}_amount

        {%- if not loop.last -%}    
            ,
        {%- endif -%}

        {% endfor %}
    from payments
    where status = 'success'
    group by 1
    order by order_id asc
)

select * from pivoted