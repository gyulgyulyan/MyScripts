--1208 solutions.Monetization.subjectSubscriptionNovemberTestGroup

with  
ab_group as (
select 
user_id,
max(created_at) as first_test,
max(case when value::varchar ='"control"' then 'Control'
		 when value::varchar ='"test"' then 'A' 
         when value::varchar ='"test2"' then 'B' end) as groups
from user_feature uf
where 
feature_id in (1208)
group by 1),
active as (select
    date_trunc('day',first_test) as first_test_d,
    groups,
    count(distinct entity_id) FILTER (WHERE type = 'assistant_solution_loaded') as active_users, --'assistant_solution_loaded'
    count(distinct entity_id) FILTER (WHERE type = 'assistant_solution_loaded' and split_part(split_part(payload->>'referer'::varchar, '/', 4),'-',1) in ('8','9','10','11')) as active_users_8_11, 
    count(distinct entity_id) FILTER (WHERE type = 'assistant_buy_access_shown') as paywall_show ,
    count(distinct entity_id) FILTER (WHERE type = 'assistant_buy_access_shown' and split_part(split_part(payload->>'referer'::varchar, '/', 4),'-',1) in ('8','9','10','11')) as paywall_show_8_11,
    count(distinct entity_id) FILTER (WHERE type = 'assistant_buy_access_clicked') as paywall_click
from analytics_track_event track
    join ab_group on ab_group.user_id=track.entity_id and created_at>=first_test
where type in ('assistant_buy_access_clicked','assistant_buy_access_shown', 'assistant_solution_loaded') and payload->>'mobileApp'='false' and created_at between '2022-11-10' and '2022-12-14'
group by first_test_d, groups)

select
    groups,
    sum(active_users),
    sum(active_users_8_11) as active_users_8_11,
    sum(paywall_show) as paywall_show,
    sum(paywall_show_8_11) as paywall_show_8_11,
    sum(paywall_click) as paywall_click
from active
group by groups
order by groups

