local Engine_PATH =({...})[1]:gsub("[%.\\/]engine$", "") .. '/'
local class  =require (Engine_PATH .. 'vendor/30log')

local Engine = class { _scheduler, _lock }
function Engine:__init(scheduler)
	self.__name='Engine'
	self._scheduler=scheduler
	self._lock     =1
end

function Engine:start()
	return self:unlock()
end

function Engine:lock()
	self._lock=self._lock+1
end

function Engine:unlock()
	assert(self._lock>0, 'Cannot unlock unlocked Engine')
	self._lock=self._lock-1
	while self._lock<1 do
		local actor=self._scheduler:next()
		if not actor then return self:lock() end
		actor:act()
	end
	return self
end

return Engine
