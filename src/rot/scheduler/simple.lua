--- The simple scheduler.
-- @module ROT.Scheduler.Simple
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Simple= ROT.Scheduler:extend("Simple")

--- Add.
-- Add an item to the schedule
-- @tparam any item
-- @tparam boolean repeating If true, this item will be rescheduled once it is returned by .next()
-- @treturn ROT.Scheduler.Simple self
function Simple:add(item, repeating)
    self._queue:add(item, 0)
    return Simple.super.add(self, item, repeating)
end

--- Next.
-- Get the next item from the scheduler and advance the appropriate amount time
-- @treturn item|nil The item previously added by .add() or nil if none are queued
function Simple:next()
    if self._current and table.indexOf(self._repeat, self._current)~=0 then
        self._queue:add(self._current, 0)
    end
    return Simple.super.next(self)
end

return Simple

--- Get Time.
-- Get time counted since start
-- @treturn int elapsed time
-- @function Simple:getTime()

--- Clear.
-- Remove all items from scheduler
-- @treturn ROT.Scheduler.Simple self
-- @function Simple:clear()

--- Remove.
-- Find and remove an item from the scheduler
-- @tparam any item The previously added item to be removed
-- @treturn boolean true if an item was removed from the scheduler
-- @function Simple:remove(item)
