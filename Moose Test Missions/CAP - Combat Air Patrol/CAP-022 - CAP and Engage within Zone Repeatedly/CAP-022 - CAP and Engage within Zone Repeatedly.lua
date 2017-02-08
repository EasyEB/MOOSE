---
-- Name: CAP-022 - CAP and Engage within Zone Repeatedly
-- Author: FlightControl
-- Date Created: 16 January 2017
--
-- # Situation:
--
-- The Su-27 airplane will patrol in PatrolZone.
-- It will engage when it detects the airplane and when the C-101CC is within the CapEngageZone.
-- Every time a C-101CC is destroyed, a new C-101CC is routed to the engage zone.
-- The test is to observe the behaviour of the Su-27 plane, which should return to the patrol zone, after destroying the 
-- C-101CC, and once the C-101CC is within the patrol zone, it should engage.
-- 
--
-- # Test cases:
-- 
-- 1. Observe the Su-27 patrolling.
-- 2. Observe that, when the C-101CC is within the engage zone, it will engage.
-- 3. After engage, observe that the Su-27 returns to the PatrolZone.
-- 4. When a new C-101CC arrives in the engage zone, it should attack again.
-- 5. If you want, you can wait until the Su-27 is out of fuel and will land.

 

-- Find the Su-27 GROUP wrapper object by using the GROUP wrapper class FindByName that returns the object and stores it in the variable CapPlane.
local CapPlane = GROUP:FindByName( "Plane" )

-- Spawn repeatedly the Enemy plane (a C-101CC), maximum 1 live at the same time, check every 60 seconds if one needs to be spawned.
local SpawnEnemy = SPAWN:New( "Enemy" ):InitLimit( 1, 10 ):SpawnScheduled( 60, 0 )


-- Create a ZONE object that represents the trigger zone "Patrol Zone".
local PatrolZone = ZONE:New( "Patrol Zone" )

-- Create the AI_CAP_ZONE process and stores the AI_CAP_ZONE object reference in AICapZone
local AICapZone = AI_CAP_ZONE:New( PatrolZone, 500, 1000, 500, 600 )

-- Find the GROUP object that represents the "Engage Zone" polygon, by using the GROUP class FindByName method, 
-- and store the returned GROUP object in the variable EngageZoneGroup.
local EngageZoneGroup = GROUP:FindByName( "Engage Zone" )

-- Create a ZONE_POLYGON (polygon zone) from the EngageZoneGroup GROUP object, and store the reference of
-- the ZONE_POLYGON in the CapEngageZone.
local CapEngageZone = ZONE_POLYGON:New( "Engage Zone", EngageZoneGroup )

-- Attach the CapPlane to the AICapZone. Now the CapPlane will be goverened by the AICapZone process.
AICapZone:SetControllable( CapPlane )

-- Set the engage zone to CapEngageZone. This will make the CapPlane engage when an enemy is detected and within the CapEngageZone.
AICapZone:SetEngageZone( CapEngageZone ) -- Set the Engage Zone. The AI will only engage when the bogeys are within the CapEngageZone.

-- Start the AICapZone process. Starts kicks it off.
AICapZone:__Start( 1 ) -- They should statup, and start patrolling in the PatrolZone.

