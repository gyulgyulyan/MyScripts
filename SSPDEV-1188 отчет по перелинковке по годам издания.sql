with 
linked as (
    select
    entity_id as user,
    split_part(split_part(json_extract_path_text(payload, 'referrer') , '/', 4),'-',2) as book_id,
    json_extract_path_text(payload, 'referrer') as from_page,
    json_extract_path_text(payload, 'publicationYear') as to_publication_year
    from entity.skysmart_edu_track_event_solutions
    where event_type = 'assistant_publication_year_clicked' 
    and created_at >'2022-12-01' and created_at <'2022-12-25'
    and split_part(split_part(json_extract_path_text(payload, 'referrer') , '/', 4),'-',2) in 
            (65, 1260, 1261, 572, 1262, 74, 1263, 527, 1264, 246, 1265, 88, 1266, 89, 1256, 215, 1257, 536, 1258, 2, 1259)
),

openned as (
select
    json_extract_path_text(payload, 'page') as from_page,
    entity_id as user,
    payload
from
  entity.skysmart_edu_track_event_solutions
where
  event_type = 'assistant_page_subject_opened'
  and created_at > '2022-12-01'
  and created_at < '2022-12-25'
  limit 20
)

select 
    count(distinct o.user) op_us,
    count(distinct l.user) link_us
from openned o
    left join linked l on l.user = o.user and o.from_page = l.from_page
