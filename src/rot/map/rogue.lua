--- Rogue Map Generator.
-- A map generator based on the original Rogue map gen algorithm
-- See http://kuoi.com/~kamikaze/GameDesign/art07_rogue_dungeon.php
-- @module ROT.Map.Rogue
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Rogue=ROT.Map:extend("Rogue")

local function calculateRoomSize(size, cell)
    local max=math.floor((size/cell)*0.8)
    local min=math.floor((size/cell)*0.25)
    min=min<2 and 2 or min
    max=max<2 and 2 or max
    return {min, max}
end

--- Constructor.
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam[opt] table options Options
  -- @tparam int options.cellWidth Number of cells to create on the horizontal (number of rooms horizontally)
  -- @tparam int options.cellHeight Number of cells to create on the vertical (number of rooms vertically)
  -- @tparam int options.roomWidth Room min and max width
  -- @tparam int options.roomHeight Room min and max height
function Rogue:init(width, height, options)
    Rogue.super.init(self, width, height)
    self._doors={}
    self._options={cellWidth=math.floor(width*0.0375), cellHeight=math.floor(height*0.125)}
    if options then for k,_ in pairs(options) do self._options[k]=options[k] end end

    if not self._options.roomWidth then
        self._options.roomWidth=calculateRoomSize(width, self._options.cellWidth)
    end

    if not self._options.roomHeight then
        self._options.roomHeight=calculateRoomSize(height, self._options.cellHeight)
    end
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.Cellular|nil self or nil if time limit is reached
function Rogue:create(callback)
    self.map=self:_fillMap(1)
    self._rooms={}
    self.connectedCells={}

    self:_initRooms()
    self:_connectRooms()
    self:_connectUnconnectedRooms()
    self:_createRandomRoomConnections()
    self:_createRooms()
    self:_createCorridors()
    if not callback then return self end
    for y = 1, self._height do
        for x = 1, self._width do
            callback(x, y, self.map[x][y])
        end
    end
    return self
end

function Rogue:_getRandomInt(min, max)
    min=min and min or 0
    max=max and max or 1
    return math.floor(self._rng:random(min,max))
end

function Rogue:_initRooms()
    for i=1,self._options.cellWidth do
        self._rooms[i]={}
        for j=1,self._options.cellHeight do
            self._rooms[i][j]={x=0, y=0, width=0, height=0, connections={}, cellx=i, celly=j}
        end
    end
end

function Rogue:_connectRooms()
    local cgx=self:_getRandomInt(1, self._options.cellWidth)
    local cgy=self:_getRandomInt(1, self._options.cellHeight)
    local idx, ncgx, ncgy
    local found=false
    local room, otherRoom
    local dirToCheck=0
    repeat
        dirToCheck={1, 3, 5, 7}
        dirToCheck=table.randomize(dirToCheck)
        repeat
            found=false
            idx=table.remove(dirToCheck)
            ncgx=cgx+ROT.DIRS.EIGHT[idx][1]
            ncgy=cgy+ROT.DIRS.EIGHT[idx][2]

            if (ncgx>0 and ncgx<=self._options.cellWidth) and
               (ncgy>0 and ncgy<=self._options.cellHeight) then
                room=self._rooms[cgx][cgy]

                if #room.connections>0 then
                    if room.connections[1][1] == ncgx and
                       room.connections[1][2] == ncgy then
                        break
                    end
                end

                otherRoom=self._rooms[ncgx][ncgy]

                if #otherRoom.connections==0 then
                    table.insert(otherRoom.connections, {cgx,cgy})
                    table.insert(self.connectedCells, {ncgx, ncgy})
                    cgx=ncgx
                    cgy=ncgy
                    found=true
                end
            end
        until #dirToCheck<1 or found
    until #dirToCheck<1
end

function Rogue:_connectUnconnectedRooms()
    local cw=self._options.cellWidth
    local ch=self._options.cellHeight

    self.connectedCells=table.randomize(self.connectedCells)
    local room, otherRoom, validRoom

    for i=1,cw do
        for j=1,ch do
            room=self._rooms[i][j]

            if #room.connections==0 then
                local dirs={1,3,5,7}
                dirs=table.randomize(dirs)
                validRoom=false
                repeat
                    local dirIdx=table.remove(dirs)
                    local newI=i+ROT.DIRS.EIGHT[dirIdx][1]
                    local newJ=j+ROT.DIRS.EIGHT[dirIdx][2]

                    if newI>0 and newI<=cw and
                       newJ>0 and newJ<=ch then

                        otherRoom=self._rooms[newI][newJ]
                        validRoom=true

                        if #otherRoom.connections==0 then
                            break
                        end

                        for k=1,#otherRoom.connections do
                            if otherRoom.connections[k][1]==i and
                               otherRoom.connections[k][2]==j then
                                validRoom=false
                                break
                            end
                        end

                        if validRoom then break end

                    end
                until #dirs<1
                if validRoom then table.insert(room.connections, {otherRoom.cellx, otherRoom.celly})
                else
                    io.write('-- Unable to connect room.'); io.flush()
                end
            end
        end
    end
