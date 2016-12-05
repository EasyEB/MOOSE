
-- Find the UNIT to be moved ...
-- This UNIT is one unit from a larger GROUP ...
local UnitMove = UNIT:FindByName( "UnitMove" )

local UnitPoint = UnitMove:GetPointVec2():RoutePointGround( 5 )

-- Find the ZONE to move the unit to:

local ZoneMove = ZONE:New( "ZoneMove" )

local ZonePoint = POINT_VEC3:NewFromVec3( ZoneMove:GetVec3(0) ):RoutePointGround( 5 )

local Task = UnitMove:TaskRoute( { UnitPoint, ZonePoint } )

UnitMove:E(Task)

UnitMove:SetTask( Task, 1 )

