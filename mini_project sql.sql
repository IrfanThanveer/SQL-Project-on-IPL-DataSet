# 1.Show the percentage of wins of each bidder in the order of highest to lowest percentage.

select ibp.bidder_id, no_of_bids,bid_won, (bid_won/no_of_bids)*100 per_of_wins from ipl_bidder_points ibp join
(select bidder_id, count(*) as bid_won from ipl_bidding_details ibd where bid_status = "won"
group by bidder_id)t
on ibp.bidder_id = t.bidder_id
order by per_of_wins desc;


# 2.Display the number of matches conducted at each stadium with the stadium name and city.

select * from ipl_stadium;
select * from ipl_match_schedule;
select stadium_name, city,no_of_matchs from ipl_stadium iss join
(select stadium_id,count(stadium_id) no_of_matchs from ipl_match_schedule
group by stadium_id)t
on t.stadium_id = iss.stadium_id;


# 3.In a given stadium, what is the percentage of wins by a team which has won the toss?

select STADIUM_NAME,(win_toss_winner/tot_match)*100 pct_toss_winner from 
(select *,count(match_id) over(partition by stadium_name) win_toss_winner from
(select ip.*,ipm.STADIUM_NAME,count(ip.match_id) over(partition by ipm.STADIUM_NAME) tot_match
from ipl_match ip join ipl_match_schedule ips on ip.match_id = ips.match_id join ipl_stadium ipm 
on ips.STADIUM_ID = ipm.STADIUM_ID)temp where toss_winner = match_winner)temp2 group by STADIUM_NAME;

# 4.Show the total bids along with the bid team and team name.

select * from ipl_bidder_details;
select * from ipl_bidding_details;
select * from ipl_bidder_points;
select * from ipl_team;

select Bid_team, Team_name, sum(no_of_bids) as Total_bids from ipl_team a join ipl_bidding_details b
on a.team_id = b.bid_team
join ipl_bidder_points c
on b.bidder_id = c.bidder_id
group by bid_team, team_name
order by bid_team;


# 5.Show the team id who won the match as per the win details.
select win_Details,if(match_winner=1,team_id1,team_id2) win from ipl_match;

# 6.Display total matches played, total matches won and total matches lost by the team along with its team name.

select * from ipl_team_standings;
select * from ipl_team;
select a.team_id, b.team_name, sum(matches_played) 'total matches played' , sum(matches_won) 'total matches won', sum(matches_lost) 'total matches lost' 
from ipl_team_standings a join ipl_team b
using(team_id)
group by a.team_id;

select team_name,tot_match,match_won,(tot_match-match_won) match_lost from
(select *,count(match_id) over(partition by team_id1) match_won from  
(select *,count(match_id) over(partition by team_id1) tot_match from ipl_match) team
 where match_winner=1)temp1 join ipl_team on team_id1 = team_id 
 group by team_id1;
 
# 7.Display the bowlers for the Mumbai Indians team.

select * from ipl_team_players;
select * from ipl_player;
select a.player_id, b.Player_name, a.remarks from ipl_team_players a join ipl_player b on a.player_id = b.player_id
where a.player_role = 'bowler' and a.remarks like '%mi%';

# 8.How many all-rounders are there in each team, Display the teams with more than 4 
# all-rounders in descending order.

select * from ipl_team_players;
select remarks as team_name , all_rounders from
(select remarks,count(player_role) All_Rounders from ipl_team_players
where player_role = 'All-Rounder'
group by remarks)t
where All_Rounders > 4;

# 9.
# Write a query to get the total bidders points for each bidding status of those bidders !!!!!!!!!!!!!!!!!!!!!!!!!!!!
# who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
# Note the total bidders’ points in descending order and the year is bidding year.
# Display columns: bidding status, bid date as year, total bidder’s points
select ipd.bid_status,year(ipd.bid_date) year,ips.total_points from ipl_bidding_details ipd join ipl_bidder_points ips using(bidder_id)
join ipl_match_schedule ipm using(schedule_id) join ipl_match using(match_id) where
MATCH_WINNER = (select team_id from ipl_team where team_name  = "Chennai Super Kings") and
bid_team = (select team_id from ipl_team where team_name  = "Chennai Super Kings") and
STADIUM_ID = (select STADIUM_ID from ipl_stadium where stadium_name = "M. Chinnaswamy Stadium") order by TOTAL_POINTS desc

select ipd.bid_status,year(ipd.bid_date) year,if(total_points is null,count(bid_status = "won")*2,total_points) tot_points from ipl_bidding_details ipd left join ipl_bidder_points ips on ipd.bidder_id = ips.bidder_id
 and year(bid_date)=tournmt_id join ipl_match_schedule ipm using(schedule_id) join ipl_match using(match_id) where
MATCH_WINNER = (select team_id from ipl_team where team_name  = "Chennai Super Kings")  and
bid_team = (select team_id from ipl_team where team_name  = "Chennai Super Kings")   and
STADIUM_ID = (select STADIUM_ID from ipl_stadium where stadium_name = "M. Chinnaswamy Stadium") 
group by ipd.bidder_id
order by TOTAL_POINTS desc;

