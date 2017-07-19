--- The Divided Maze Map Generator.
-- Recursively divided maze, http://en.wikipedia.org/wiki/Maze_generation_algorithm#Recursive_division_method
-- @module ROT.Map.DividedMaze
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local DividedMaze = ROT.Map:extend("DividedMaze")
--- Constructor.
-- Called with ROT.Map.DividedMaze:new(width, height)
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
function DividedMaze:init(width, height)
    DividedMaze.super.init(self, width, height)
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.DividedMaze self
function DividedMaze:create(callback)
    local w=self._width
    local h=self._height
    self._map = {}

    for i=1,w do
        table.insert(self._map, {})
        for j=1,h do
            local border= i==1 or j==1 or i==w or j==h
            table.insert(self._map[i], border and 1 or 0)
        end
    end
    self._stack = { {2,2,w-1,h-1} }
    self:_process()
    if not callback then return self end
    for y = 1, h do
        for x = 1, w do
            callback(x, y, self._map[x][y])
        end
    end
    return self
end

function DividedMaze:_process()
    while #self._stack>0 do
        local room=table.remove(self._stack, 1)
        self:_partitionRoom(room)
    end
end

function DividedMaze:_partitionRoom(room)
    local availX={}
    local availY={}

    for i=room[1]+1,room[3]-1 do
        local top   =self._map[i][room[2]-1]
        local bottom=self._map[i][room[4]+1]
        if top>0 and bottom>0 and i%2==0 then table.insert(availX, i) end
    end

    for j=room[2]+1,room[4]-1 do
        local left =self._map[room[1]-1][j]
        local right=self._map[room[3]+1][j]
        if left>0 and right>0 and j%2==0 then table.insert(availY, j) end
    end

    if #availX==0 or #availY==0 then return end

    local x=table.random(availX)
    local y=table.random(availY)

    self._map[x][y]=1

    local walls={}

    table.insert(walls, {})
    for i=room[1],x-1,1 do
        self._map[i][y]=1
        table.insert(walls[#walls], {i,y})
    end

    table.insert(walls, {})
    for i=x+1,room[3],1 do
        self._map[i][y]=1
        table.insert(walls[#walls],{i,y})
    end

    table.insert(walls, {})
    for j=room[2],y-1,1 do
        self._map[x][j]=1
        table.insert(walls[#walls],{x,j})
    end

    table.insert(walls, {})
    for j=y+1,room[4] do
        self._map[x][j]=1
        table.insert(walls[#walls],{x,j})
    end

    local solid= table.random(walls)
    for i=1,#walls do
        local w=walls[i]
        if w~=solid then
            local hole=table.random(w)
            self._map[hole[1]][hole[2]]=0
        end
    end
    table.insert(self._stack, {room[1], room[2], x-1, y-1})
    table.insert(self._stack, {x+1, room[2], room[3], y-1})
    table.insert(self._stack, {room[1], y+1, x-1, room[4]})
    table.insert(self._stack, {x+1, y+1, room[3], room[4]})

end

return DividedMaze
