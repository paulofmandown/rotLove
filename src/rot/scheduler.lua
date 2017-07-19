--- The Scheduler Prototype
-- @module ROT.Scheduler
local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Scheduler = ROT.Class:extend("Scheduler")

function Scheduler:init()
    self._queue=ROT.EventQueue:new()
    self._repeat ={}
    self._current=nil
end

--- Get Time.
-- Get time counted since start
-- @treturn int elapsed time
function Scheduler:getTime()
    return self._queue:getTime()
end

--- Add.
-- Add an item to the schedule
-- @tparam any item
-- @tparam boolean repeating If true, this item will be rescheduled once it is returned by .next()
-- @treturn ROT.Scheduler self
function Scheduler:add(item, repeating)
    if repeating then table.insert(self._repeat, item) end
    return self
end

--- Get scheduled time.
-- Get the time the given item is scheduled for
-- @tparam any item
-- @treturn number time
function Scheduler:getTimeOf(item)
    return self._queue:getEventTime(item)
end

--- Clear.
-- Remove all items from scheduler
-- @treturn ROT.Scheduler self
function Scheduler:clear()
    self._queue:clear()
    self._repeat={}
    self._current=nil
    return self
end

--- Remove.
-- Find and remove an item from the scheduler
-- @tparam any item The previously added item to be removed
-- @treturn boolean true if an item was removed from the scheduler
function Scheduler:remove(item)
    local result=self._queue:remove(item)
    local index=table.indexOf(self._repeat, item)
    if index~=0 then table.remove(self._repeat, index) end
    if self._current==item then self._current=nil end
    return result
end

--- Next.
-- Get the next event from the scheduler and advance the appropriate amount time
-- @treturn event|nil The event previously added by .add() or nil if none are queued
function Scheduler:next()
    self._current=self._queue:get()
    return self._current
end

return Scheduler
