--Total PU New
--Subscriptions
--transactions
--OLD SubS
--Trans->subs
with  ab_group as (
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

payments as (
            select
            (billing_item.meta->'countDays')::int as countDays,
            date_trunc('month',billing_transaction.created_at) as month,
            date_trunc('week',billing_transaction.created_at) as week,
            user_id,
            u.status,
            billing_order.status as payment_status,
            billing_transaction.created_at,
            billing_item.meta->'period' as sub_type,
            billing_item.title, 
            payment_system,
            coalesce((bs.reason->>'Amount')::FLOAT,billing_item.price) as price,
            case when split_part(billing_order.meta->>'returnUrl'::varchar, '/', 3) = 'resh.skysmart.ru'
            then split_part(split_part(billing_order.meta->>'returnUrl'::varchar, '/', 4),'-',1)
            else split_part(split_part(billing_order.meta->>'returnUrl'::varchar, '/', 5),'-',1) end as class,
            case when split_part(billing_order.meta->>'returnUrl'::varchar, '/', 3) = 'resh.skysmart.ru'
            then split_part(billing_order.meta->>'returnUrl'::varchar, '/', 5) 
            else split_part(billing_order.meta->>'returnUrl'::varchar, '/', 6) end as subject
            --split_part(split_part(billing_order.meta->>'returnUrl'::varchar, '/', 5),'-',1) as class,
            --split_part(billing_order.meta->>'returnUrl'::varchar, '/', 6) as subject
        from   billing_order  
        left join billing_order_item on billing_order_item.billing_order_id = billing_order.id 
        left join billing_item on billing_item.id=item_id
        left join billing_transaction on order_relation_id = billing_order .id 
        left join public.user u on billing_order.user_id = u.id 
        left join billing_transaction_status bs on bs.transaction_id = billing_transaction.id 
       where 
         (lower(name) not like '%test%' or name is null)
        and (lower(surname) not like '%test%' or surname is null)
        and (lower(name) not like '%тест%' or name is null)
        and (lower(surname) not like '%тест%' or surname is null)
        and ((lower(email) not like '%тест%' and lower(email) not like '%test%' and email not in('contentlc2020@yandex.ru','raaaam@gmail.com','jjgjjfjj@mail.ru','skyeatsairplanee2202@gmail.com')  ) or email is null)
        and ( lower(email) not like '%skyeng%'  or email is null)
        and BS.status='success'
        and billing_transaction.status = 'success'
        and billing_transaction.created_at >='2022-11-10' 
        and billing_transaction.created_at < '2022-12-15'
        and U.type='student'
),

payments_join as (
    select
    p.*,
    groups,
    first_test
    from payments p 
    join ab_group ab on p.user_id=ab.user_id and p.created_at>=first_test and groups in ('A','B')
),

        subs as (
        select
        user_id,
        s.created_at,
        s.cancelled_at,
        sp.created_at as pr_created_at,
        subscription_id
        from subscription s
        left join subscription_prolongation sp on sp.subscription_id = s.id
        ),
        
        payments2 as (
        select
        p.*,
        s2.pr_created_at,
        s2.subscription_id,
        case when DATE_PART('day', p.created_at - first_test ) < 30 and 
        s2.pr_created_at is not null then 1 else 0 end as fake_flag,
       case when s3.created_at is null then  s.cancelled_at end as cancelled_at
        from payments_join p
        left join subs s on s.user_id = p.user_id and s.created_at = p.created_at
        left join subs s2 on s2.user_id = p.user_id and s2.pr_created_at = p.created_at
        left join subs s3 on s.user_id = s3.user_id and DATE_PART('day', s3.created_at - s.cancelled_at ) = 0
       ),

pay_cohorts as (
    select
    user_id,
    min(created_at) as first_pay,
    min(case when countDays::int<30 then created_at end) as first_transact,
    min(case when countDays::int>=30 then created_at end) as first_sub
from payments2
where fake_flag=0
group by 1
),

groups as (
select
groups,
count(distinct user_id) as all_users_test
from ab_group
group by 1
),

active as (
select
groups,
count(distinct entity_id) as active_users
from analytics_track_event track
join ab_group on ab_group.user_id=track.entity_id and created_at>=first_test
where type='assistant_solution_loaded' and payload->>'mobileApp'='false'
group by 1
)




select
groups,
--all users in test
all_users_test,
--active users
active_users,
--Revenue
sum(price) as revenue,
--Revenue sub
sum(case when countDays>=30  then price end) as revenue_sub,
--Total PU
count(distinct user_id) as pay_users,

--Total payments 
count(user_id) as payments,


--focus segment
count(distinct case when  split_part(class,'klass',1) in ('8','9','10','11') then user_id end) as pay_users_8_11,

--Total PU New
count(distinct case when date_trunc('month',first_pay)=month then user_id end) as new_users,


--Subscriptions
count(distinct case when countDays>=30  then user_id end) as all_sub_users,
count(case when countDays>=30  then user_id end) as all_sub,

--Subscriptions_cancelled
count(distinct case when countDays>=30 and cancelled_at is not null  then user_id end) as cancell_users,

--transactions
count(distinct case when countDays<30 then user_id end) as transact_users,
count( case when countDays<30 then user_id end) as transactions,

--new transactions
count(distinct case when countDays<30 and date_trunc('month',first_transact)=month  then user_id end) as new_transact_users,
count( case when countDays<30 and date_trunc('month',first_transact)=month then user_id end) as new_transactions,


--NEW SubS
count(distinct case when countDays>=30 and date_trunc('month',first_sub)=month  then user_id end) as new_sub_users,
count( case when countDays>=30 and date_trunc('month',first_sub)=month then user_id end) as new_sub,
--OLD SubS
count(distinct case when countDays>=30 and date_trunc('month',first_sub)<month then user_id end) as old_sub_users,
count( case when countDays>=30 and date_trunc('month',first_sub)<month then user_id end) as old_sub,

--Trans->subs 
count(distinct case when countDays>=30 and date_trunc('month',first_transact)<date_trunc('month',first_sub)
and month = date_trunc('month',first_sub) then user_id end) as transfer_users


from payments2
left join pay_cohorts using(user_id)
left join groups using(groups)
left join active using(groups)
where fake_flag=0
and DATE_PART('day', created_at - first_test ) <= 6 
and created_at<='2022-12-14'
and first_test<='2022-12-14'
group by 1,2,3