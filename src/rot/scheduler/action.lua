--- Action based turn scheduler.
-- @module ROT.Scheduler.Action
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Action= ROT.Scheduler:extend("Action")
function Action:init()
    Action.super.init(self)
    self._defaultDuration=1
    self._duration=self._defaultDuration
end

--- Add.
-- Add an item to the scheduler.
-- @tparam any item The item that is returned when this turn comes up
-- @tparam boolean repeating If true, when this turn comes up, it will be added to the queue again
-- @tparam[opt=1] int time an initial delay time
-- @treturn ROT.Scheduler.Action self
function Action:add(item, repeating, time)
    self._queue:add(item, time and time or self._defaultDuration)
    return Action.super.add(self, item, repeating)
end

--- Clear.
-- empties this scheduler's event queue, no items will be returned by .next() until more are added with .add()
-- @treturn ROT.Scheduler.Action self
function Action:clear()
    self._duration = self._defaultDuration
    return Action.super.clear(self)
end

--- Remove.
-- Looks for the next instance of item in the event queue
-- @treturn ROT.Scheduler.Action self
function Action:remove(item)
    if item==self._current then self._duration=self._defaultDuration end
    return Action.super.remove(self, item)
end

--- Next.
-- returns the next item based on that item's last action's duration
-- @return item
function Action:next()
    if self._current and table.indexOf(self._repeat, self._current)~=0 then
        self._queue:add(self._current, self._duration and self._duration or self._defaultDuration)
        self._duration=self._defaultDuration
    end
    return Action.super.next(self)
end

--- set duration for the active item
-- after calling next() this function defines the duration of that item's action
-- @tparam int time The amount of time that the current item's action should last.
-- @treturn ROT.Scheduler.Action self
function Action:setDuration(time)
    if self._current then self._duration=time end
    return self
end

return Action
