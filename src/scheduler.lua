--- The Scheduler Prototype
-- @module ROT.Scheduler

local Scheduler_Path =({...})[1]:gsub("[%.\\/]scheduler$", "") .. '/'
local class  =require (Scheduler_Path .. 'vendor/30log')

local Scheduler = class {
	__name,
	_queue,
	_repeat,
	_current
}
function Scheduler:__init()
	self.__name  ='Scheduler'
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
	local index=table.indexOf(self._events, item)
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
