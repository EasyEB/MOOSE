--- (AI) (SP) (MP) Tasking for Air to Ground Processes.
-- 
-- 1) @{#TASK_A2G} class, extends @{Task#TASK}
-- =================================================
-- The @{#TASK_A2G} class defines a CAS or BAI task of a @{Set} of Target Units, 
-- located at a Target Zone, based on the tasking capabilities defined in @{Task#TASK}.
-- The TASK_A2G is implemented using a @{Statemachine#FSM_TASK}, and has the following statuses:
-- 
--   * **None**: Start of the process
--   * **Planned**: The SEAD task is planned. Upon Planned, the sub-process @{Process_Fsm.Assign#ACT_ASSIGN_ACCEPT} is started to accept the task.
--   * **Assigned**: The SEAD task is assigned to a @{Group#GROUP}. Upon Assigned, the sub-process @{Process_Fsm.Route#ACT_ROUTE} is started to route the active Units in the Group to the attack zone.
--   * **Success**: The SEAD task is successfully completed. Upon Success, the sub-process @{Process_SEAD#PROCESS_SEAD} is started to follow-up successful SEADing of the targets assigned in the task.
--   * **Failed**: The SEAD task has failed. This will happen if the player exists the task early, without communicating a possible cancellation to HQ.
-- 
-- ===
-- 
-- ### Authors: FlightControl - Design and Programming
-- 
-- @module Task_A2G


do -- TASK_A2G

  --- The TASK_A2G class
  -- @type TASK_A2G
  -- @extends Tasking.Task#TASK
  TASK_A2G = {
    ClassName = "TASK_A2G",
  }
  
  --- Instantiates a new TASK_A2G.
  -- @param #TASK_A2G self
  -- @param Tasking.Mission#MISSION Mission
  -- @param Set#SET_GROUP SetGroup The set of groups for which the Task can be assigned.
  -- @param #string TaskName The name of the Task.
  -- @param #string TaskType BAI or CAS
  -- @param Set#SET_UNIT UnitSetTargets
  -- @param Core.Zone#ZONE_BASE TargetZone
  -- @return #TASK_A2G self
  function TASK_A2G:New( Mission, SetGroup, TaskName, TaskType, TargetSetUnit, TargetZone, FACUnit )
    local self = BASE:Inherit( self, TASK:New( Mission, SetGroup, TaskName, TaskType ) )
    self:F()
  
    self.TargetSetUnit = TargetSetUnit
    self.TargetZone = TargetZone
    self.FACUnit = FACUnit
    
    local A2GUnitProcess = self:GetUnitProcess()

    A2GUnitProcess:AddProcess   ( "Planned",    "Accept",   ACT_ASSIGN_ACCEPT:New( "Attack the Area" ), { Assigned = "Route", Rejected = "Eject" } )
    A2GUnitProcess:AddProcess   ( "Assigned",   "Route",    ACT_ROUTE_ZONE:New( self.TargetZone ), { Arrived = "Update" } )
    A2GUnitProcess:AddTransition( "Rejected",   "Eject",    "Planned" )
    A2GUnitProcess:AddTransition( "Arrived",    "Update",   "Updated" ) 
    A2GUnitProcess:AddProcess   ( "Updated",    "Account",  ACT_ACCOUNT_DEADS:New( self.TargetSetUnit, "Attack" ), { Accounted = "Success" } )
    A2GUnitProcess:AddProcess   ( "Updated",    "Smoke",    ACT_ASSIST_SMOKE_TARGETS_ZONE:New( self.TargetSetUnit, self.TargetZone ) )
    --Fsm:AddProcess ( "Updated",    "JTAC",     PROCESS_JTAC:New( self, TaskUnit, self.TargetSetUnit, self.FACUnit  ) )
    A2GUnitProcess:AddTransition( "Accounted",  "Success",  "Success" )
    A2GUnitProcess:AddTransition( "Failed",     "Fail",     "Failed" )
    
    function A2GUnitProcess:onenterUpdated( TaskUnit )
      self:E( { self } )
      self:Account()
      self:Smoke()
    end

    
    
    --_EVENTDISPATCHER:OnPlayerLeaveUnit( self._EventPlayerLeaveUnit, self )
    --_EVENTDISPATCHER:OnDead( self._EventDead, self )
    --_EVENTDISPATCHER:OnCrash( self._EventDead, self )
    --_EVENTDISPATCHER:OnPilotDead( self._EventDead, self )

    return self
  end
  
    --- @param #TASK_A2G self
  function TASK_A2G:GetPlannedMenuText()
    return self:GetStateString() .. " - " .. self:GetTaskName() .. " ( " .. self.TargetSetUnit:GetUnitTypesText() .. " )"
  end
  
  end



