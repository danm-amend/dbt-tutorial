{{ config(
    materialized='incremental',
    unique_key = 'event_id'
)}}


with events as (
    select * from {{ source('snowplow', 'events') }}
    {% if is_incremental() %}
    where cast(collector_tstamp as datetime) >= (select date_add(max(cast(max_collector_tstamp as datetime)), INTERVAL 12 hour) from {{ this }})
    {% endif %}
),

page_views as (
    select * from events
    where event = 'page_view'
),

aggregated_page_events as (
    select 
        event_id,
        count(*) * 10 as approx_time_on_page,
        min(derived_tstamp) as page_view_start,
        max(collector_tstamp) as max_collector_tstamp,
    from events 
    group by 1
),

joined as (
    select 
        *
    from page_views
    left join aggregated_page_events using (event_id)
)

select * from joined