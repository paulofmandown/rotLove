local Simple_Path =({...})[1]:gsub("[%.\\/]simple$", "") .. '/'
local class  =require (Simple_Path .. 'vendor/30log')

local Simple= ROT.Scheduler:extends { __name='Simple' }

function Simple:add(item, repeating)
	self._queue:add(item, 0)
	return Simple.super.add(self, item, repeating)
end

function Simple:next()
	if self._current and table.indexOf(self._repeat, self._current)~=0 then
		self._queue:add(self._current, 0)
	end
	return Simple.super.next(self)
end

return Simple
