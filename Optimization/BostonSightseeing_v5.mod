#######################################################################
# Problem: Boston Sightseeing Optimization
# Description: This optimization problems aims at helping graduate students sightsee across Boston
# Authors : Abhilash Janardhanan, Shashank Shet, Pratik Nagare
# Version No: 19.11.4
# Added two sets as dummies for Start and end point
# Added Timevalue variable that holds the time value
########################################################################


# A Dummy variable to make Homebase the starting point
set HOMEBASE_START;
# A set of places to be visited apart from homebase
set TRAVEL_PLACES;
# A dummy variable to make Homebase the ending point
set HOMEBASE_END;

param NumberOfDays >= 1 integer;

set DAYS = 1 .. NumberOfDays by 1;

# Master set of all places
set ALL_PLACES = HOMEBASE_START union TRAVEL_PLACES union HOMEBASE_END;

set STARTING_PAIRS = HOMEBASE_START cross TRAVEL_PLACES;
set ENDING_PAIRS = TRAVEL_PLACES cross HOMEBASE_END;
set INTERMEDIATE_PAIRS = { (src, dst) in  TRAVEL_PLACES cross TRAVEL_PLACES : src <> dst } ;


# Set of all valid pairs
set ALL_VALID_PAIRS = STARTING_PAIRS union 
					    INTERMEDIATE_PAIRS union 
					       ENDING_PAIRS union 
					       (HOMEBASE_START cross HOMEBASE_END)
;

set INVALID_PATHS = (ALL_PLACES cross ALL_PLACES ) diff ALL_VALID_PAIRS ;

param Budget;
# Cost incurred for visiting each place
param Cost {ALL_PLACES} >= 0;

# Distance between pairs of places
param Distance {ALL_PLACES, ALL_PLACES} >= 0;

# Hrs to spend in each place
param Duration{ALL_PLACES} >= 0; 

# Factor to calculate time to drive there
param minMPH = 25;

# Adding a correction factor to account for traffic and non straight path from src to dest
param timeFactor = 1.75;

# 25 MPG From https://en.wikipedia.org/wiki/Fuel_economy_in_automobiles#United_States
param milesPerGallon >= 0; 

# 2.86 USD for mid-grade gasoline from https://gasprices.aaa.com/state-gas-price-averages/ 
param costPerGallon >= 0;

# Per mile cost to travel between src to dest
param costFactor =  costPerGallon/ milesPerGallon ;

param hoursInADay;

# Decision variable to denote whether we are at a given place at a given timeslot
var travel {ALL_PLACES, ALL_PLACES, DAYS} binary;

# var visited{ALL_PLACES} binary;

# Variable to hold the time spent from beginning of trip and ensure that no loops exists in solution
var Timevalue {p in ALL_PLACES, d in DAYS} >= 0 , <= hoursInADay, ;

# Objective 1: Maximize total number of places visited

maximize TotalVisits :
	sum {src in ALL_PLACES, dst in ALL_PLACES, day in DAYS}  travel[src, dst, day] 
	;

/*
minimize VisitsByDistance:
	sum { (i,j,d) in ALL_VALID_PAIRS cross DAYS } Distance[i,j]*travel[i,j,d];
*/

# Cannot travel to a place from itself
s.t. NoSelfLoop {place in ALL_PLACES, day in DAYS}:
	travel[place, place, day] = 0;

# Total cost is within Budget
s.t. TotalCost : 
  sum {src in ALL_PLACES, dst in ALL_PLACES, day in DAYS}
      (Cost[src] + costFactor*timeFactor*Distance[src, dst]) * travel[src,dst, day] <= Budget;


# Can each place you visit you must leave
s.t. InDegreeOutDegreeMatch {place in TRAVEL_PLACES, day in DAYS}:
	sum {dst in ALL_PLACES} travel[place, dst, day] = sum {src in ALL_PLACES} travel[src, place, day];

	
s.t. NoInvalidPaths { (src,dst) in INVALID_PATHS, day in DAYS } :
	travel[src, dst, day] = 0;

     
# Can only visit a place once
s.t. PlaceSingularity {src in TRAVEL_PLACES}:
  sum {dst in ALL_PLACES, day in DAYS} travel[src,dst, day] <= 1 ;
  
# Time Spent is within hours allowed
s.t. TimeSpent {day in DAYS} :
	sum {src in ALL_PLACES, dst in ALL_PLACES} 
	travel[src, dst, day] * (Duration[src] + Distance[src, dst]*timeFactor/minMPH ) <= hoursInADay;

# Time Continuity Constraint
s.t. Timevalue_dest {dst in TRAVEL_PLACES union HOMEBASE_END, day in DAYS}:
	Timevalue[dst, day] >= sum {src in ALL_PLACES} (
	( Timevalue[src, day] + Duration[src] +  
		Distance[src, dst]*timeFactor/minMPH)*travel[src, dst, day]);

# Fails at activating this
/*
s.t. Timevalue_src {src in ALL_PLACES}:
	Timevalue[src] <= sum {dst in TRAVEL_PLACES union HOMEBASE_END} (( Timevalue[dst] - Duration[src])*travel[src, dst]);
*/
	
# s.t. Timevalue_dest {dst in TRAVEL_PLACES union HOMEBASE_END}:
#	Timevalue[dst] >= sum {src in ALL_PLACES} ( Timevalue[src] + travel[src, dst] * (Duration[src] + Distance[src, dst]*timeFactor/minMPH ));
/*
s.t. Timevalue_dest_smaller {dst in TRAVEL_PLACES union HOMEBASE_END}:
	Timevalue[dst] >= sum {src in ALL_PLACES} ( Timevalue[src]*travel[src, dst] + Duration[dst]);
*/
	
# First place and last place should be homebase

s.t. StartAtHomebase {hb in HOMEBASE_START, day in DAYS}:
	sum {place in TRAVEL_PLACES union HOMEBASE_END} travel[hb, place, day] = 1;

s.t. EndAtHomebase {hb in HOMEBASE_END, day in DAYS}:
	sum {place in TRAVEL_PLACES union HOMEBASE_START} travel[place, hb, day] = 1;

/*
s.t. NoEnteringHomebaseStart {hb in HOMEBASE_START, day in DAYS}:
	sum {place in TRAVEL_PLACES} travel[place,hb, day] = 0;
	
s.t. NoExitingHomebaseEnd {hb in HOMEBASE_END, day in DAYS}:
	sum {place in TRAVEL_PLACES} travel[hb, place, day] = 0;
	*/ 
# Cannot go back to the same place 
s.t. ReturnSingularity {src in ALL_PLACES, dst in ALL_PLACES}:
		sum {day in DAYS} (travel[src,dst, day] + travel[dst, src, day]) <= 1 ;

/*
s.t. StartTofinishAvoid {p in TRAVEL_PLACES} :
	sum {hbs in HOMEBASE_START, hbe in HOMEBASE_END} (travel[hbs, p] + travel[p, hbe] )<= 1;	
*/	
	
# s.t. VisitFLag {place in ALL_PLACES}:
# 	 visited[place] = sum {dest in ALL_PLACES } travel[place, dest] ; 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	