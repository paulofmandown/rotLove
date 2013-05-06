--- Linear Congruential Generator. A random number generator based on RandomLua
-- @module ROT.RNG.LCG

local LCG_PATH =({...})[1]:gsub("[%.\\/]lcg$", "") .. '/'
local class  =require (LCG_PATH .. 'vendor/30log')

local LCG=ROT.RNG:extends { __name, mt, index, a, c, m, x, _seed }


--- Constructor.
-- Called with ROT.RNG.LCG:new(r)
-- @tparam[opt] string r Choose to populate the rng with values from numerical recipes or mvc as opposed to Ansi C. Accepted values 'nr', 'mvc'
function LCG:__init(r)
	self.__name='LCG'
    self.a= 1103515245   -- Ansi C
    self.c= 12345
    self.m= 0x10000

    if r=='nr' then self.a, self.c, self.m = 1664525, 1013904223, 0x10000       -- Numerical Recipes
    elseif r=='mvc' then self.a, self.c, self.m = 214013, 2531011, 0x10000 end  -- MVC
end

--- Random.
-- get a random number
-- @tparam[opt=0] int a lower threshold for random numbers
-- @tparam[opt=1] int b upper threshold for random numbers
-- @treturn number a random number
function LCG:random(a, b)
    local y = (self.a * self.x + self.c) % self.m
    self.x = y
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
function LCG:randomseed(s)
    if not s then s = self:seed() end
    self._seed=s
    self.x = self:normalize(s)
end

--- Get current rng state
-- Returns a table that can be given to the rng to return it to this state.
-- Any RNG of the same type will always produce the same values from this state.
-- @treturn table A table that represents the current state of the rng
function LCG:getState()
    return { a=self.a, c=self.c, m=self.m, x=self.x, _seed=self._seed}
end

--- Set current rng state
-- used to return an rng to a known/previous state
-- @tparam table stateTable The table retrieved from .getState()
function LCG:setState(stateTable)
    assert(stateTable.a, 'bad stateTable: need stateTable.a')
    assert(stateTable.c, 'bad stateTable: need stateTable.c')
    assert(stateTable.m, 'bad stateTable: need stateTable.m')
    assert(stateTable.x, 'bad stateTable: need stateTable.x')
    assert(stateTable._seed, 'bad stateTable: need stateTable._seed')

    self.a=stateTable.a
    self.c=stateTable.c
    self.m=stateTable.m
    self.x=stateTable.x
    self._seed=stateTable._seed
end

return LCG
