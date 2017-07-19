--- Cellular Automaton Map Generator
-- @module ROT.Map.Cellular
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Cellular = ROT.Map:extend("Cellular")
--- Constructor.
-- Called with ROT.Map.Cellular:new()
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam[opt] table options Options
  -- @tparam table options.born List of neighbor counts for a new cell to be born in empty space
  -- @tparam table options.survive List of neighbor counts for an existing  cell to survive
  -- @tparam int options.topology Topology. Accepted values: 4, 8
  -- @tparam boolean options.connected Set to true to connect open areas on create
  -- @tparam int options.minimumZoneArea Unconnected zones with fewer tiles than this will be turned to wall instead of being connected
function Cellular:init(width, height, options)
    Cellular.super.init(self, width, height)
    self._options={
                    born    ={5,6,7,8},
                    survive ={4,5,6,7,8},
                    topology=8,
                    connected=false,
                    minimumZoneArea=8
                  }
    if options then
        for k,v in pairs(options) do
            self._options[k]=v
        end
    end
    local t=self._options.topology
    assert(t==8 or t==4, 'topology must be 8 or 4')
    self._dirs = t==8 and ROT.DIRS.EIGHT or t==4 and ROT.DIRS.FOUR
end

--- Randomize cells.
-- Random fill map with 0 or 1. Call this first when creating a map.
-- @tparam number prob Probability that a cell will be a floor (0). Accepts values between 0 and 1
-- @treturn ROT.Map.Cellular self
function Cellular:randomize(prob)
    if not self._map then self._map = self:_fillMap(0) end
    for i=1,self._width do
        for j=1,self._height do
            self._map[i][j]= self._rng:random() < prob and 1 or 0
        end
    end
    return self
end

--- Set.
-- Assign a value (0 or 1) to a cell on the map
-- @tparam int x x-position of the cell
-- @tparam int y y-position of the cell
-- @tparam int value Value to be assigned 0-Floor 1-Wall
function Cellular:set(x, y, value)
    self._map[x][y]=value
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.Cellular self
function Cellular:create(callback)
    local newMap =self:_fillMap(0)
    local born   =self._options.born
    local survive=self._options.survive
    local changed=false

    for j=1,self._height do
        for i=1,self._width do
            local cur   =self._map[i][j]
            local ncount=self:_getNeighbors(i, j)
            if cur>0 and table.indexOf(survive, ncount)>0 then
                newMap[i][j]=1
            elseif cur<=0 and table.indexOf(born, ncount)>0 then
                newMap[i][j]=1
            end
            if not changed and newMap[i][j]~=self._map[i][j] then changed=true end
        end
    end
    self._map=newMap

    if self._options.connected then
        self:_completeMaze()
    end
    if callback then
        for i=1,self._width do
            for j=1,self._height do
                if callback then callback(i, j, newMap[i][j]) end
            end
        end
    end
    self.changed = changed
    return self
end

function Cellular:_getNeighbors(cx, cy)
    local rst=0
    for i=1,#self._dirs do
        local dir=self._dirs[i]
        local x  =cx+dir[1]
        local y  =cy+dir[2]
        if x>0 and x<=self._width and y>0 and y<=self._height then
            rst= self._map[x][y]==1 and rst+1 or rst
        end
    end
    return rst
end

function Cellular:_completeMaze()
    -- Collect all zones
    local zones={}
    for i=1,self._width do
        for j=1,self._height do
            if self._map[i][j]==0 then
                self:_addZoneFrom(i,j,zones)
            end
        end
    end
    -- overwrite zones below a certain size
    -- and connect zones
    for i=1,#zones do
        if #zones[i]<self._options.minimumZoneArea then
            for _,v in pairs(zones[i]) do
                self._map[v[1]][v[2]]=1
            end
        else
            local rx=self._rng:random(1,self._width)
            local ry=self._rng:random(1,self._height)
            while self._map[rx][ry]~=1 and self._map[rx][ry]~=i do
                rx=self._rng:random(1,self._width)
                ry=self._rng:random(1,self._height)
            end
            local t=zones[i][self._rng:random(1,#zones[i])]
            self:_tunnel(t[1],t[2],rx,ry)
            -- re-establish floors as 0 for this zone
            for _,v in pairs(zones[i]) do
                self._map[v[1]][v[2]]=0
            end
        end
    end
end

function Cellular:_addZoneFrom(x,y,zones)
    local dirs=self._dirs
    local todo={{x,y}}
    table.insert(zones,{})
    local zId =#zones+1
    self._map[x][y]=zId
    table.insert(zones[#zones], {x,y})
    while #todo>0 do
        local t=table.remove(todo)
        local tx=t[1]
        local ty=t[2]
        for _,v in pairs(dirs) do
            local nx=tx+v[1]
            local ny=ty+v[2]
            if self._map[nx] and self._map[nx][ny] and self._map[nx][ny]==0 then
                self._map[nx][ny]=zId
                table.insert(zones[#zones], {nx,ny})
                table.insert(todo, {nx,ny})
            end
        end
    end
end

function Cellular:_tunnel(sx,sy,ex,ey)
    local xOffset=ex-sx
    local yOffset=ey-sy
    local xpos   =sx
    local ypos   =sy
    local moves={}
    local xAbs=math.abs(xOffset)
    local yAbs=math.abs(yOffset)
    local firstHalf =self._rng:random()
    local secondHalf=1-firstHalf
    local xDir=xOffset>0 and 3 or 7
    local yDir=yOffset>0 and 5 or 1
    if xAbs<yAbs then
        local tempDist=math.ceil(yAbs*firstHalf)
        table.insert(moves, {yDir, tempDist})
        table.insert(moves, {xDir, xAbs})
        tempDist=math.floor(yAbs*secondHalf)
        table.insert(moves, {yDir, tempDist})
    else
        local tempDist=math.ceil(xAbs*firstHalf)
        table.insert(moves, {xDir, tempDist})
        table.insert(moves, {yDir, yAbs})
        tempDist=math.floor(xAbs*secondHalf)
        table.insert(moves, {xDir, tempDist})
    end

    local dirs=ROT.DIRS.EIGHT
    self._map[xpos][ypos]=0
    while #moves>0 do
        local move=table.remove(moves)
        if move and move[1] and move[1]<9 and move[1]>0 then
            while move[2]>0 do
                xpos=xpos+dirs[move[1]][1]
                ypos=ypos+dirs[move[1]][2]
                self._map[xpos][ypos]=0
                move[2]=move[2]-1
            end
        end
    end
end

return Cellular
