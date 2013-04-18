SpeedScheduler_Path =({...})[1]:gsub("[%.\\/]speedScheduler$", "") .. '/'
local class  =require (SpeedScheduler_Path .. 'vendor/30log')

SpeedScheduler= Scheduler:extends { __name='SpeedScheduler' }

function SpeedScheduler:add(item, repeating)
	self._queue:add(item, 1/item:getSpeed())
	return SpeedScheduler.super.add(self, item, repeating)
end

function SpeedScheduler:next()
	if self._current and table.indexOf(self._repeat, self._current)~=0 then
		self._queue:add(self._current, 1/self._current:getSpeed())
	end
	return SpeedScheduler.super.next(self)
end

return SpeedScheduler
