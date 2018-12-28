/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
select name from facilities where membercost <> 0

Tennis Court 1 
Tennis Court 2 
Massage Room 1 
Massage Room 2 
Squash Court 

/* Q2: How many facilities do not charge a fee to members? */
select count(*) from facilites where membercost = 0
4

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select facid, name, membercost, monthlymaintenance from Facilities where (membercost < (monthlymaintenance*.2)) and membercost > 0

facid	name			membercost	monthlymaintenance
0		Tennis Court 1	5.0			200
1		Tennis Court 2	5.0			200
4		Massage Room 1	9.9			3000
5		Massage Room 2	9.9			3000
6		Squash Court	3.5			80

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select * from Facilities wher facid in(1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance, case when monthlymaintenance > 100 then 'cheap' else 'expensive' end as label from Facilities 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select max(joindate), firstname, surname from Members 

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name, concat( m.firstname, ' ', m.surname ) AS member_name
FROM Members m, Facilities f, Bookings b
WHERE (
f.facid = b.facid
)
AND (
b.memid = m.memid
)
AND f.name LIKE 'tennis%'
order by member_name


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

Select f.name, 'GUEST' as name, (f.guestcost * b.slots) as cost 
from Bookings b, Members m, Facilities f 
where b.memid = m.memid 
and b.facid = f.facid 
and (f.guestcost * b.slots) > 30 
and b.starttime LIKE '2012-09-14%' 
and b.memid = 0
union
select f.name, concat(m.firstname, ' ', m.surname) as name, (f.membercost * b.slots) as cost 
from Bookings b, Members m, Facilities f 
where b.memid = m.memid 
and b.facid = f.facid 
and (f.membercost * b.slots) > 30 
and b.starttime LIKE '2012-09-14%' 
and b.memid <> 0
order by cost desc

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select * from (
	select f.name, case when b.memid <> 0 then concat(m.firstname, ' ', m.surname) else 'GUEST' end as booking_name, case when b.memid <> 0 then f.membercost * b.slots else f.guestcost * b.slots end as cost
	from Bookings b, Members m, Facilities f
	where b.memid = m.memid 
	and b.facid = f.facid 
	and b.starttime LIKE '2012-09-14%' )
as x
where x.cost > 30
order by cost desc

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select * from (
	select f.name, sum((case when b.memid <> 0 then f.membercost * b.slots else f.guestcost * b.slots end)) as total_revenue 
	from Bookings b, Facilities f 
	where b.facid = f.facid 
	group by f.facid 
	order by total_revenue asc) 
as x 
where x.total_revenue < 1000