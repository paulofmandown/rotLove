--- The RNG Class.
-- A Lua port of Johannes Baagøe's Alea
-- From http://baagoe.com/en/RandomMusings/javascript/
-- Johannes Baagøe <baagoe@baagoe.com>, 2010
-- Mirrored at:
-- https://github.com/nquinlan/better-random-numbers-for-javascript-mirror
-- @module ROT.RNG
local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local RNG = ROT.Class:extend("RNG")


local function Mash ()
  local n = 0xefc8249d

  local function mash (data)
    data = tostring(data)

    for i = 1, data:len() do
      n = n + data:byte(i)
      local h = 0.02519603282416938 * n
      n = math.floor(h)
      h = h - n
      h = h * n
      n = math.floor(h)
      h = h - n
      n = n + h * 0x100000000 -- 2^32
    end
    return math.floor(n) * 2.3283064365386963e-10 -- 2^-32
  end

  return mash
end

function RNG:init(seed)
    self.s0 = 0
    self.s1 = 0
    self.s2 = 0
    self.c = 1
    self:setSeed(seed)
end

--- Seed.
-- seed the rng
-- @tparam[opt=os.clock()] number s A number to base the rng from
function RNG:getSeed()
    return self.seed
end

--- Seed.
-- seed the rng
-- @tparam[opt=os.clock()] number s A number to base the rng from
function RNG:setSeed(seed)
    self.c = 1
    self.seed = seed or os.time()

    local mash = Mash()
    self.s0 = mash(' ')
    self.s1 = mash(' ')
    self.s2 = mash(' ')

    self.s0 = self.s0 - mash(self.seed)
    if self.s0 < 0 then
        self.s0 = self.s0 + 1
    end
    self.s1 = self.s1 - mash(self.seed)
    if self.s1 < 0 then
        self.s1 = self.s1 + 1
    end
    self.s2 = self.s2 - mash(self.seed)
    if self.s2 < 0 then
        self.s2 = self.s2 + 1
    end
    mash = nil
end

function RNG:getUniform()
    -- return self.implementation()
    local t = 2091639 * self.s0 + self.c * 2.3283064365386963e-10 -- 2^-32
    self.s0 = self.s1
    self.s1 = self.s2
    self.c = math.floor(t)
    self.s2 = t - self.c
    return self.s2
end

function RNG:getUniformInt(lowerBound, upperBound)
    local max = math.max(lowerBound, upperBound)
    local min = math.min(lowerBound, upperBound)
    return math.floor(self:getUniform() * (max - min + 1)) + min
end

function RNG:getNormal(mean, stddev)
    repeat
        local u = 2*self:getUniform()-1
        local v = 2*self:getUniform()-1
        local r = u*u + v*v
    until r > 1 or r == 0

    local gauss = u * math.sqrt(-2*math.log(r)/r)
    return (mean or 0) + gauss*(stddev or 1)
end

function RNG:getPercentage()
    return 1 + math.floor(self:getUniform()*100)
end

function RNG:getWeightedValue(tbl)
    local total=0
    for _,v in pairs(tbl) do
        total=total+v
    end
    local rand=self:getUniform()*total
    local part=0
    for k,v in pairs(tbl) do
        part=part+v
        if rand<part then return k end
    end
    return nil
end

--- Get current rng state
-- Returns a table that can be given to the rng to return it to this state.
-- Any RNG of the same type will always produce the same values from this state.
-- @treturn table A table that represents the current state of the rng
function RNG:getState()
    return { self.s0, self.s1, self.s2, self.c, self.seed }
end

--- Set current rng state
-- used to return an rng to a known/previous state
-- @tparam table stateTable The table retrieved from .getState()
function RNG:setState(t)
    self.s0, self.s1, self.s2, self.c, self.seed =
        t[1], t[2], t[3], t[4], t[5]
end

function RNG:clone()
    local clone = self:extend()
    clone:setState(self:getState())
    return clone
end

-- Methods below mirror Lua's math.random and math.randomseed

--- Random.
-- get a random number
-- @tparam[opt=0] int a lower threshold for random numbers
-- @tparam[opt=1] int b upper threshold for random numbers
-- @treturn number a random number
function RNG:random(a, b)
    if not a then
        return self:getUniform()
    elseif not b then
        return self:getUniformInt(1, tonumber(a))
    else
        return self:getUniformInt(tonumber(a), tonumber(b))
    end
end

RNG.randomseed = RNG.setSeed

RNG:init()

return RNG

