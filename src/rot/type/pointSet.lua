--- Pair set.
-- An unordered collection of unique value-pairs.
-- @module ROT.Type.PointSet
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local PointSet = ROT.Class:extend("PointSet")

function PointSet:init()
    self._index = {}
end

local function hash(x, y)
    return x and y * 0x4000000 + x or false --  26-bit x and y
end

function PointSet:find(x, y)
    return self._index[hash(x, y)]
end

function PointSet:peek(i)
    return self[i], self[i + 1]
end

function PointSet:poke(i, x, y)
    self._index[hash(self:peek(i))] = nil
    self._index[hash(x, y)] = i
    self._index[false] = nil
    self[i], self[i + 1] = x, y
    return self
end

function PointSet:push(x, y)
    local key = hash(x, y)
    local i = self._index[key]
    if i then return nil, i end
    i = #self + 1
    self:poke(i, x, y)
    self._index[key] = i
    self._index[false] = nil
    return i
end

function PointSet:pluck(i)
    local last, x, y = #self - 1, self:peek(i)
    self:poke(i, self:peek(last)):poke(last)
    self._index[hash(x, y)] = nil
    self._index[hash(self:peek(i))] = i
    self._index[false] = nil
    return x, y
end

function PointSet:prune(x, y)
    local i = self:find(x, y)
    return i and self:pluck(i)
end

local function iterate(self, i)
    i = i - 2
    if i > 0 then
        return i, self:peek(i)
    end
end

function PointSet:each()
    return iterate, self, #self + 1
end

function PointSet:getRandom()
    local i = self._rng:random(1, #self / 2) * 2 - 1
    return self:peek(i)
end

return PointSet

