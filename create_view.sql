
create view reviews_view 
as
select rating, movie_id
from reviews 
where rating > 4;

select * from reviews_view;