# 10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
# Note 
#	1.use the performance_dtls column from ipl_player to get the total number of wickets
#	2.Do not use the limit method because it might not give appropriate results when players have the same number of wickets
#	3.Do not use joins in any cases.
#	4.Display the following columns teamn_name, player_name, and player_role.

select player_name,wkts,(select remarks from ipl_team_players ip where temp.player_id = ip.player_id) team_name,
(select player_role from ipl_team_players ip where temp.player_id = ip.player_id) roles from
(select *,dense_rank() over(order by wkts desc) rnk from 
(select *,cast(substring(substring(performance_dtls,instr(performance_dtls,"wkt"),6),
instr(substring(performance_dtls,instr(performance_dtls,"wkt"),6),"-")+1,2) as float) wkts
from ipl_player)temp where player_id in 
(select player_id from ipl_team_players where player_role in ("all-rounder","bowler"))) temp 
where rnk<=5;

# 11.show the percentage of toss wins of each bidder and display the results in descending order based on the percentage

select bidder_id,(toss_count/tot_count)*100 as pct from 
(select *,count(*) over(partition by BIDDER_ID) toss_count from
(select *,count(*) over(partition by BIDDER_ID) tot_count from(
select bidder_id,bid_status,ipl.SCHEDULE_ID,match_date,bid_date,toss_id,bid_team from ipl_bidding_details ipl join
(select SCHEDULE_ID,match_date,if (toss_winner = 1,team_id1,team_id2) toss_id from ipl_match ip join ipl_match_schedule ips 
on ip.MATCH_ID = ips.MATCH_ID) temp on ipl.SCHEDULE_ID=temp.SCHEDULE_ID) temp2)temp3 where toss_id = BID_TEAM)temp4
group by BIDDER_ID order by pct desc;


#12.find the IPL season which has min duration and max duration.
#Output columns should be like the below:
#Tournment_ID, Tourment_name, Duration column, Duration
select * from 
(select tournmt_id, tournmt_name, datediff(TO_DATE, FROM_DATE) Duration,"max" as "min/max" from ipl_tournament)t
where duration in (select max(datediff(TO_DATE, FROM_DATE)) from ipl_tournament) union
select * from 
(select tournmt_id, tournmt_name, datediff(TO_DATE, FROM_DATE) Duration ,"min"from ipl_tournament)t
where duration in (select min(datediff(TO_DATE, FROM_DATE)) from ipl_tournament);
#13.Write a query to display to calculate the total points month-wise for the 2017 bid year. 
#sort the results based on total points in descending order and month-wise in ascending order.
#Note: Display the following columns:
#1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
#Only use joins for the above query queries.
select bidder_name,temp.* from ipl_bidder_details join 
(select bidder_id ,month(bid_date) month,year(bid_date) year,count(*)*2 as tot_points from ipl_bidding_details where year(bid_date) = 2017 and bid_status = "won"
group by bidder_id,month(bid_date))temp using(bidder_id)
order by tot_points desc,month;

#14.Write a query for the above question using sub queries by having the same constraints as the above question.
select (select bidder_name from ipl_bidder_details ipd where ipd.bidder_id = ipl.bidder_id) bidder_name, bidder_id ,month(bid_date) month,year(bid_date) year,
count(*)*2 as tot_points 
from ipl_bidding_details ipl where year(bid_date) = 2017 and bid_status = "won"
group by bidder_id,month(bid_date)
order by tot_points desc,month;

#15.Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
#Output columns should be:
#like:
#Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;
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

#16.Create two tables called Student_details and Student_details_backup.
#Table 1: Attributes 		Table 2: Attributes
#Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.
#Feel free to add more columns the above one is just an example schema.
#Assume you are working in an Ed-tech company namely Great Learning where you will be inserting and modifying the details of the students in 
-- the Student details table. Every time the students changed their details like mobile number, You need to update their details in the student 
-- details table.  Here is one thing you should ensure whenever the new students' details come , you should also store them in the Student backup
--  table so that if you modify the details in the student details table, you will be having the old details safely.
#You need not insert the records separately into both tables rather Create a trigger in such a way that It should insert the details into the Student back table when you inserted the student details into the student table automatically.
create table Student_details
(
Student_id int,
Student_name varchar(20),
Mail_ID varchar(20),
Mobile_NO int
);
create table Student_details_backup
(
Student_id int,
Student_name varchar(20),
Mail_ID varchar(20),
Mobile_NO int
);
create trigger backups
before insert
on student_details
for each row
insert into Student_details_backup(Student_id,Student_name,Mail_ID,Mobile_NO) values 
(new.Student_id,new.Student_name,new.Mail_ID,new.Mobile_NO);

insert into Student_details values
(1,'Ravi','raviggmail',1234555);
select * from Student_details;
select * from Student_details_backup;