end

function Rogue:_createRandomRoomConnections()
    return
end

function Rogue:_createRooms()
    local w  =self._width
    local h  =self._height
    local cw =self._options.cellWidth
    local ch =self._options.cellHeight
    local cwp=math.floor(self._width/cw)
    local chp=math.floor(self._height/ch)

    local roomw, roomh
    local roomWidth =self._options.roomWidth
    local roomHeight=self._options.roomHeight
    local sx, sy
    local otherRoom


    for i=1,cw do
        for j=1,ch do
            sx=cwp*(i-1)
            sy=chp*(j-1)
            sx=sx<2 and 2 or  sx
            sy=sy<2 and 2 or  sy
            roomw=self:_getRandomInt(roomWidth[1], roomWidth[2])
            roomh=self:_getRandomInt(roomHeight[1], roomHeight[2])

            if j>1 then
                otherRoom=self._rooms[i][j-1]
                while sy-(otherRoom.y+otherRoom.height)<3 do
                    sy=sy+1
                end
            end

            if i>1 then
                otherRoom=self._rooms[i-1][j]
                while sx-(otherRoom.x+otherRoom.width)<3 do
                    sx=sx+1
                end
            end
            local sxOffset=math.round(self:_getRandomInt(0, cwp-roomw)/2)
            local syOffset=math.round(self:_getRandomInt(0, chp-roomh)/2)
            while sx+sxOffset+roomw>w do
                if sxOffset>0 then
                    sxOffset=sxOffset-1
                else
                    roomw=roomw-1
                end
            end

            while sy+syOffset+roomh>h do
                if syOffset>0 then
                    syOffset=syOffset-1
                else
                    roomh=roomh-1
                end
            end


            sx=sx+sxOffset
            sy=sy+syOffset

            self._rooms[i][j].x     =sx
            self._rooms[i][j].y     =sy
            self._rooms[i][j].width =roomw
            self._rooms[i][j].height=roomh

            for ii=sx,sx+roomw-1 do
                for jj=sy,sy+roomh-1 do
                    self.map[ii][jj]=0
                end
            end
        end
    end
end

function Rogue:_getWallPosition(aRoom, aDirection)
    local rx, ry, door
    if aDirection==1 or aDirection==3 then
        local maxRx=aRoom.x+aRoom.width-1
        rx=self:_getRandomInt(aRoom.x, maxRx>aRoom.x and maxRx or aRoom.x)
        if aDirection==1 then
            ry  =aRoom.y-2
            door=ry+1
        else
            ry  =aRoom.y+aRoom.height+1
            door=ry-1
        end
        self.map[rx][door]=0
        table.insert(self._doors,{x=rx, y=door})
    elseif aDirection==2 or aDirection==4 then
        local maxRy=aRoom.y+aRoom.height-1
        ry=self:_getRandomInt(aRoom.y, maxRy>aRoom.y and maxRy or aRoom.y)
        if aDirection==2 then
            rx  =aRoom.x+aRoom.width+1
            door=rx-1
        else
            rx  =aRoom.x-2
            door=rx+1
        end
        self.map[door][ry]=0
        table.insert(self._doors,{x=door, y=ry})
    end
    return {rx, ry}
end

function Rogue:_drawCorridor(startPosition, endPosition)
    local xOffset=endPosition[1]-startPosition[1]
    local yOffset=endPosition[2]-startPosition[2]
    local xpos   =startPosition[1]
    local ypos   =startPosition[2]
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
    self.map[xpos][ypos]=0
    while #moves>0 do
        local move=table.remove(moves)
        if move and move[1] and move[1]<9 and move[1]>0 then
            while move[2]>0 do
                xpos=xpos+dirs[move[1]][1]
                ypos=ypos+dirs[move[1]][2]
                self.map[xpos][ypos]=0
                move[2]=move[2]-1
            end
        end
    end
end

function Rogue:_createCorridors()
    local cw=self._options.cellWidth
    local ch=self._options.cellHeight
    local room, connection, otherRoom, wall, otherWall

    for i=1,cw do
        for j=1,ch do
            room=self._rooms[i][j]
            for k=1,#room.connections do
                connection=room.connections[k]
                otherRoom =self._rooms[connection[1]][connection[2]]

                if otherRoom.cellx>room.cellx then
                    wall     =2
                    otherWall=4
                elseif otherRoom.cellx<room.cellx then
                    wall     =4
                    otherWall=2
                elseif otherRoom.celly>room.celly then
                    wall     =3
                    otherWall=1
                elseif otherRoom.celly<room.celly then
                    wall     =1
                    otherWall=3
                end
                self:_drawCorridor(self:_getWallPosition(room, wall), self:_getWallPosition(otherRoom, otherWall))
            end
        end
    end
end

return Rogue
