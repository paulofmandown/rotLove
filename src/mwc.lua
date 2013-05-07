--- Multiply With Carry. A random number generator based on RandomLua
-- @module ROT.RNG.MWC
local MWC_PATH =({...})[1]:gsub("[%.\\/]mwc$", "") .. '/'
local class  =require (MWC_PATH .. 'vendor/30log')

local MWC=ROT.RNG:extends { __name, mt, index, a, c, ic, m, x, _seed }

--- Constructor.
-- Called with ROT.RNG.MWC:new(r)
-- @tparam[opt] string r Choose to populate the rng with values from numerical recipes or mvc as opposed to Ansi C. Accepted values 'nr', 'mvc'
function MWC:__init(r)
	self.__name='MWC'

    self.a= 1103515245
    self.c= 12345
    self.ic=self.c
    self.m= 0x10000

    if r=='nr' then self.a, self.c, self.m = 1664525, 1013904223, 0x10000
    elseif r=='mvc' then self.a, self.c, self.m = 214013, 2531011, 0x10000 end
end

--- Random.
-- get a random number
-- @tparam[opt=0] int a lower threshold for random numbers
-- @tparam[opt=1] int b upper threshold for random numbers
-- @treturn number a random number
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

--- Seed.
-- seed the rng
-- @tparam[opt=os.clock()] number s A number to base the rng from
function MWC:randomseed(s)
    if not s then s = self:seed() end
    self._seed=s
    self.c = self.ic
    self.x = self:normalize(s)
end

--- Get current rng state
-- Returns a table that can be given to the rng to return it to this state.
-- Any RNG of the same type will always produce the same values from this state.
-- @treturn table A table that represents the current state of the rng
function MWC:getState()
    return { a=self.a, c=self.c, ic=self.ic, m=self.m, x=self.x, _seed=self._seed}
end

--- Set current rng state
-- used to return an rng to a known/previous state
-- @tparam table stateTable The table retrieved from .getState()
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
