/***********************************************************************************************************************************
Dataset :		This is a historical dataset on the modern Olympic Games, including all the Games from Athens 1896 to Rio 2016. 

Data source:	https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results.

Skills Used: 	Joins, CTE's,Window functions,Aggregate functions

Description:	I imported Olympic history data into the local PostgreSQL Server to make it more usable for the following analysis.
***********************************************************************************************************************************/

/************************** SCHEMA **************************/

DROP DATABASE IF EXISTS portfolioprj_olympic;

CREATE DATABASE portfolioprj_olympic
    WITH
    OWNER = postgres
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
    
DROP TABLE IF EXISTS OLYMPIC_EVENTS;

CREATE TABLE IF NOT EXISTS OLYMPIC_EVENTS
(
 id   INT,
 name    VARCHAR,
 sex     VARCHAR,
 age     INT,
 height  VARCHAR,
 weight  VARCHAR,
 team    VARCHAR,
 noc     VARCHAR,
 games   VARCHAR,
 year    INT,
 season  VARCHAR,
 city    VARCHAR,
 sport   VARCHAR,
 event   VARCHAR,
 medal   VARCHAR
);

DROP TABLE IF EXISTS OLYMPIC_NOC_REGIONS;

CREATE TABLE IF NOT EXISTS OLYMPIC_NOC_REGIONS
(
    noc      VARCHAR,
    region   VARCHAR,
    notes    VARCHAR    
);
/************************** SCHEMA **************************/


/************************** DATA ANALYSIS **************************/

--1.SQL query to find the total no of Olympic Games held as per the dataset.

select count (distinct games) as total_olympic_games
	from OLYMPIC_EVENTS;

--2.SQL query to list down all the Olympic Games held so far.

select distinct games,season,city 
	from OLYMPIC_EVENTS
	order by games;

--3.Total number of countries participated in olympics

select count(distinct onr.region) as countries_participated
	from olympic_events oe
	join olympic_noc_regions onr 
	on oe.noc=onr.noc

--4.Fetch total no of countries participated in each olympic games.

select oe.games,count(distinct onr.region) as total_countries
	from olympic_events oe
	join olympic_noc_regions onr 
	on oe.noc=onr.noc
	group by oe.games
	order by oe.games

--5.query to return the Olympic Games which had the highest participating countries and the lowest participating countries.

with highest_lowest_participating_countries as(select *, dense_rank() over(order by re.total_countries desc) max_rank, dense_rank() over(order by re.total_countries) min_rank
		        from 
		        (
		        select oe.games, count(distinct onr.region) as total_countries
				from olympic_events oe
				join olympic_noc_regions onr 
				on oe.noc=onr.noc
				group by oe.games) re
				)				
select games, total_countries 
	from highest_lowest_participating_countries 
	where max_rank = 1 or min_rank = 1


--6. SQL query to return the list of countries who had been part of all Olympics games.
 
select onr.region as country,count(distinct oe.games) as total_participated_games
	from olympic_events oe
	join olympic_noc_regions onr 
	on oe.noc=onr.noc
	group by onr.region
	having count(distinct oe.games)=(select count(distinct games)
                                 		from olympic_events)                            
 
--7.Identify the sport which had played in all summer olympics.

with sport_per_games as(
	select sport,games 
		from  olympic_events
		where season='Summer'
		group by sport,games
 		order by games,sport),	
games_count as(
	select sport,count(games) as total_games
		from sport_per_games
 		group by sport),
total_summer_games as(
	select count(distinct games) as total_games_in_summer 
		from olympic_events
		where season='Summer')
select *
	from games_count
	join total_summer_games
	on games_count.total_games=total_summer_games.total_games_in_summer 

--8.Identify the sport which had played in all winter olympics

with sport_per_games as(
	select sport,games 
		from  olympic_events
		where season='Winter'
 		group by sport,games
 		order by games,sport),	
games_count as(
	select sport,count(games) as total_games
		from sport_per_games
 		group by sport),
total_winter_games as(
	select count(distinct games) as total_games_in_winter 
		from olympic_events
	 	where season='Winter')
select *
	from games_count
	 join total_winter_games
	 on games_count.total_games=total_winter_games.total_games_in_winter

--9.Identify the sport which had played once in all of olympic games.

select sport,count(distinct games)
	 from olympic_events
	 group by sport
	 having count(distinct games)=1

--10.query to fetch the total no of sports played in each olympic games.

select games,count(distinct sport) as no_of_sports
	from olympic_events
	group by games
	order by no_of_sports 

--11.Query to fetch the details of the oldest athletes to win a gold medal at the olympics.

select *
    from olympic_events
    where medal='Gold' and (age) in
        (select max(age)
            from olympic_events
            where medal='Gold')
 
--12.number of male and female athletes participated in all olympic games.

with t1 as(
	select sex as female,count(sex) as female_athletes
        from olympic_events
       	where sex='F'
       	group by sex),
       		 
