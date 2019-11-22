#######################################################################
# Problem: Boston Sightseeing Optimization
# Description: This optimization problems aims at helping graduate students sightsee across Boston
# Authors : Abhilash Janardhanan, Shashank Shet, Pratik Nagare
# Version No: 19.11.3
########################################################################




# A set to contain the Homebase which serves as starting and ending point
set HOMEBASE;
# A set of places to be visited
set TRAVEL_PLACES;

set ALL_PLACES = HOMEBASE union TRAVEL_PLACES;


param Budget;
# Cost incurred for visiting each place
param Cost {ALL_PLACES} >= 0;

# Distance between pairs of places
param Distance {ALL_PLACES, ALL_PLACES};

# Hrs to spend in each place
param Duration{ALL_PLACES} ; 

# Factor to calculate time to drive there
param minMPH = 25;
# Adding a correction factor to account for traffic and non straight path from src to dest
param timeFactor = 1.75;
# Per mile cost to travel between src to dest
param costFactor = 0.5;

param hoursInADay = 10;

# Decision variable to denote whether we are at a given place at a given timeslot
var travel {ALL_PLACES, ALL_PLACES} binary;

var visited{ALL_PLACES} binary;

# Objective 1: Maximize total number of places visited
maximize TotalVisits :
	sum {src in ALL_PLACES, dst in ALL_PLACES}  travel[src, dst] ;


# Cannot travel to a place from itself
s.t. NoSelfLoop {place in ALL_PLACES}:
	travel[place, place] = 0;

# Total cost is within Budget
s.t. TotalCost : 
  sum {src in ALL_PLACES, dst in ALL_PLACES}
      (Cost[src] + costFactor*timeFactor*Distance[src, dst]) * travel[src,dst] <= Budget;


# Can each place you visit you must leave
s.t. InDegreeOutDegreeMatch {place in ALL_PLACES}:
	sum {dst in ALL_PLACES} travel[place, dst] = sum {src in ALL_PLACES} travel[src, place];
     
# Can only visit a place once
s.t. PlaceSingularity {src in ALL_PLACES}:
  sum {dst in ALL_PLACES} travel[src,dst] <= 1 ;
  
# Time Spent is within hours allowed
s.t. TimeSpent:
	sum {src in ALL_PLACES, dst in ALL_PLACES} 
	travel[src, dst] * (Duration[src] + Distance[src, dst]*timeFactor/minMPH ) <= hoursInADay;
	
# First place and last place should be homebase

s.t. StartAtHomebase {hb in HOMEBASE}:
	sum {place in ALL_PLACES} travel[hb, place] = 1;

s.t. EndAtHomebase {hb in HOMEBASE}:
	sum {place in ALL_PLACES} travel[place, hb] = 1;
	 
# Cannot go back to the same place 
s.t. ReturnSingularity {src in ALL_PLACES, dst in ALL_PLACES}:
		travel[src,dst] + travel[dst, src] <= 1 ;
	
	
	
s.t. VisitFLag {place in ALL_PLACES}:
	 visited[place] = sum {dest in ALL_PLACES } travel[place, dest] ; 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	