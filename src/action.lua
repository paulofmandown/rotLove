local Action_Path =({...})[1]:gsub("[%.\\/]action$", "") .. '/'
local class  =require (Action_Path .. 'vendor/30log')

local Action= ROT.Scheduler:extends { _defaultDuration, _duration }

function Action:__init()
	Action.super.__init(self)
	self.__name='Action'
	self._defaultDuration=1
	self._duration=self._defaultDuration
end

function Action:add(item, repeating, time)
	self._queue:add(item, time and time or self._defaultDuration)
	return Action.super.add(self, item, repeating)
end

function Action:clear()
	self._duration = self._defaultDuration
	return Action.super.clear(self)
end

function Action:remove(item)
	if item==self._current then self._duration=self._defaultDuration end
	return Action.super.remove(self, item)
end

function Action:next()
	if self._current and table.indexOf(self._repeat, self._current)~=0 then
		self._queue:add(self._current, self._duration and self._duration or self._defaultDuration)
		self._duration=self._defaultDuration
	end
	return Action.super.next(self)
end

function Action:setDuration(time)
	if self._current then self._duration=time end
	return self
end

return Action
