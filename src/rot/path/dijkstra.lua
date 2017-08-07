--- Dijkstra Pathfinding.
-- Simplified Dijkstra's algorithm: all edges have a value of 1
-- @module ROT.Path.Dijkstra
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Dijkstra=ROT.Path:extend("Dijkstra")

local Grid = ROT.Type.Grid

--- Constructor.
-- @tparam int toX x-position of destination cell
-- @tparam int toY y-position of destination cell
-- @tparam function passableCallback Function with two parameters (x, y) that returns true if the cell at x,y is able to be crossed
-- @tparam table options Options
  -- @tparam[opt=8] int options.topology Directions for movement Accepted values (4 or 8)
function Dijkstra:init(toX, toY, passableCallback, options)
    toX, toY = tonumber(toX), tonumber(toY)
    Dijkstra.super.init(self, toX, toY, passableCallback, options)

    self._computed=Grid()
    self._todo    ={}

    self:_add(toX, toY)
end

--- Compute the path from a starting point
-- @tparam int fromX x-position of starting point
-- @tparam int fromY y-position of starting point
-- @tparam function callback Will be called for every path item with arguments "x" and "y"
function Dijkstra:compute(fromX, fromY, callback)
    fromX, fromY = tonumber(fromX), tonumber(fromY)
    
    local item = self._computed:getCell(fromX, fromY)
        or self:_compute(fromX, fromY)
    
    while item do
        callback(item.x, item.y)
        item=item.prev
    end
end

function Dijkstra:_compute(fromX, fromY)
    while #self._todo>0 do
        local item=table.remove(self._todo, 1)
        if item.x == fromX and item.y == fromY then return item end

        local neighbors=self:_getNeighbors(item.x, item.y)

        for i=1,#neighbors do
            local x=neighbors[i][1]
            local y=neighbors[i][2]
            if not self._computed:getCell(x, y) then
                self:_add(x, y, item)
            end
        end
    end
end

function Dijkstra:_add(x, y, prev)
    local obj = { x = x, y = y, prev = prev }

    self._computed:setCell(x, y, obj)
    table.insert(self._todo, obj)
end

return Dijkstra

