/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost >0;

-- Tennis court 1 and 2, massage room 1 and 2, and squash court charge a fee to members

/* Q2: How many facilities do not charge a fee to members? */

SELECT name
FROM Facilities
WHERE membercost =0;

-- 4 facilities do not charge a fee to members

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < ( 0.20 * monthlymaintenance )
AND membercost > 0;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid
IN ( 1, 5 );

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance >100
THEN 'expensive'
ELSE 'cheap'
END AS costtype
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname, MAX( joindate )
FROM Members
WHERE firstname NOT LIKE 'GUEST'
AND surname NOT LIKE 'GUEST'

--Darren Smith at 2012-09-26

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name, CONCAT(m.firstname, ' ', m.surname) AS fullname
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE f.facid IN (0,1) AND m.firstname NOT LIKE 'GUEST'
ORDER BY fullname;

--m.firstname || ' ' || m.surname AS fullname is the code for concating in sqllite that works
/*I don't have the permissions to use concat but I'm pretty sure this is how you
get the first and last name into one column with the fullname*/
--The following is the code I ran because I didn't have permission to use concat

SELECT DISTINCT f.name, m.firstname, m.surname
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE f.facid IN (0,1) AND m.firstname NOT LIKE 'GUEST'
ORDER BY m.firstname, m.surname;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name,m.firstname, m.surname,
	CASE WHEN b.memid = 0 THEN (b.slots * f.guestcost)
		ELSE b.slots * f.membercost END AS cost
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
INNER JOIN Facilities AS f ON b.facid = f.facid 
WHERE ((b.slots * f.membercost > 30 AND b.memid !=0) OR (b.slots * f.guestcost > 30 AND b.memid =0)) AND b.starttime LIKE '2012-09-14%'
ORDER BY cost DESC;

--Above is the code I used. Again I would've used "CONCAT(m.firstname, ' ', m.surname) AS fullname" if I had the permission to use it.
--List returned is all guests except Jemima Farrell in the massage room 1

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.name, m.firstname, m.surname, sub.cost
FROM Members AS m
INNER JOIN (
    SELECT b.memid, f.name,
        CASE WHEN b.memid =0
            THEN (b.slots * f.guestcost)
        ELSE b.slots * f.membercost END AS cost
    FROM Bookings b
    INNER JOIN Facilities f ON b.facid = f.facid
    WHERE ((b.slots * f.membercost >30
        AND b.memid !=0)
        OR (b.slots * f.guestcost >30
        AND b.memid =0))
        AND b.starttime LIKE '2012-09-14%'
    ) AS sub ON m.memid = sub.memid
ORDER BY sub.cost DESC 


/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT f.name,
	SUM(CASE WHEN b.memid = 0 THEN (b.slots * f.guestcost)
		ELSE b.slots * f.membercost END) AS total_revenue
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
INNER JOIN Facilities AS f ON b.facid = f.facid 
GROUP BY f.name
Having total_revenue < 1000
ORDER BY total_revenue;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT DISTINCT m1.surname, m1.firstname,
	CASE WHEN recommendedby LIKE ''
			THEN 'No recommender'
		 ELSE (SELECT m2.firstname || ' ' || m2.surname
               FROM Members AS m2
               WHERE m1.recommendedby = m2.memid) END AS recommender
FROM Members AS m1
WHERE firstname NOT LIKE 'GUEST'
ORDER BY surname, firstname;

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name AS facility_name, m.memid AS member_id,
	m.firstname, m.surname, COUNT(b.memid) AS usage_count
FROM Members AS m
INNER JOIN Bookings AS b ON m.memid = b.memid
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY f.name, m.memid
ORDER BY m.surname, m.firstname, usage_count DESC;

/* Q13: Find the facilities usage by month, but not guests */

WITH b AS(
SELECT memid, facid,
	CASE WHEN starttime LIKE '2012-09%'
			THEN 'September'
		 WHEN starttime LIKE '2012-08%'
			THEN 'August'
		 ELSE 'July' END AS month
FROM Bookings)
SELECT f.name AS facility_name, b.month, COUNT(*) AS month_usage
FROM Members AS m
INNER JOIN b ON m.memid=b.memid
INNER JOIN Facilities AS f ON b.facid=f.facid
WHERE m.memid != 0
GROUP BY f.name, b.month
ORDER BY f.name, b.month

--Used a cte, but could've done it without it too

