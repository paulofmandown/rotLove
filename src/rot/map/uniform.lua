--- The Uniform Map Generator.
-- See http://www.roguebasin.roguelikedevelopment.org/index.php?title=Dungeon-Building_Algorithm.
-- @module ROT.Map.Uniform
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Uniform=ROT.Map.Dungeon:extend("Uniform")

--- Constructor.
-- Called with ROT.Map.Uniform:new()
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam[opt] table options Options
  -- @tparam[opt={4,9}] table options.roomWidth room minimum and maximum width
  -- @tparam[opt={4,6}] table options.roomHeight room minimum and maximum height
  -- @tparam[opt=0.2] number options.dugPercentage we stop after this percentage of level area has been dug out
  -- @tparam[opt=1000] int options.timeLimit stop after this much time has passed (msec)
-- @tparam userdata rng Userdata with a .random(self, min, max) function
function Uniform:init(width, height, options)
    Uniform.super.init(self, width, height)

    self._digCallback = self:bind(self._digCallback)
    self._canBeDugCallback = self:bind(self._canBeDugCallback)
    self._isWallCallback = self:bind(self._isWallCallback)

    self._options={
                    roomWidth={4,9},
                    roomHeight={4,6},
                    roomDugPercentage=0.2,
                    timeLimit=1000
                  }
    if options then
        for k,_ in pairs(options) do
            self._options[k]=options[k]
        end
    end
    self._roomAttempts=20
    self._corridorAttempts=20
    self._connected={}
    self._unconnected={}
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.Uniform self
function Uniform:create(callback)
    local t1=os.clock()*1000
    while true do
        local t2=os.clock()*1000
        if t2-t1>self._options.timeLimit then return nil end
        self._map=self:_fillMap(1)
        self._dug=0
        self._rooms={}
        self._unconnected={}
        self:_generateRooms()
        if self:_generateCorridors() then break end
    end

    if not callback then return self end
    for y = 1, self._height do
        for x = 1, self._width do
            callback(x, y, self._map[x][y])
        end
    end
    return self
end

function Uniform:_generateRooms()
    local w=self._width-4
    local h=self._height-4
    local room=nil
    repeat
        room=self:_generateRoom()
        if self._dug/(w*h)>self._options.roomDugPercentage then break end
    until not room
end

function Uniform:_generateRoom()
    local count=0
    while count<self._roomAttempts do
        count=count+1
        local room=ROT.Map.Room:createRandom(self._width, self._height, self._options, self._rng)
        if room:isValid(self._isWallCallback, self._canBeDugCallback) then
            room:create(self._digCallback)
            table.insert(self._rooms, room)
            return room
        end
    end
    return nil
end

function Uniform:_generateCorridors()
    local cnt=0
    while cnt<self._corridorAttempts do
        cnt=cnt+1
        self._corridors={}
        self._map=self:_fillMap(1)
        for i=1,#self._rooms do
            local room=self._rooms[i]
            room:clearDoors()
            room:create(self._digCallback)
        end

        self._unconnected=table.randomize(table.slice(self._rooms))
        self._connected  ={}
        table.insert(self._connected, table.remove(self._unconnected))
        while true do
            local connected=table.random(self._connected)
            local room1    =self:_closestRoom(self._unconnected, connected)
            local room2    =self:_closestRoom(self._connected, room1)
            if not self:_connectRooms(room1, room2) then break end
            if #self._unconnected<1 then return true end
        end
    end
    return false
end

function Uniform:_closestRoom(rooms, room)
    local dist  =math.huge
    local center=room:getCenter()
    local result=nil

    for i=1,#rooms do
        local r =rooms[i]
        local c =r:getCenter()
        local dx=c[1]-center[1]
        local dy=c[2]-center[2]
        local d =dx*dx+dy*dy
        if d<dist then
            dist  =d
            result=r
        end
    end
    return result
end

