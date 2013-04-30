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

function Scheduler:getTime()
	return self._queue:getTime()
end

function Scheduler:add(item, repeating)
	if repeating then table.insert(self._repeat, item) end
	return self
end

function Scheduler:clear()
	self._queue:clear()
	self._repeat={}
	self._current=nil
	return self
end

function Scheduler:remove(item)
	local result=self._queue:remove(item)
	local index=table.indexOf(self._events, item)
	if index~=0 then table.remove(self._repeat, index) end
	if self._current==item then self._current=nil end
	return result
end

function Scheduler:next()
	self._current=self._queue:get()
	return self._current
end

return Scheduler
