
# Q1 Show the percentage of wins of each bidder in the order of highest to lowest percentage.


select * from ipl_bidder_details;
select * from ipl_bidding_details;
select * from ipl_bidder_points;

select bp.bidder_id ,bd.bidder_name , bbd.bid_status , bp.no_of_bids ,bp.total_points , sum(bbd.bid_status= "won"),
(sum(bbd.bid_status='Won')/bp.no_of_bids)*100 as percentage_of_wins
from ipl_bidder_details bd join ipl_bidder_points bp
on bd.bidder_id = bp.bidder_id
join ipl_bidding_details as bbd 
on bbd.bidder_id = bd.bidder_id 
group by bp.bidder_id 
order by percentage_of_wins desc;

# Q2 Display the number of matches conducted at each stadium with the stadium name and city.

select * from ipl_match_schedule;
select * from ipl_match;
select * from ipl_stadium;

select stadium_id, stadium_name, city, count(schedule_id) 
from ipl_stadium s join ipl_match_schedule mc
using (stadium_id)
group by stadium_name
order by STADIUM_ID;


# Q3 In a given stadium, what is the percentage of wins by a team which has won the toss?

select count(*) from ipl_match_schedule;
select * from ipl_match;
select * from ipl_stadium;


#  number teams who won toss and match in that stadium / number of teams won in the particulater stadium 

select stadium_name, stadium_id,
((select count(*) from ipl_match m join ipl_match_schedule ms using (match_id)
where ms.stadium_id = s.stadium_id and toss_winner = match_winner)/
(select count(*) from ipl_match_schedule ms where ms.stadium_id = s.stadium_id))* 100 
as percent_of_wins_by_teams_who_won_toss
from ipl_stadium s ;



# Q4 Show the total bids along with the bid team and team name.

select bd.bid_team, it.team_name , count(bd.bidder_id)over() as total_bids
from ipl_bidding_details bd join ipl_team it
on it.team_id = bd.bid_team
group by bd.bid_team
;


# Q5 Show the team id who won the match as per the win details.

with temp as
(select *,if(MATCH_WINNER = '1', team_id1, team_id2) as match_win
from ipl_match)
select it.team_id,team_name, win_details, match_id from ipl_team it join temp
on it.team_id = temp.match_win;


# Q6 Display total matches played, total matches won and total matches lost by the team along with its team name.

select * from ipl_team_standings;
select * from ipl_team;

select it.team_id, it.team_name, sum(its.matches_played) total_matches_playes, sum(its.matches_won) total_matchces_won,
sum(its.matches_lost) total_matches_lost
from ipl_team it join ipl_team_standings its using (team_id)
group by team_name;


#Q7 Display the bowlers for the Mumbai Indians team.

select * from ipl_player;
select * from ipl_team_players;
select * from ipl_team;

with temp as 
(select player_id, player_role,team_id from ipl_team_players where player_role = 'Bowler' and team_id =5)
select ip.player_id, ip.player_name, player_role, it.team_name, it.team_id from ipl_player ip join temp
using (player_id)
join ipl_team it 
using (team_id);

select * from ipl_team_players;
#Q8 How many all-rounders are there in each team, Display the teams with more than 4 
# all-rounders in descending order.

with temp as
(select team_id,player_role, count(team_id) as no_all_rounders from ipl_team_players where player_role = 'All-Rounder'
group by team_id)
 select team_id,team_name, no_all_rounders from temp t join ipl_team it 
 using (team_id)
 where no_all_rounders >4 order by no_all_rounders desc;
 
 
 # Q9  Write a query to get the total bidders points for each bidding status of those 
 # bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
 # Note the total bidders’ points in descending order and the year is bidding year.
 # Display columns: bidding status, bid date as year, total bidder’s points


select ibd.bid_status, year(ibd.Bid_date), ibp.total_points 
from ipl_bidding_details ibd 
join ipl_match_schedule ims using (schedule_id) 
join ipl_bidder_points ibp using (bidder_id)
join ipl_match im using (match_id)
where bid_team = 1 and im.win_details like '%CSK won%' and stadium_id = 7 
order by TOTAL_POINTS desc;


# 10 Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
# Note 
# 1. use the performance_dtls column from ipl_player to get the total number of wickets
# 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
# Do not use joins in any cases.
# Display the following columns teamn_name, player_name, and player_role.

 select * from ipl_team_players;
select * from ipl_player;
select * from ipl_team;

