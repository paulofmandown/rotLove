local Dijkstra_PATH=({...})[1]:gsub("[%.\\/]dijkstra$", "") .. '/'
local class  =require (Dijkstra_PATH .. 'vendor/30log')

local Dijkstra=ROT.Path:extends { _toX, _toY, _fromX, _fromY, _computed, _todo, _passableCallback, _options, _dirs}

function Dijkstra:__init(toX, toY, passableCallback, options)
    Dijkstra.super.__init(self, toX, toY, passableCallback, options)

    self._computed={}
    self._todo    ={}

    local obj = {x=toX, y=toY, prev=nil}
    self._computed[toX..','..toY] = obj
    table.insert(self._todo, obj)
end

function Dijkstra:compute(fromX, fromY, callback)
    local key=fromX..','..fromY

    if not self._computed[key] then self:_compute(fromX, fromY) end
    if not self._computed[key] then return end

    local item=self._computed[key]
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
            local neighbor=neighbors[i]
            local x=neighbor[1]
            local y=neighbor[2]
            local id=x..','..y
            if not self._computed[id] then
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

    self._computed[x..','..y]=obj
    table.insert(self._todo, obj)
end

return Dijkstra
