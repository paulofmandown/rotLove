--- The Icey Maze Map Generator.
-- See http://www.roguebasin.roguelikedevelopment.org/index.php?title=Simple_maze for explanation
-- @module ROT.Map.IceyMaze
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local IceyMaze = ROT.Map:extend("IceyMaze")
--- Constructor.
-- Called with ROT.Map.IceyMaze:new(width, height, regularity)
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam int[opt=0] regularity A value used to determine the 'randomness' of the map, 0= more random
function IceyMaze:init(width, height, regularity)
    IceyMaze.super.init(self, width, height)
    self._regularity= regularity and regularity or 0
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.IceyMaze self
function IceyMaze:create(callback)
    local w=self._width
    local h=self._height
    local map=self:_fillMap(1)
    w= w%2==1 and w-1 or w-2
    h= h%2==1 and h-1 or h-2

    local cx, cy, nx, ny = 1, 1, 1, 1
    local done   =0
    local blocked=false
    local dirs={
                {0,0},
                {0,0},
                {0,0},
                {0,0}
               }
    repeat
        cx=2+2*math.floor(self._rng:random()*(w-1)/2)
        cy=2+2*math.floor(self._rng:random()*(h-1)/2)
        if done==0 then map[cx][cy]=0 end
        if map[cx][cy]==0 then
            self:_randomize(dirs)
            repeat
                if math.floor(self._rng:random()*(self._regularity+1))==0 then self:_randomize(dirs) end
                blocked=true
                for i=1,4 do
                    nx=cx+dirs[i][1]*2
                    ny=cy+dirs[i][2]*2
                    if self:_isFree(map, nx, ny, w, h) then
                        map[nx][ny]=0
                        map[cx+dirs[i][1]][cy+dirs[i][2]]=0

                        cx=nx
                        cy=ny
                        blocked=false
                        done=done+1
                        break
                    end
                end
            until blocked
        end
    until done+1>=w*h/4

    if not callback then return self end
    for y = 1, self._height do
        for x = 1, self._width do
            callback(x, y, map[x][y])
        end
    end
    return self
end

function IceyMaze:_randomize(dirs)
    for i=1,4 do
        dirs[i][1]=0
        dirs[i][2]=0
    end
    local rand=math.floor(self._rng:random()*4)
    if rand==0 then
        dirs[1][1]=-1
        dirs[3][2]=-1
        dirs[2][1]= 1
        dirs[4][2]= 1
    elseif rand==1 then
        dirs[4][1]=-1
        dirs[2][2]=-1
        dirs[3][1]= 1
        dirs[1][2]= 1
    elseif rand==2 then
        dirs[3][1]=-1
        dirs[1][2]=-1
        dirs[4][1]= 1
        dirs[2][2]= 1
    elseif rand==3 then
        dirs[2][1]=-1
        dirs[4][2]=-1
        dirs[1][1]= 1
        dirs[3][2]= 1
    end
end

function IceyMaze:_isFree(map, x, y, w, h)
    if x<2 or y<2 or x>w or y>h then return false end
    return map[x][y]~=0
end

return IceyMaze
