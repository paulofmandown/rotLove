--- Stores and retrieves events based on time.
-- @module ROT.EventQueue
local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local EventQueue = ROT.Class:extend("EventQueue")

function EventQueue:init()
    self._time = 0
    self._events = {}
    self._eventTimes = {}
end

--- Get Time.
-- Get time counted since start
-- @treturn int elapsed time
function EventQueue:getTime()
    return self._time
end

--- Clear.
-- Remove all events from queue
-- @treturn ROT.EventQueue self
function EventQueue:clear()
    self._events    ={}
    self._eventTimes={}
    return self
end

--- Add.
-- Add an event
-- @tparam any event Any object
-- @tparam int time The number of time units that will elapse before this event is returned
function EventQueue:add(event, time)
    local index= 1
    if self._eventTimes then
        for i=1,#self._eventTimes do
            if self._eventTimes[i]>time then
                index=i
                break
            end
            index=i+1
        end
    end
    table.insert(self._events, index, event)
    table.insert(self._eventTimes, index, time)
end

--- Get.
-- Get the next event from the queue and advance the appropriate amount time
-- @treturn event|nil The event previously added by .add() or nil if none are queued
function EventQueue:get()
    if #self._events<1 then return nil end
    local time = table.remove(self._eventTimes, 1)
    if time>0 then
        self._time=self._time+time
        for i=1,#self._eventTimes do
            self._eventTimes[i]=self._eventTimes[i]-time
        end
    end
    return table.remove(self._events, 1)
end

--- Get event time.
-- Get the time associated with the given event
-- @tparam any event
-- @treturn number time
function EventQueue:getEventTime(event)
    local index=table.indexOf(self._events, event)
    if index==0 then return nil end
    return self._eventTimes[index]
end

--- Remove.
-- Find and remove an event from the queue
-- @tparam any event The previously added event to be removed
-- @treturn boolean true if an event was removed from the queue
function EventQueue:remove(event)
    local index=table.indexOf(self._events, event)
    if index==0 then return false end
    self:_remove(index)
    return true
end

function EventQueue:_remove(index)
    table.remove(self._events, index)
    table.remove(self._eventTimes, index)
end

return EventQueue