select * from 
(select *, dense_rank()over(order by total_wickets desc)rnk from
(select ip.player_id, ip.player_name, itp.player_role,it.team_name, 
cast(substr(performance_dtls, position('W' in performance_dtls)+4,2)as unsigned) as total_wickets 
from ipl_player ip join ipl_team_players itp using (player_id)
join ipl_team it using (team_id)
where player_role in ('Bowler','All-Rounder')) t)t1
having rnk <= 5
;





# Q11  Show the percentage of toss wins of each bidder and display the results in descending order based on the percentage

select * from ipl_bidder_points;
select * from ipl_bidding_details;
 
	 select ibp.bidder_id,ibd.bid_status, ibp.no_of_bids, (count(bid_status)/no_of_bids)*100 as Percent_Toss_win
	 from ipl_bidder_points ibp join ipl_bidding_details ibd using (bidder_id)
	 where BID_STATUS = 'won'
	 group by bidder_id
	 order by Percent_Toss_win desc;
     
 
# Q12 Find the IPL season which has min duration and max duration.
# Output columns should be like the below:
# Tournment_ID, Tourment_name, Duration column, Duration
 
select * from 
(select tournmt_id, tournmt_name, datediff(TO_DATE, FROM_DATE) Duration,"max" as "min/max" from ipl_tournament)t
where duration in (select max(datediff(TO_DATE, FROM_DATE)) from ipl_tournament) union
select * from 
(select tournmt_id, tournmt_name, datediff(TO_DATE, FROM_DATE) Duration ,"min"from ipl_tournament)t
where duration in (select min(datediff(TO_DATE, FROM_DATE)) from ipl_tournament);


# Q13 Write a query to display to calculate the total points month-wise for the 2017 bid year. 
# sort the results based on total points in descending order and month-wise in ascending order.
# Note: Display the following columns:
# Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
# Only use joins for the above query queries.

select bidder_name,temp.* from ipl_bidder_details join 
(select bidder_id ,month(bid_date) month,year(bid_date) year,count(*)*2 as tot_points from ipl_bidding_details where year(bid_date) = 2017 and bid_status = "won"
group by bidder_id,month(bid_date))temp using(bidder_id)
order by tot_points desc,month;



# Q14 Write a query for the above question using sub queries by having the same constraints as the above question.


select (select bidder_name from ipl_bidder_details ipd where ipd.bidder_id = ipl.bidder_id) bidder_name, bidder_id ,month(bid_date) month,year(bid_date) year,
count(*)*2 as tot_points 
from ipl_bidding_details ipl where year(bid_date) = 2017 and bid_status = "won"
group by bidder_id,month(bid_date)
order by tot_points desc,month;


#Q15 Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
# Output columns should be:
# like:
# Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;

# Highest_3_Bidders

select t3.BIDDER_ID, t3.BIDDER_NAME as Highest_3_Bidders, TOTAL_POINTS from
(select t2.*, dense_rank()over(order by t2.TOTAL_POINTS desc) ranks from
(select t1.*,total_points from ipl_bidder_points b,(
select a.bidder_id,t.bidder_name, year(a.bid_date) years, month(a.bid_date) months from ipl_bidding_details a,(select bidder_id,bidder_name from ipl_bidder_details)t
where a.bidder_id = t.BIDDER_ID)t1
where b.bidder_id = t1.BIDDER_ID
group by bidder_id, bidder_name, years, months
order by TOTAL_POINTS desc, months)t2
where years = 2018)t3
where ranks in (1,2,3)
group by Bidder_id;


# Lowest_3_bidder

select t3.BIDDER_ID, t3.BIDDER_NAME as lowest_3_Bidders, TOTAL_POINTS from
(select t2.*, dense_rank()over(order by t2.TOTAL_POINTS ) ranks from
(select t1.*,total_points from ipl_bidder_points b,(
select a.bidder_id,t.bidder_name, year(a.bid_date) years, month(a.bid_date) months from ipl_bidding_details a,(select bidder_id,bidder_name from ipl_bidder_details)t
where a.bidder_id = t.BIDDER_ID)t1
where b.bidder_id = t1.BIDDER_ID
group by bidder_id, bidder_name, years, months
order by TOTAL_POINTS desc, months)t2
where years = 2018)t3
where ranks in (1,2,3)
group by Bidder_id;




#Q16 Create two tables called Student_details and Student_details_backup.

create table student_details
(Student_id int primary key,
Student_name varchar(20),
email_id unique,
Mobile_no unique
);





