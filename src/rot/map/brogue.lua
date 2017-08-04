--- The Brogue Map Generator.
-- Based on the description of Brogues level generation at http://brogue.wikia.com/wiki/Level_Generation
-- @module ROT.Map.Brogue
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Brogue=ROT.Map.Dungeon:extend("Brogue")

local PointSet = ROT.Type.PointSet

--- Constructor.
-- Called with ROT.Map.Brogue:new(). A note: Brogue's map is 79x29. Consider using those dimensions for Display if you're looking to build a brogue-like.
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam[opt] table options Options
  -- @tparam[opt={4,20}] table options.roomWidth Room width for rectangle one of cross rooms
  -- @tparam[opt={3,7}] table options.roomHeight Room height for rectangle one of cross rooms
  -- @tparam[opt={3,12}] table options.crossWidth Room width for rectangle two of cross rooms
  -- @tparam[opt={2,5}] table options.crossHeight Room height for rectangle two of cross rooms
  -- @tparam[opt={3,12}] table options.corridorWidth Length of east-west corridors
  -- @tparam[opt={2,5}] table options.corridorHeight Length of north-south corridors
function Brogue:init(width, height, options)
    Brogue.super.init(self, width, height)

    self._digCallback = self:bind(self._digCallback)
    self._canBeDugCallback = self:bind(self._canBeDugCallback)
    self._isWallCallback = self:bind(self._isWallCallback)

    self._options={
                    roomWidth={4,20},
                    roomHeight={3,7},
                    crossWidth={3,12},
                    crossHeight={2,5},
                    corridorWidth={2,12},
                    corridorHeight={2,5},
                    caveChance=.33,
                    corridorChance=.8
                  }

    if options then
        for k,v in pairs(options) do self._options[k]=v end
    end

    self._walls=PointSet():setRNG(self._rng)
    self._rooms={}
    self._loops=30
    self._loopAttempts=300
    self._maxrooms=99
    self._roomAttempts=600
    self._dirs=ROT.DIRS.FOUR
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall, 2==door
-- @tparam boolean firstFloorBehavior If true will put an upside T (9x10v and 20x4h) at the bottom center of the map.
-- @treturn ROT.Map.Brogue self
function Brogue:create(callback, firstFloorBehavior)
    self._map=self:_fillMap(1)
    self._rooms={}
    self._walls=PointSet():setRNG(self._rng)

    self:_buildFirstRoom(firstFloorBehavior)
    self:_generateRooms()
    self:_generateLoops()
    self:_closeDiagonalOpenings()
    self:_addDoors()

    if not callback then return self end
    for y=1,self._height do
        for x=1,self._width do
            callback(x,y, self._map[x][y])
        end
    end
    return self
end

function Brogue:_buildFirstRoom(firstFloorBehavior)
    while true do
        if firstFloorBehavior then
            local room=ROT.Map.BrogueRoom:createEntranceRoom(self._width, self._height)
            if room:isValid(self._isWallCallback, self._canBeDugCallback) then
                table.insert(self._rooms, room)
                room:create(self._digCallback)
                self:_insertWalls(room._walls)
                return room
            end
        elseif self._rng:random()<self._options.caveChance then
            return self:_buildCave()
        else
            local room=ROT.Map.BrogueRoom:createRandom(self._width, self._height, self._options, self._rng)
            if room:isValid(self._isWallCallback, self._canBeDugCallback) then
                table.insert(self._rooms, room)
                room:create(self._digCallback)
                self:_insertWalls(room._walls)
                return room
            end
        end
    end
end

function Brogue:_buildCave()
    local cl=ROT.Map.Cellular:new(self._width, self._height, nil, self._rng)
    cl:randomize(.55)
    for _=1,5 do cl:create() end
    local map=cl._map
    local id=2
    local largest=2
    local bestBlob = { size = 0, walls = PointSet() }

    for x=1,self._width do
        for y=1,self._height do
            if map[x][y]==1 then
                local blobData=self:_fillBlob(x,y,map, id)
                if blobData.size > bestBlob.size then
                    largest=id
                    bestBlob=blobData
                end
                id=id+1
            end
        end
    end

    for _, x, y in bestBlob.walls:each() do
        self._walls:push(x, y)
    end
    
    for x=2,self._width-1 do
        for y=2,self._height-1 do
            if map[x][y]==largest then
                self._map[x][y]=0
            else
                self._map[x][y]=1
            end
        end
    end
end

function Brogue:_fillBlob(x,y,map, id)
    map[x][y]=id
    local todo=PointSet()
    local dirs=ROT.DIRS.EIGHT
    local size=1
    local walls=PointSet()
    todo:push(x, y)
    repeat
        local px, py = todo:pluck(1)
        for i=1,#dirs do
            local rx=px+dirs[i][1]
            local ry=py+dirs[i][2]
            if rx<1 or rx>self._width or ry<1 or ry>self._height then

            elseif map[rx][ry]==1 then
                map[rx][ry]=id
                todo:push(rx, ry)
                size=size+1
            elseif map[rx][ry]==0 then
                walls:push(rx, ry)
            end
        end
    until #todo==0
    return { size = size, walls = walls }
