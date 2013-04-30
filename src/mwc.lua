local MWC_PATH =({...})[1]:gsub("[%.\\/]mwc$", "") .. '/'
local class  =require (MWC_PATH .. 'vendor/30log')

local MWC=ROT.RNG:extends { __name, mt, index, a, c, ic, m, x, _seed }

function MWC:__init(r)
	self.__name='MWC'

    self.a= 1103515245
    self.c= 12345
    self.ic=self.c
    self.m= 0x10000

    if r=='nr' then self.a, self.c, self.m = 1664525, 1013904223, 0x10000
    elseif r=='mvc' then self.a, self.c, self.m = 214013, 2531011, 0x10000 end
end

function MWC:random(a, b)
    local m = self.m
    local t = self.a * self.x + self.c
    local y = t % m
    self.x = y
    self.c = math.floor(t / m)
    if not a then return y / 0x10000
    elseif not b then
        if a == 0 then return y
        else return 1 + (y % a) end
    else
        return a + (y % (b - a + 1))
    end
end

function MWC:randomseed(s)
    if not s then s = self:seed() end
    self._seed=s
    self.c = self.ic
    self.x = self:normalize(s)
end

function MWC:getState()
    return { a=self.a, c=self.c, ic=self.ic, m=self.m, x=self.x, _seed=self._seed}
end

function MWC:setState(stateTable)
    assert(stateTable.a, 'bad stateTable: need stateTable.a')
    assert(stateTable.c, 'bad stateTable: need stateTable.c')
    assert(stateTable.ic, 'bad stateTable: need stateTable.ic')
    assert(stateTable.m, 'bad stateTable: need stateTable.m')
    assert(stateTable.x, 'bad stateTable: need stateTable.x')
    assert(stateTable._seed, 'bad stateTable: need stateTable._seed')

    self.a=stateTable.a
    self.c=stateTable.c
    self.ic=stateTable.ic
    self.m=stateTable.m
    self.x=stateTable.x
    self._seed=stateTable._seed
end

return MWC
