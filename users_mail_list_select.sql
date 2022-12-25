select
    auth_user_id,
    case when max(step) =1 then '1'
    when max(step) = 2 then '1/2'
    when max(step) =3 then '1/2/3' end as step_finished,
    user_id as edu_user_id
from (
select  
    auth_user_id,
    case  when ev.type = 'assistant_step_training_shown' then 1
    when ev.type = 'assistant_step_training_interacted' then 2
    when ev.type = 'assistant_step_training_completed' then 3 end as step,
    
    case when ev.type = 'assistant_step_training_nav_button_clicked' then split_part(split_part(payload->>'referer'::varchar, '/', 4),'-',1)
        else payload::json->>'classNumber' end as class,
    user_id
from analytics_track_event ev
join edu_user_to_auth_user_relation au ON au.edu_user_id = ev.user_id and au.user_type = 'student'
where ev.created_at >'2022-12-04' and ev.created_at <'2022-12-25'
    and ev.type in ('assistant_step_training_shown','assistant_step_training_interacted','assistant_step_training_completed')
    ) as info
group by  user_id, auth_user_id