function Uniform:_connectRooms(room1, room2)
    local center1=room1:getCenter()
    local center2=room2:getCenter()

    local diffX=center2[1]-center1[1]
    local diffY=center2[2]-center1[2]

    local dirIndex1=0
    local dirIndex2=0
    local min      =0
    local max      =0
    local index    =0

    if math.abs(diffX)<math.abs(diffY) then
        dirIndex1=diffY>0 and 3 or 1
        dirIndex2=(dirIndex1+1)%4+1
        min      =room2:getLeft()
        max      =room2:getRight()
        index    =1
    else
        dirIndex1=diffX>0 and 2 or 4
        dirIndex2=(dirIndex1+1)%4+1
        min      =room2:getTop()
        max      =room2:getBottom()
        index    =2
    end

    local index2=(index%2)+1

    local start=self:_placeInWall(room1, dirIndex1)
    if not start or #start<1 then return false end
    local endTbl={}

    if start[index] >= min and start[index] <= max then
        endTbl=table.slice(start)
        local value=nil
        if     dirIndex2==1 then value=room2:getTop()   -1
        elseif dirIndex2==2 then value=room2:getRight() +1
        elseif dirIndex2==3 then value=room2:getBottom()+1
        elseif dirIndex2==4 then value=room2:getLeft()  -1
        end
        endTbl[index2]=value
        self:_digLine({start, endTbl})
    elseif start[index] < min-1 or start[index] > max+1 then
        local diff=start[index]-center2[index]
        local rotation=0
        if dirIndex2==1 or dirIndex2==2 then rotation=diff<0 and 2 or 4
        elseif dirIndex2==3 or dirIndex2==4 then rotation=diff<0 and 4 or 2 end
        if rotation==0 then assert(false, 'failed to rotate') end
        dirIndex2=(dirIndex2+rotation)%4+1

        endTbl=self:_placeInWall(room2, dirIndex2)
        if not endTbl then return false end

        local mid={0,0}
        mid[index]=start[index]
        mid[index2]=endTbl[index2]
        self:_digLine({start, mid, endTbl})
    else
        endTbl=self:_placeInWall(room2, dirIndex2)
        if #endTbl<1 then return false end
        local mid   =math.round((endTbl[index2]+start[index2])/2)

        local mid1={0,0}
        local mid2={0,0}
        mid1[index] = start[index];
        mid1[index2] = mid;
        mid2[index] = endTbl[index];
        mid2[index2] = mid;
        self:_digLine({start, mid1, mid2, endTbl});
    end

    room1:addDoor(start[1],start[2])
    room2:addDoor(endTbl[1], endTbl[2])

    index=table.indexOf(self._unconnected, room1)
    if index>0 then
        table.insert(self._connected, table.remove(self._unconnected, index))
    end

    return true
end

function Uniform:_placeInWall(room, dirIndex)
    local start ={0,0}
    local dir   ={0,0}
    local length=0
    local retTable={}

    if dirIndex==1 then
        dir   ={1,0}
        start ={room:getLeft()-1, room:getTop()-1}
        length= room:getRight()-room:getLeft()
    elseif dirIndex==2 then
        dir   ={0,1}
        start ={room:getRight()+1, room:getTop()}
        length=room:getBottom()-room:getTop()
    elseif dirIndex==3 then
        dir   ={1,0}
        start ={room:getLeft()-1, room:getBottom()+1}
        length=room:getRight()-room:getLeft()
    elseif dirIndex==4 then
        dir   ={0,1}
        start ={room:getLeft()-1, room:getTop()-1}
        length=room:getBottom()-room:getTop()
    end
    local avail={}
    local lastBadIndex=-1
    local null=string.char(0)
    for i=1,length do
        local x=start[1]+i*dir[1]
        local y=start[2]+i*dir[2]
        table.insert(avail, null)
        if self._map[x][y]==1 then --is a wall
            if lastBadIndex ~=i-1 then
                avail[i]={x, y}
            end
        else
            lastBadIndex=i
            if i>1 then avail[i-1]=null end
        end
    end

    for i=1,#avail do
        if avail[i]~=string.char(0) then
            table.insert(retTable, avail[i])
            i=i-1
        end
    end
    return #retTable>0 and table.random(retTable) or nil
end

function Uniform:_digLine(points)
    for i=2,#points do
        local start=points[i-1]
        local endPt=points[i]
        local corridor=ROT.Map.Corridor:new(start[1], start[2], endPt[1], endPt[2])
        corridor:create(self._digCallback)
        table.insert(self._corridors, corridor)
    end
end

function Uniform:_digCallback(x, y, value)
    self._map[x][y]=value
    if value==0 then self._dug=self._dug+1 end
end

function Uniform:_isWallCallback(x, y)
    if x<1 or y<1 or x>self._width or y>self._height then return false end
    return self._map[x][y]==1
end

function Uniform:_canBeDugCallback(x, y)
    if x<2 or y<2 or x>=self._width or y>=self._height then return false end
    return self._map[x][y]==1
end

return Uniform
