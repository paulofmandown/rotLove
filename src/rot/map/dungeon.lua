--- The Dungeon-style map Prototype.
-- This class is extended by ROT.Map.Digger and ROT.Map.Uniform
-- @module ROT.Map.Dungeon
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Dungeon = ROT.Map:extend("Dungeon")
--- Constructor.
-- Called with ROT.Map.Cellular:new()
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
function Dungeon:init(width, height)
    Dungeon.super.init(self, width, height)
    self._rooms    ={}
    self._corridors={}
end

--- Get rooms
-- Get a table of rooms on the map
-- @treturn table A table containing objects of the type ROT.Map.Room
function Dungeon:getRooms() return self._rooms end

--- Get doors
-- Get a table of doors on the map
-- @treturn table A table {{x=int, y=int},...} for doors.

-- FIXME: This could be problematic; it accesses an internal member of another
-- class (room._doors). Will break if underlying implementation changes.
-- Should probably take a callback instead like Room:getDoors().

function Dungeon:getDoors()
    local result={}
    for _, room in ipairs(self._rooms) do
        for _, x, y in room._doors:each() do
            result[#result + 1] = { x = x, y = y }
        end
    end
    return result
end

--- Get corridors
-- Get a table of corridors on the map
-- @treturn table A table containing objects of the type ROT.Map.Corridor
function Dungeon:getCorridors() return self._corridors end

function Dungeon:_getDetail(name, x, y)
    local t = self[name]
    for i = 1, #t do
        if t[i].x == x and t[i].y == y then return t[i], i end
    end
end

function Dungeon:_setDetail(name, x, y, value)
    local detail, i = self:_getDetail(name, x, y)
    if detail then
        if value then
            detail.value = value
        else
            table.remove(self[name], i)
        end
    elseif value then
        local t = self[name]
        detail = { x = x, y = y, value = value }
        t[#t + 1] = detail
    end
    return detail
end

function Dungeon:getWall(x, y)
    return self:_getDetail('_walls', x, y)
end

function Dungeon:setWall(x, y, value)
    return self:_setDetail('_walls', x, y, value)
end

return Dungeon
