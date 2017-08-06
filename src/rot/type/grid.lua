--- Grid.
-- @module ROT.Type.Grid
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Grid = ROT.Class:extend("Grid")

-- Grid class

function Grid:init()
    self:clear()
end

function Grid:clear()
    self._points = ROT.Type.PointSet()
    self._values = {}
end

function Grid:removeCell(x, y)
    local i = self._points:find(x, y)
    if not i then return end
    local n = #self._points - 1
    local oldValue = self._values[i]
    self._points:pluck(i)
    self._values[i] = self._values[n]
    self._values[n] = nil
    return oldValue
end

function Grid:setCell(x, y, value)
    if value == nil then return self:removeCell(x, y) end
    local i, j = self._points:push(x, y)
    local oldValue = j and self._values[j]
    self._values[i or j] = value
    return oldValue
end

function Grid:getCell(x, y)
    local i = self._points:find(x, y)
    return i and self._values[i]
end

local function iterate(self, i)
    i = i - 2
    if i > 0 then
        local x, y = self._points:peek(i)
        return i, x, y, self._values[i]
    end
end

function Grid:each()
    return iterate, self, #self._points + 1
end

function Grid:getRandom()
    local x, y = self._points:getRandom()
    return x, y, self:getCell(x, y)
end

return Grid

