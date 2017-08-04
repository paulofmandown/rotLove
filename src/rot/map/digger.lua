--- The Digger Map Generator.
-- See http://www.roguebasin.roguelikedevelopment.org/index.php?title=Dungeon-Building_Algorithm.
-- @module ROT.Map.Digger
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Digger=ROT.Map.Dungeon:extend("Digger")
--- Constructor.
-- Called with ROT.Map.Digger:new()
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam[opt] table options Options
  -- @tparam[opt={3,8}] table options.roomWidth room minimum and maximum width
  -- @tparam[opt={3,5}] table options.roomHeight room minimum and maximum height
  -- @tparam[opt={3,7}] table options.corridorLength corridor minimum and maximum length
  -- @tparam[opt=0.2] number options.dugPercentage we stop after this percentage of level area has been dug out
  -- @tparam[opt=1000] int options.timeLimit stop after this much time has passed (msec)
  -- @tparam[opt=false] boolean options.nocorridorsmode If true, do not use corridors to generate this map
function Digger:init(width, height, options)
    Digger.super.init(self, width, height)

    self._digCallback = self:bind(self._digCallback)
    self._canBeDugCallback = self:bind(self._canBeDugCallback)
    self._isWallCallback = self:bind(self._isWallCallback)
    self._priorityWallCallback = self:bind(self._priorityWallCallback)

    self._options={
                    roomWidth={3,8},
                    roomHeight={3,5},
                    corridorLength={3,7},
                    dugPercentage=0.2,
                    timeLimit=1000,
                    nocorridorsmode=false
                  }
    if options then
        for k,_ in pairs(options) do
            self._options[k]=options[k]
        end
    end

    self._features={Room=4, Corridor=4}
    if self._options.nocorridorsmode then
        self._features.Corridor=nil
    end
    self._featureAttempts=20
    self._walls={}
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.Digger self
function Digger:create(callback)
    self._rooms    ={}
    self._corridors={}
    self._map      =self:_fillMap(1)
    self._walls    ={}
    self._dug      =0
    local area     =(self._width-2)*(self._height-2)

    self:_firstRoom()

    local t1=os.clock()*1000
    local priorityWalls=0
    repeat
        local t2=os.clock()*1000
        if t2-t1>self._options.timeLimit then break end

        local wall=self:_findWall()
        if not wall then break end

        local x    = wall.x
        local y    = wall.y
        local dir  =self:_getDiggingDirection(x, y)
        if dir then
            local featureAttempts=0
            repeat
                featureAttempts=featureAttempts+1
                if self:_tryFeature(x, y, dir[1], dir[2]) then
                    self:_removeSurroundingWalls(x, y)
                    self:_removeSurroundingWalls(x-dir[1], y-dir[2])
                    break
                end
            until featureAttempts>=self._featureAttempts
            priorityWalls=0
            for i = 1, #self._walls do
                local wall = self._walls[i]
                if wall.value > 1 then
                    priorityWalls=priorityWalls+1
                end
            end
        end
    until self._dug/area > self._options.dugPercentage and priorityWalls<1

    self:_addDoors()

    if not callback then return self end
    for y = 1, self._height do
        for x = 1, self._width do
            callback(x, y, self._map[x][y])
        end
    end
    return self
end

function Digger:_digCallback(x, y, value)
    if value==0 or value==2 then
        self._map[x][y]=0
        self._dug=self._dug+1
    else
        self:setWall(x, y, 1)
    end
end

function Digger:_isWallCallback(x, y)
    if x<1 or y<1 or x>self._width or y>self._height then return false end
    return self._map[x][y]==1
end

function Digger:_canBeDugCallback(x, y)
    if x<2 or y<2 or x>=self._width or y>=self._height then return false end
    return self._map[x][y]==1
end

function Digger:_priorityWallCallback(x, y)
    self:setWall(x, y, 2)
end

function Digger:_firstRoom()
    local cx  =math.floor(self._width/2)
    local cy  =math.floor(self._height/2)
    local room=ROT.Map.Room:new():createRandomCenter(cx, cy, self._options, self._rng)
    table.insert(self._rooms, room)
    room:create(self._digCallback)
end

function Digger:_findWall()
    local prio1={}
    local prio2={}
    for i = 1, #self._walls do
        local wall = self._walls[i]
        if wall.value > 1 then prio2[#prio2 + 1] = wall
        else prio1[#prio1 + 1] = wall end
    end
    local arr=#prio2>0 and prio2 or prio1
    if #arr<1 then return nil end
    local wall = table.random(arr)
    self:setWall(wall.x, wall.y, nil)
    return wall
end

function Digger:_tryFeature(x, y, dx, dy)
    local type=self._rng:getWeightedValue(self._features)
    local feature=ROT.Map[type]:createRandomAt(x,y,dx,dy,self._options,self._rng)

    if not feature:isValid(self._isWallCallback, self._canBeDugCallback) then
        return false
    end

    feature:create(self._digCallback)

    if type=='Room' then
        table.insert(self._rooms, feature)
    elseif type=='Corridor' then
        feature:createPriorityWalls(self._priorityWallCallback)
        table.insert(self._corridors, feature)
    end

    return true
end

function Digger:_removeSurroundingWalls(cx, cy)
    local deltas=ROT.DIRS.FOUR
    for i=1,#deltas do
        local delta=deltas[i]
        local x    =cx+delta[1]
        local y    =cy+delta[2]
        self:setWall(x, y, nil)
        x=2*delta[1]
        y=2*delta[2]
        self:setWall(x, y, nil)
    end
end

function Digger:_getDiggingDirection(cx, cy)
    if cx<2 or cy<2 or cx>self._width-1 or cy>self._height-1 then return nil end
    local deltas=ROT.DIRS.FOUR
    local result=nil

    for i=1,#deltas do
        local delta=deltas[i]
        local x    =cx+delta[1]
        local y    =cy+delta[2]
        if self._map[x][y]==0 then
            if result then return nil end
            result=delta
        end
    end
    if not result then return nil end

    return {-result[1], -result[2]}
end

function Digger:_addDoors()
    for i=1,#self._rooms do
        local room=self._rooms[i]
        room:clearDoors()
        room:addDoors(self._isWallCallback)
    end
end

return Digger
