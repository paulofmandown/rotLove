local Speed_Path =({...})[1]:gsub("[%.\\/]speed$", "") .. '/'
local class  =require (Speed_Path .. 'vendor/30log')

local Speed= ROT.Scheduler:extends { __name='Speed' }

function Speed:add(item, repeating)
	self._queue:add(item, 1/item:getSpeed())
	return Speed.super.add(self, item, repeating)
end

function Speed:next()
	if self._current and table.indexOf(self._repeat, self._current)~=0 then
		self._queue:add(self._current, 1/self._current:getSpeed())
	end
	return Speed.super.next(self)
end

return Speed
