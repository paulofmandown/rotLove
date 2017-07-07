--- Dijkstra Pathfinding.
-- Simplified Dijkstra's algorithm: all edges have a value of 1
-- @module ROT.Path.Dijkstra
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Dijkstra=ROT.Path:extend("Dijkstra")
--- Constructor.
-- @tparam int toX x-position of destination cell
-- @tparam int toY y-position of destination cell
-- @tparam function passableCallback Function with two parameters (x, y) that returns true if the cell at x,y is able to be crossed
-- @tparam table options Options
  -- @tparam[opt=8] int options.topology Directions for movement Accepted values (4 or 8)
function Dijkstra:init(toX, toY, passableCallback, options)
    Dijkstra.super.init(self, toX, toY, passableCallback, options)

    self._computed={}
    self._todo    ={}

    local obj = {x=toX, y=toY, prev=nil}
    self._computed[toX]={}
    self._computed[toX][toY] = obj
    table.insert(self._todo, obj)
end

--- Compute the path from a starting point
-- @tparam int fromX x-position of starting point
-- @tparam int fromY y-position of starting point
-- @tparam function callback Will be called for every path item with arguments "x" and "y"
function Dijkstra:compute(fromX, fromY, callback)
    self._fromX=tonumber(fromX)
    self._fromY=tonumber(fromY)

    if not self._computed[self._fromX] then self._computed[self._fromX]={} end
    if not self._computed[self._fromX][self._fromY] then self:_compute(self._fromX, self._fromY) end
    if not self._computed[self._fromX][self._fromY] then return end

    local item=self._computed[self._fromX][self._fromY]
    while item do
        callback(tonumber(item.x), tonumber(item.y))
        item=item.prev
    end
end

function Dijkstra:_compute(fromX, fromY)
    while #self._todo>0 do
        local item=table.remove(self._todo, 1)
        if item.x == fromX and item.y == fromY then return end

        local neighbors=self:_getNeighbors(item.x, item.y)

        for i=1,#neighbors do
            local x=neighbors[i][1]
            local y=neighbors[i][2]
            if not self._computed[x] then self._computed[x]={} end
            if not self._computed[x][y] then
                self:_add(x, y, item)
            end
        end
    end
end

function Dijkstra:_add(x, y, prev)
    local obj={}
    obj.x   =x
    obj.y   =y
    obj.prev=prev

    self._computed[x][y]=obj
    table.insert(self._todo, obj)
end

return Dijkstra
