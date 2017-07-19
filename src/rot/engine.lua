local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Engine = ROT.Class:extend("Engine")

function Engine:init(scheduler)
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
