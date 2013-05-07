ActionScheduler_Path =({...})[1]:gsub("[%.\\/]actionScheduler$", "") .. '/'
local class  =require (ActionScheduler_Path .. 'vendor/30log')

ActionScheduler= Scheduler:extends { _defaultDuration, _duration }

function ActionScheduler:__init()
	ActionScheduler.super.__init(self)
	self.__name='ActionScheduler'
	self._defaultDuration=1
	self._duration=self._defaultDuration
end

function ActionScheduler:add(item, repeating, time)
	self._queue:add(item, time and time or self._defaultDuration)
	return ActionScheduler.super.add(self, item, repeating)
end

function ActionScheduler:clear()
	self._duration = self._defaultDuration
	return ActionScheduler.super.clear(self)
end

function ActionScheduler:remove(item)
	if item==self._current then self._duration=self._defaultDuration end
	return ActionScheduler.super.remove(self, item)
end

function ActionScheduler:next()
	if self._current and table.indexOf(self._repeat, self._current)~=0 then
		self._queue:add(self._current, self._duration and self._duration or self._defaultDuration)
		self._duration=self._defaultDuration
	end
	return ActionScheduler.super.next(self)
end

function ActionScheduler:setDuration(time)
	if self._current then self._duration=time end
	return self
end

return ActionScheduler
