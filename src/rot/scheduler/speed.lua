--- The Speed based scheduler
-- @module ROT.Scheduler.Speed
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Speed= ROT.Scheduler:extend("Speed")
--- Add.
-- Add an item to the schedule
-- @tparam userdata item Any class/module/userdata with a :getSpeed() function. The value returned by getSpeed() should be a number.
-- @tparam boolean repeating If true, this item will be rescheduled once it is returned by .next()
-- @tparam number time Initial time offset, defaults to 1/item:getSpeed()
-- @treturn ROT.Scheduler.Speed self
function Speed:add(item, repeating, time)
    self._queue:add(item, time or (1/item:getSpeed()))
    return Speed.super.add(self, item, repeating)
end

--- Next.
-- Get the next item from the scheduler and advance the appropriate amount time
-- @treturn item|nil The item previously added by .add() or nil if none are queued
function Speed:next()
    if self._current and table.indexOf(self._repeat, self._current)~=0 then
        self._queue:add(self._current, 1/self._current:getSpeed())
    end
    return Speed.super.next(self)
end

return Speed

--- Get Time.
-- Get time counted since start
-- @treturn int elapsed time
-- @function Speed:getTime()

--- Clear.
-- Remove all items from scheduler
-- @treturn ROT.Scheduler.Speed self
-- @function Speed:clear()

--- Remove.
-- Find and remove an item from the scheduler
-- @tparam any item The previously added item to be removed
-- @treturn boolean true if an item was removed from the scheduler
-- @function Speed:remove(item)
