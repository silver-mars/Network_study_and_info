select distinct 
status_id,
round(
((count(*) over (partition by status_id )) * 100)::numeric 
/ count(*) over ()
, 2) as percent 
from tables 
where dateinsert > '2023-02-15' and 
checks_id in (9)
order by status_id 

select id, dec_code, dates 
from clc 
where id in (
select id 
from tables 
where dateinsert > '2023-02-15' and 
checks_id = 9
order by id desc)
