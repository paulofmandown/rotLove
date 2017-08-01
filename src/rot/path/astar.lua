--- A* Pathfinding.
-- Simplified A* algorithm: all edges have a value of 1
-- @module ROT.Path.AStar
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local AStar=ROT.Path:extend("AStar")
--- Constructor.
-- @tparam int toX x-position of destination cell
-- @tparam int toY y-position of destination cell
-- @tparam function passableCallback Function with two parameters (x, y) that returns true if the cell at x,y is able to be crossed
-- @tparam table options Options
  -- @tparam[opt=8] int options.topology Directions for movement Accepted values (4 or 8)
function AStar:init(toX, toY, passableCallback, options)
    AStar.super.init(self, toX, toY, passableCallback, options)
    self._todo={}
    self._done={}
    self._fromX=nil
    self._fromY=nil
end

--- Compute the path from a starting point
-- @tparam int fromX x-position of starting point
-- @tparam int fromY y-position of starting point
-- @tparam function callback Will be called for every path item with arguments "x" and "y"
function AStar:compute(fromX, fromY, callback)
    self._todo={}
    self._done={}
    self._fromX=tonumber(fromX)
    self._fromY=tonumber(fromY)
    self._done[self._toX]={}
    self:_add(self._toX, self._toY, nil)

    while #self._todo>0 do
        local item=table.remove(self._todo, 1)
        if item.x == fromX and item.y == fromY then break end
        local neighbors=self:_getNeighbors(item.x, item.y)

        for i=1,#neighbors do
            local x = neighbors[i][1]
            local y = neighbors[i][2]
            if not self._done[x] then self._done[x]={} end
            if not self._done[x][y] then
                self:_add(x, y, item)
            end
        end
    end

    local item=self._done[self._fromX] and self._done[self._fromX][self._fromY] or nil
    if not item then return end

    while item do
        callback(tonumber(item.x), tonumber(item.y))
        item=item.prev
    end
end

function AStar:_add(x, y, prev)
    local h = self:_distance(x, y)
    local obj={}
    obj.x   =x
    obj.y   =y
    obj.prev=prev
    obj.g   =prev and prev.g+1 or 0
    obj.h   =h
    self._done[x][y]=obj

    local f=obj.g+obj.h

    for i=1,#self._todo do
        local item=self._todo[i]
        local itemF = item.g + item.h;
        if f < itemF or (f == itemF and h < item.h) then
            table.insert(self._todo, i, obj)
            return
        end
    end

    table.insert(self._todo, obj)
end

function AStar:_distance(x, y)
    if self._options.topology==4 then
        return math.abs(x-self._fromX)+math.abs(y-self._fromY)
    elseif self._options.topology==8 then
        return math.max(math.abs(x-self._fromX), math.abs(y-self._fromY))
    end
end

return AStar