t2 as(
  select sex as male, count(sex) as male_athelets
    from olympic_events
    where sex='M'
    group by sex
)
select *
from t1,t2

--12. Improved query--with count function

select count(case sex when 'F' then 1 else null end) as female_athletes, count(case sex when 'M' then 1 else null end) as male_athelets
        from olympic_events
        
----12. with sum function

select sum(case sex when 'F' then 1 else 0 end) as female_athletes, sum(case sex when 'M' then 1 else 0 end) as male_athelets
        from olympic_events

--13.query to fetch the top 5 athletes who have won the most gold medals.

with t1 as(
	select name,team,count(name) as total_gold_medals
		from olympic_events
		where medal='Gold'
		group by name,team
		order by total_gold_medals desc),
	
t2 as(
	select *,dense_rank()over (order by total_gold_medals desc) as "top_5_rank"
    	from t1
)
select name,team,total_gold_medals
	from t2
	where top_5_rank<='5'
	
--13. Improved query--query for all the athelets who won gold medals

with t1 as(
select name,team,count(name) as total_gold_medals, dense_rank()over (order by count(name) desc) as "medal_rank"
    from olympic_events
    where medal='Gold'
    group by name,team)
select name,team,total_gold_medals,medal_rank
    from t1
    where medal_rank>='1'

--14.Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).

with t1 as(
	select name,team,count(name) as total_medals
		from olympic_events
		where medal in('Gold','Silver','Bronze')
		group by name,team
		order by total_medals desc),
t2 as(
 	 select *,dense_rank() over(order by total_medals desc)as "r"
      	from t1)
select name,team,total_medals
  	from t2
  	where "r"<='5'
  
--15. SQL query to fetch the medal status of countries in all olympic games.

with t1 as(
	select onr.region ,count(medal) as total_medals
		from olympic_events oe
		join olympic_noc_regions onr 
		on oe.noc=onr.noc
		where medal in ('Gold','Silver','Bronze')
		group by onr.region),
t2 as (
	select *,dense_rank() over (order by total_medals desc) as "rank"
	    from t1)
select region,total_medals,"rank"
	from t2
	where "rank">='1'

--16.query to list down the  total gold, silver and bronze medals won by each country upto year 2016.

select onr.region as Country,count(case when medal='Gold' then 1  end)as Gold_medal,
                             count(case when medal='Silver' then 1  end)as Silver_medal,
                             count(case when medal='Bronze' then 1 end)as Bronze_medal,count(medal) as total_medals
		from olympic_events oe
		join olympic_noc_regions onr 
	    on oe.noc=onr.noc and oe.medal!='NA'
		where medal in ('Gold','Silver','Bronze')
		group by onr.region
		order by total_medals desc

--17.SQL Query to fetch countries which had won silver or bronze medal but never won a gold medal.

with t1 as(select onr.region as country,count(case when medal='Gold' then 1  end)as Gold_medal,
                                        count(case when medal='Silver' then 1  end)as Silver_medal,
                                         count(case when medal='Bronze' then 1 end)as Bronze_medal
from olympic_events oe
	join olympic_noc_regions onr 
	on oe.noc=onr.noc
	group by onr.region
	order by Gold_medal desc,Silver_medal desc,Bronze_medal desc)
select country,Gold_medal,Silver_medal,Bronze_medal
	from t1
	where Gold_medal=0 and(Silver_medal>0 or Bronze_medal>0)
	order by Silver_medal desc

--18.Medal status in Rio olympics(2016 Summer) (latest olympics in this dataset)

with event_country_medal as (
select distinct oe.event "event", onr.region as country, oe.medal as medal
	from olympic_events oe
    join olympic_noc_regions onr 
    on oe.noc=onr.noc and oe.medal != 'NA'
	where oe.games = '2016 Summer'
    group by oe.event, country, medal)
select country, sum(case when medal='Gold' then 1 else 0 end) as Gold,
                sum(case when medal='Silver' then 1 else 0 end) as Silver,
                sum(case when medal='Bronze' then 1 else 0 end) as Bronze, count (medal) as total_medal
    from event_country_medal
    group by country
    order by Gold desc

--19.athelets age over 60 won the gold medal

select name,age,team,sport,games,medal
	from olympic_events
	where age>=60 and medal='Gold'

--20. which sport had more female participant in summer olympics

select sport ,count(sex) as female_participant_summer
	from olympic_events
	where sex='F' and season='Summer'
	group by sport
	order by female_participant_summer desc

--21.which sport had more female participant in winter olympics

select sport,count(sex) as female_participant_winter
	from olympic_events
	where sex='F' and season='Winter'
	group by sport
	order by female_participant_winter desc

--22.which season had more female participant

select sex as female,count(case when season='Summer' then 1 end)as summer_olympics,
                     count(case when season='Winter' then 1 end)as winter_olympics     
	from olympic_events
	where sex='F'
	group by sex


