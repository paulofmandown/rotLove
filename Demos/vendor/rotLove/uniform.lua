Uniform_PATH =({...})[1]:gsub("[%.\\/]uniform$", "") .. '/'
local class  =require (Uniform_PATH .. 'vendor/30log')

Uniform=Dungeon:extends { _options, _rng }

function Uniform:__init(width, height, options)
    Uniform.super.__init(self, width, height)
    assert(ROT or twister, 'require rot or RandomLua')

    self._options={
                    roomWidth={4,9},
                    roomHeight={4,6},
                    corridorLength={3,7},
                    roomDugPercentage=0.17,
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

function Uniform:create(callback)
    local t1=os.clock()*1000
    while true do
        local t2=os.clock()*1000
        if t2-t1>self._options.timeLimit then return nil end
        self._map=self._fillMap(1)
        self._dug=0
        self._rooms={}
        self._unconnected={}
        self._generateRooms()
        if self._generateCorridors() then break end
    end

    if callback then
        for i=1,self._width do
            for j=1,self._height do
                callback(i, j, self._map[i][j])
            end
        end
    end

    return self
end

function Uniform:_generateRooms()
    local w=self._width-2
    local h=self._height-2
    local room=nil
    repeat
        room=self._generateRoom()
        if self._dug/(w*h)>self._options.roomDugPercentage then break end
    until not room
end

function Uniform:_generateRoom()
    local count=0
    while count<self._roomAttempts do
        count=count+1
        local room=Room:createRandom(self._width, self._height, self._options)
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

        self._map=self._fillMap(1)
        for k,_ in pairs(self._rooms) do
            local room=self._rooms[k]
            room:clearDoors()
            room:create(self._digCallback)
            table.insert(self._unconnected, room)
        end
        self._unconnected=table.randomize(self._unconnected)
        self._connected  ={}

        while true do
            local connected=table.random(self._connected)
            local room1    =self._closestRoom(self._unconnected, connected)
            local room2    =self._closestRoom(self._unconnected, room1)
            if not self._connectRooms(room1, room2 then break end
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
        dirIndex1=diffY>0 and 2 or 0
        dirIndex2=(dirIndex1+2)%4
        min      =room2:getLeft()
        max      =room2:getRight()
        index    =0
    else
        dirIndex1=diffX>0 and 1 or 3
        dirIndex2=(dirIndex1+2)%4
        min      =room2:getTop()
        max      =room2:getBottom()
        index    =1
    end

    local start=self._placeInWall(room1, dirIndex1)
    --...To Be Continued...
end

return Uniform
