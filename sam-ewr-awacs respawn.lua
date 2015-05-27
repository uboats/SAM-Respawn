-- This is a lua script managing the SAM/EWR/AWACS delayed respawn once being destroyed with unlimited times
-- All the units must be active/activated from the beginning
-- by uboats Feb. 7, 2015


-- ** for SAM, complete components are required (SR, TR, STR, LN, etc..)
-- ** for SAM, optional: for each SAM site, a trigger zone can be set to cover the SAM site and its name must be same as SAM's group name. Then SAM will respawn at a random location inside that zone. Otherwise, at its original location

-- RespawnAWACS() does NOT work properly, under investigation

------------ USER CONFIG -------------

local SAM_Respawn_Delay = 1200
local EWR_Respawn_Delay = 600
local AWACS_Respawn_Delay = 600

------------ NON-CONFIG PART BELOW -------------

local SAMgroup = {}
local EWRgroup = {}
local AWACSgroup = {}


function getEWRgroup(info)
  local EWRtable = {'[all][vehicle]'}
  local EWRstart = mist.makeUnitTable(EWRtable)

  for i = 1, #EWRstart do
    if Unit.getByName(EWRstart[i]) ~= nil then
      local possibleunit     = Unit.getByName(EWRstart[i])
      local possibleunittype = Unit.getTypeName(possibleunit)
      
      if possibleunittype == "55G6 EWR" or possibleunittype == "1L13 EWR" then
        local EWRgrp   = Unit.getGroup(possibleunit)
        local EWRgname = Group.getName(EWRgrp)
        local EWRgsize = Group.getSize(EWRgrp)
        
        EWRgroup[#EWRgroup + 1] =
        {
          name = EWRgname,
          size = EWRgsize
        }
      end
    end
  end

  -- local msg = 'Total '..tostring(samcnt)..' EWR'
  -- trigger.action.outText(msg,5)
  
end


function getAWACSgroup(info)
  local AWACStable = {'[all][plane]'}
  local AWACSstart = mist.makeUnitTable(AWACStable)

  for i = 1, #AWACSstart do
    if Unit.getByName(AWACSstart[i]) ~= nil then
      local possibleunit     = Unit.getByName(AWACSstart[i])
      local possibleunittype = Unit.getTypeName(possibleunit)
      
      if possibleunittype == "A-50" or possibleunittype == "E-2D" or possibleunittype == "E-2C" or possibleunittype == "E-3A" then
        local AWACSgrp   = Unit.getGroup(possibleunit)
        local AWACSgname = Group.getName(AWACSgrp)
        local AWACSgsize = Group.getSize(AWACSgrp)
        
        AWACSgroup[#AWACSgroup + 1] =
        {
          name = AWACSgname,
          size = AWACSgsize
        }
      end
    end
  end

  --local msg = 'Total '..tostring(#AWACSgroup)..' AWACS'
  --trigger.action.outText(msg,5)  
  
end


function getSAMgroup(info)
  local SAMtable = {'[all][vehicle]'}
  local SAMstart = mist.makeUnitTable(SAMtable)

  for i = 1, #SAMstart do
    if Unit.getByName(SAMstart[i]) ~= nil then
      local possibleunit     = Unit.getByName(SAMstart[i])
      local possibleunittype = Unit.getTypeName(possibleunit)
      
      if possibleunittype == "Hawk sr" or possibleunittype == "Patriot str" or possibleunittype == "Kub 1S91 str" or possibleunittype == "S-300PS 40B6MD sr" or possibleunittype == "SA-11 Buk SR 9S18M1"
      then -- should add S-300, kub etc
        local SAMgrp   = Unit.getGroup(possibleunit)
        local SAMgname = Group.getName(SAMgrp)
        local SAMgsize = Group.getSize(SAMgrp)
        
        SAMgroup[#SAMgroup + 1] =
        {
          name = SAMgname,
          size = SAMgsize
        }
      end
    end
  end

  -- local msg = 'Total '..tostring(#SAMgroup)..' SAM'
  -- trigger.action.outText(msg,5)
  
end

function getAllgroup(info)
  getSAMgroup(info)
  getEWRgroup(info)
  --getAWACSgroup(info)

  --local totnum = #SAMgroup + #AWACSgroup + #EWRgroup
  --local msg = 'Respawn: '..tostring(#SAMgroup)..', '..tostring(#EWRgroup)
  --trigger.action.outText(msg,3)
  
end

-- one time job: store all units info
mist.scheduleFunction(getAllgroup, {'test'}, timer.getTime() + 5)


-- check whether group has unit being destroyed
function checkGroup(gname, gsize)
  local gself = Group.getByName(gname)
  local tmpnum = Group.getSize(gself)
  
  if gself then
    if (tmpnum < gsize) then
      return true
    else
      return false
    end
  else 
    return false
  end

end


function RespawnSAM(info)
  for i = 1, #SAMgroup do
    local gname = SAMgroup[i].name
    local gsize = SAMgroup[i].size
        
    if checkGroup(gname,gsize) then
      --local msg = 'SAM: '..gname..' is destroyed'
      --trigger.action.outText(msg,3)
      
      trigger.action.deactivateGroup(Group.getByName(gname)) -- remove group
      
      tzone = trigger.misc.getZone(gname)
      
      if tzone == nil then
        mist.scheduleFunction(mist.respawnGroup, {gname}, timer.getTime() + SAM_Respawn_Delay) -- delayed respawn
      else
        mist.scheduleFunction(mist.respawnInZone, {gname,gname}, timer.getTime() + SAM_Respawn_Delay) -- delayed respawn
      end
    end
  end
  
end

function RespawnEWR(info)
  for i = 1, #EWRgroup do
    local gname = EWRgroup[i].name
    local gsize = EWRgroup[i].size
    
    -- TODO: check whether zone exists
    -- if not, use 'respawnGroup', otherwise 'respawnInZone'
    
    
    if checkGroup(gname,gsize) then
      --local msg = 'EWR: '..gname..' is destroyed'
      --trigger.action.outText(msg,3)
      
      trigger.action.deactivateGroup(Group.getByName(gname)) -- remove group
      
      mist.scheduleFunction(mist.respawnGroup, {gname}, timer.getTime() + EWR_Respawn_Delay) -- delayed respawn      
    end
  end
  
end

function RespawnAWACS(info)
  for i = 1, #AWACSgroup do
    local gname = AWACSgroup[i].name
    local gsize = AWACSgroup[i].size
    
    -- TODO: check whether zone exists
    -- if not, use 'respawnGroup', otherwise 'respawnInZone'
    
    
    if checkGroup(gname,gsize) then
      local msg = 'AWACS: '..gname..' is destroyed'
      trigger.action.outText(msg,3)
      
      trigger.action.deactivateGroup(Group.getByName(gname)) -- remove group
      
      mist.scheduleFunction(mist.respawnGroup, {gname,true}, timer.getTime() + AWACS_Respawn_Delay) -- delayed respawn
    end
  end
  
end

function getAllrespawn(info)
  --RespawnAWACS(info)
  RespawnEWR(info)
  RespawnSAM(info)

end

mist.scheduleFunction(getAllrespawn, {'test'}, timer.getTime() + 10, 3)