end

function Brogue:_generateRooms()
    local rooms=0
    for i=1,1000 do
        if rooms>self._maxrooms then break end
        if self:_buildRoom(i>375) then
            rooms=rooms+1
        end
    end
end

function Brogue:_buildRoom(forceNoCorridor)
    --local p=table.remove(self._walls,self._rng:random(1,#self._walls))
    -- local p=self._walls[self._rng:random(1,#self._walls)]
    local x, y = self._walls:getRandom()
    if not x then return false end
    local d=self:_getDiggingDirection(x, y)
    if d then
        if self._rng:random()<self._options.corridorChance and not forceNoCorridor then
            local cd
            if d[1]~=0 then cd=self._options.corridorWidth
            else cd=self._options.corridorHeight
            end
            local corridor=ROT.Map.Corridor:createRandomAt(x+d[1],y+d[2],d[1],d[2],{corridorLength=cd}, self._rng)
            if corridor:isValid(self._isWallCallback, self._canBeDugCallback) then
                local dx=corridor._endX
                local dy=corridor._endY

                local room=ROT.Map.BrogueRoom:createRandomAt(dx, dy ,d[1],d[2], self._options, self._rng)

                if room:isValid(self._isWallCallback, self._canBeDugCallback) then
                    corridor:create(self._digCallback)
                    table.insert(self._corridors, corridor)
                    room:create(self._digCallback)
                    table.insert(self._rooms, room)
                    self:_insertWalls(room._walls)
                    self._map[x][y]=0
                    self._map[dx][dy]=0
                    return true
                end
            end
        else
            local room=ROT.Map.BrogueRoom:createRandomAt(x,y,d[1],d[2], self._options, self._rng)
            if room:isValid(self._isWallCallback, self._canBeDugCallback) then
                room:create(self._digCallback)
                table.insert(self._rooms, room)
                self:_insertWalls(room._walls)
                return true
            end
        end
    end
    return false
end

function Brogue:_getDiggingDirection(cx, cy)
    local deltas=ROT.DIRS.FOUR
    local result=nil

    for i=1,#deltas do
        local delta=deltas[i]
        local x    =cx+delta[1]
        local y    =cy+delta[2]
        if x<1 or y<1 or x>self._width or y>self._height then return nil end
        if self._map[x][y]==0 then
            if result and #result>0 then return nil end
            result=delta
        end
    end
    if not result or #result<1 then return nil end

    return {-result[1], -result[2]}
end

function Brogue:_insertWalls(wt)
    for _, x, y in wt:each() do self._walls:push(x, y) end
end

function Brogue:_generateLoops()
    local dirs=ROT.DIRS.FOUR
    local count=0
    local wd=self._width
    local hi=self._height
    local m=self._map
    local function cb()
        count=count+1
    end
    local function pass(x,y)
        return m[x][y]~=1
    end
    for _=1,300 do
        if #self._walls<1 then return end
        local wx, wy = self._walls:getRandom()
        self._walls:prune(wx, wy)
        
        for j=1,2 do
            local x=wx +dirs[j][1]
            local y=wy +dirs[j][2]
            local x2=wx+dirs[j+2][1]
            local y2=wy+dirs[j+2][2]
            if x>1 and x2>1 and y>1 and y2>1 and
                x<wd and x2<wd and y<hi and y2<hi and
                m[x][y]==0 and m[x2][y2]==0
            then
                local path=ROT.Path.AStar(x,y,pass)
                path:compute(x2, y2, cb)
                if count>20 then
                    m[wx][wy]= 0 -- 2
                end
                count=0
            end
        end
        
    end
end

function Brogue:_closeDiagonalOpenings()
end

function Brogue:_digCallback(x, y, value)
    self._map[x][y] = value == 2 and 0 or value
end

function Brogue:_isWallCallback(x, y)
    if x<1 or y<1 or x>self._width or y>self._height then return false end
    return self._map[x][y]==1
end

function Brogue:_canBeDugCallback(x, y)
    if x<2 or y<2 or x>=self._width or y>=self._height then
        return false
    end
    local drs=ROT.DIRS.FOUR
    for i=1,#drs do
        if self._map[x+drs[i][1]][y+drs[i][2]]==0 then return false end
    end
    return true
end

function Brogue:_addDoors()
    for i=1,#self._rooms do
        local room=self._rooms[i]
        room:clearDoors()
        room:addDoors(self._isWallCallback)
    end
end

return Brogue
