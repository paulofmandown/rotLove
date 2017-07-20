--- Room object.
-- Used by ROT.Map.Uniform and ROT.Map.Digger to create maps
-- @module ROT.Map.Room
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Room = ROT.Map.Feature:extend("Room")
--- Constructor.
-- creates a new room object with the assigned values
-- @tparam int x1 Left wall
-- @tparam int y1 Upper wall
-- @tparam int x2 Right wall
-- @tparam int y2 Bottom wall
-- @tparam[opt] int doorX x-position of door
-- @tparam[opt] int doorY y-position of door
function Room:init(x1, y1, x2, y2, doorX, doorY)
    self._x1   =x1
    self._x2   =x2
    self._y1   =y1
    self._y2   =y2
    self._doors= {}
    if doorX then
        self._doors[doorX..','..doorY] = 1
    end
end

--- Create Random with position.
-- @tparam int x x-position of room
-- @tparam int y y-position of room
-- @tparam int dx x-direction in which to build room 1==right -1==left
-- @tparam int dy y-direction in which to build room 1==down  -1==up
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for room {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for room {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(self, min, max) method
function Room:createRandomAt(x, y, dx, dy, options, rng)
    rng = rng or self._rng
    local min  =options.roomWidth[1]
    local max  =options.roomWidth[2]
    local width=min+math.floor(rng:random(min, max))

    min   =options.roomHeight[1]
    max   =options.roomHeight[2]
    local height=min+math.floor(rng:random(min,max))

    if dx==1 then
        local y2=y-math.floor(rng:random()*height)
        return Room:new(x+1, y2, x+width, y2+height-1, x, y):setRNG(rng)
    end
    if dx==-1 then
        local y2=y-math.floor(rng:random()*height)
        return Room:new(x-width, y2, x-1, y2+height-1, x, y):setRNG(rng)
    end
    if dy==1 then
        local x2=x-math.floor(rng:random()*width)
        return Room:new(x2, y+1, x2+width-1, y+height, x, y):setRNG(rng)
    end
    if dy==-1 then
        local x2=x-math.floor(rng:random()*width)
        return Room:new(x2, y-height, x2+width-1, y-1, x, y):setRNG(rng)
    end
end

--- Create Random with center position.
-- @tparam int cx x-position of room's center
-- @tparam int cy y-position of room's center
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for room {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for room {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function Room:createRandomCenter(cx, cy, options, rng)
    rng = rng or self._rng
    local min  =options.roomWidth[1]
    local max  =options.roomWidth[2]
    local width=min+math.floor(rng:random()*(max-min+1))

    min   =options.roomHeight[1]
    max   =options.roomHeight[2]
    local height=min+math.floor(rng:random()*(max-min+1))

    local x1=cx-math.floor(rng:random()*width)
    local y1=cy-math.floor(rng:random()*height)
    local x2=x1+width-1
    local y2=y1+height-1

    return Room:new(x1, y1, x2, y2):setRNG(rng)
end

--- Create random with no position.
-- @tparam int availWidth Typically the width of the map.
-- @tparam int availHeight Typically the height of the map
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for room {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for room {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function Room:createRandom(availWidth, availHeight, options, rng)
    rng = rng or self._rng
    local min  =options.roomWidth[1]
    local max  =options.roomWidth[2]
    local width=math.floor(rng:random(min, max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    local height=math.floor(rng:random(min, max))

    local left=availWidth-width
    local top =availHeight-height

    local x1=math.floor(rng:random()*left)
    local y1=math.floor(rng:random()*top)
    local x2=x1+width
    local y2=y1+height
    return Room:new(x1, y1, x2, y2):setRNG(rng)
end

--- Place a door.
-- adds an element to this rooms _doors table
-- @tparam int x the x-position of the door
-- @tparam int y the y-position of the door
function Room:addDoor(x, y)
    self._doors[x..','..y]=1
end

--- Get all doors.
-- Runs the provided callback on all doors for this room
-- @tparam function callback A function with two parameters (x, y) representing the position of the door.
function Room:getDoors(callback)
    for k,_ in pairs(self._doors) do
        local parts=k:split(',')
        callback(tonumber(parts[1]), tonumber(parts[2]))
    end
end

--- Reset the room's _doors table.
-- @treturn ROT.Map.Room self
function Room:clearDoors()
    self._doors={}
    return self
end

--- Add all doors based on available walls.
-- @tparam function isWallCallback
-- @treturn ROT.Map.Room self
function Room:addDoors(isWallCallback)
    local left  =self._x1-1
    local right =self._x2+1
    local top   =self._y1-1
    local bottom=self._y2+1
    for x=left,right do
        for y=top,bottom do
            if x~=left and x~=right and y~=top and y~=bottom then
            elseif isWallCallback(x,y) then
            elseif (x==left or x==right) and not isWallCallback(x+1, y) and not isWallCallback(x-1, y) then
                self:addDoor(x,y)
            elseif (y==top or y==bottom) and not isWallCallback(x, y+1) and not isWallCallback(x, y-1)  then
                self:addDoor(x,y)
            end
        end
    end
    return self
end

--- Write various information about this room to the console.
function Room:debug()
    local door='doors'
    for k,_ in pairs(self._doors) do door=door..'; '..k end
    local debugString= 'room    : '..(self._x1 and self._x1 or 'not available')
                              ..','..(self._y1 and self._y1 or 'not available')
                              ..','..(self._x2 and self._x2 or 'not available')
                              ..','..(self._y2 and self._y2 or 'not available')
                              ..','..door
    io.write(debugString);io.flush()
end

--- Use two callbacks to confirm room validity.
-- @tparam function isWallCallback A function with two parameters (x, y) that will return true if x, y represents a wall space in a map.
-- @tparam function canBeDugCallback A function with two parameters (x, y) that will return true if x, y represents a map cell that can be made into floorspace.
-- @treturn boolean true if room is valid.
function Room:isValid(isWallCallback, canBeDugCallback)
    local left  =self._x1-1
    local right =self._x2+1
    local top   =self._y1-1
    local bottom=self._y2+1
    for x=left,right do
        for y=top,bottom do
            if x==left or x==right or y==top or y==bottom then
                if not isWallCallback(x, y) then return false end
            else
                if not canBeDugCallback(x, y) then return false end
            end
        end
    end
    return true
end

--- Create.
-- Function runs a callback to dig the room into a map
-- @tparam function digCallback The function responsible for digging the room into a map.
function Room:create(digCallback)
    local left  =self._x1-1
    local top   =self._y1-1
    local right =self._x2+1
    local bottom=self._y2+1
    local value=0
    for x=left,right do
        for y=top,bottom do
            if self._doors[x..','..y] then
                value=2
            elseif x==left or x==right or y==top or y==bottom then
                value=1
            else
                value=0
            end
            digCallback(x, y, value)
        end
    end
end

--- Get center cell of room
-- @treturn table {x-position, y-position}
function Room:getCenter()
    return {math.round((self._x1+self._x2)/2),
            math.round((self._y1+self._y2)/2)}
end

--- Get Left most floor space.
-- @treturn int left-most floor
function Room:getLeft()   return self._x1 end
--- Get right-most floor space.
-- @treturn int right-most floor
function Room:getRight()  return self._x2 end
--- Get top most floor space.
-- @treturn int top-most floor
function Room:getTop()    return self._y1 end
--- Get bottom-most floor space.
-- @treturn int bottom-most floor
function Room:getBottom() return self._y2 end

return Room
