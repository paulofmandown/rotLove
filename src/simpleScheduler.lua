SimpleScheduler_Path =({...})[1]:gsub("[%.\\/]simpleScheduler$", "") .. '/'
local class  =require (SimpleScheduler_Path .. 'vendor/30log')

SimpleScheduler= Scheduler:extends { }

function SimpleScheduler:add(item, repeating)
	self._queue:add(item, 0)
	return SimpleScheduler.super.add(self, item, repeating)
end

function SimpleScheduler:next()
	write(table.indexOf(self._repeat, self._current))
	if self._current and table.indexOf(self._repeat, self._current)~=0 then
		self._queue:add(self._current, 0)
	end
	return SimpleScheduler.super.next(self)
end

return SimpleScheduler
