--- The Eller Maze Map Generator.
-- See http://homepages.cwi.nl/~tromp/maze.html for explanation
-- @module ROT.Map.EllerMaze
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local EllerMaze = ROT.Map:extend("EllerMaze")

--- Constructor.
-- Called with ROT.Map.EllerMaze:new(width, height)
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
function EllerMaze:init(width, height)
    EllerMaze.super.init(self, width, height)
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.EllerMaze self
function EllerMaze:create(callback)
    local map =ROT.Type.Grid()
    local w   =math.ceil((self._width-2)/2)
    local rand=9/24
    local L   ={}
    local R   ={}

    for i=1,w do
        table.insert(L,i)
        table.insert(R,i)
    end
    table.insert(L,w)
    local j=2
    while j<self._height-2 do
        for i=1,w do
            local x=2*i
            local y=j
            map:setCell(x, y, 0)

            if i~=L[i+1] and self._rng:random()>rand then
                self:_addToList(i, L, R)
                map:setCell(x + 1, y, 0)
            end

            if i~=L[i] and self._rng:random()>rand then
                self:_removeFromList(i, L, R)
            else
                map:setCell(x, y + 1, 0)
            end
        end
        j=j+2
    end
    --j=self._height%2==1 and self._height-2 or self._height-3
    for i=1,w do
        local x=2*i
        local y=j
        map:setCell(x, y, 0)

        if i~=L[i+1] and (i==L[i] or self._rng:random()>rand) then
            self:_addToList(i, L, R)
            map:setCell(x + 1, y, 0)
        end

        self:_removeFromList(i, L, R)
    end

    if not callback then return self end
    
    for y = 1, self._height do
        for x = 1, self._width do
            callback(x, y, map:getCell(x, y) or 1)
        end
    end
    
    return self
end

function EllerMaze:_removeFromList(i, L, R)
    R[L[i]]=R[i]
    L[R[i]]=L[i]
    R[i]   =i
    L[i]   =i
end

function EllerMaze:_addToList(i, L, R)
    R[L[i+1]]=R[i]
    L[R[i]]  =L[i+1]
    R[i]     =i+1
    L[i+1]   =i
end

return EllerMaze
