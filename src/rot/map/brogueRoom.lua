--- BrogueRoom object.
-- Used by ROT.Map.Brogue to create maps with 'cross rooms'
-- @module ROT.Map.BrogueRoom
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local BrogueRoom = ROT.Map.Room:extend("BrogueRoom")

local PointSet = ROT.Type.PointSet

--- Constructor.
-- creates a new BrogueRoom object with the assigned values
-- @tparam table dims Represents dimensions and positions of the rooms two rectangles
-- @tparam[opt] int doorX x-position of door
-- @tparam[opt] int doorY y-position of door
function BrogueRoom:init(dims, doorX, doorY)
    self._dims = dims
    self._doors = PointSet()
    self._walls = PointSet()
    if doorX then
        self._doors:push(doorX, doorY)
    end
end

--- Create room at bottom center with dims 9x10 and 20x4
-- @tparam int availWidth Typically the width of the map.
-- @tparam int availHeight Typically the height of the map
-- @tparam[opt] userData rng A user defined object with a .random(self, min, max) method
function BrogueRoom:createEntranceRoom(availWidth, availHeight, rng)
    local dims={}
    dims.w1=9
    dims.h1=10
    dims.w2=20
    dims.h2=4

    dims.x1=math.floor(availWidth/2-dims.w1/2)
    dims.y1=math.floor(availHeight-dims.h1-1)
    dims.x2=math.floor(availWidth/2-dims.w2/2)
    dims.y2=math.floor(availHeight-dims.h2-1)

    return BrogueRoom:new(dims):setRNG(rng)
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
function BrogueRoom:createRandomAt(x, y, dx, dy, options, rng)
    rng = rng or self._rng
    local dims={}

    local min=options.roomWidth[1]
    local max=options.roomWidth[2]
    dims.w1=math.floor(rng:random(min,max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    dims.h1=math.floor(rng:random(min,max))

    min=options.crossWidth[1]
    max=options.crossWidth[2]
    dims.w2=math.floor(rng:random(min,max))

    min=options.crossHeight[1]
    max=options.crossHeight[2]
    dims.h2=math.floor(rng:random(min,max))

    if dx==1 then
        -- wider rect gets x+1
        -- wider gets y-math.floor(rng:random()*widersHeight)
        if dims.w1>dims.w2 then
            dims.x1=x+1
            dims.y1=y-math.floor(rng:random()*dims.h1)
            dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
            dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
        else
            dims.x2=x+1
            dims.y2=y-math.floor(rng:random()*dims.h2)
            dims.x1=math.floor(rng:random(dims.x2, (dims.x2+dims.w2)-dims.w1))
            dims.y1=math.floor(rng:random(dims.y2, (dims.y2+dims.h2)-dims.h1))
        end
    elseif dx==-1 then
        -- wider rect gets x-widersWidth
        -- wider gets y-math.floor(rng:random()*widersHeight)
        if dims.w1>dims.w2 then
            dims.x1=x-dims.w1-1
            dims.y1=y-math.floor(rng:random()*dims.h1)
            dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
            dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
        else
            dims.x2=x-dims.w2-1
            dims.y2=y-math.floor(rng:random()*dims.h2)
            dims.x1=math.floor(rng:random(dims.x2, (dims.x2+dims.w2)-dims.w1))
            dims.y1=math.floor(rng:random(dims.y2, (dims.y2+dims.h2)-dims.h1))
        end
    elseif dy==1 then
        -- taller gets y+1
        -- taller gets x-math.floor(rng:random()*width)
        if dims.h1>dims.h2 then
            dims.y1=y+1
            dims.x1=x-math.floor(rng:random()*dims.w1)
            dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
            dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
        else
            dims.y2=y+1
            dims.x2=x-math.floor(rng:random()*dims.w2)
            dims.x1=math.floor(rng:random(dims.x2, (dims.x2+dims.w2)-dims.w1))
            dims.y1=math.floor(rng:random(dims.y2, (dims.y2+dims.h2)-dims.h1))
        end
    elseif dy==-1 then
        -- taller gets y-tallersHeight
        -- taller gets x-math.floor(rng:random()*width)
        if dims.h1>dims.h2 then
            dims.y1=y-dims.h1-1
            dims.x1=x-math.floor(rng:random()*dims.w1)
            dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
            dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
        else
            dims.y2=y-dims.h2-1
            dims.x2=x-math.floor(rng:random()*dims.w2)
            dims.x1=math.floor(rng:random(dims.x2, (dims.x2+dims.w2)-dims.w1))
            dims.y1=math.floor(rng:random(dims.y2, (dims.y2+dims.h2)-dims.h1))
        end
    else
        assert(false, 'dx or dy must be 1 or -1')
    end
    --if dims.x2~=dims.x2 then dims.x2=dims.x1 end
    --if dims.y2~=dims.y2 then dims.y2=dims.y1 end
    --if dims.x1~=dims.x1 then dims.x1=dims.x2 end
    --if dims.y1~=dims.y1 then dims.y1=dims.y2 end
    return BrogueRoom:new(dims, x, y):setRNG(rng)
end

--- Create Random with center position.
-- @tparam int cx x-position of room's center
-- @tparam int cy y-position of room's center
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for room {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for room {min,max}
  -- @tparam table options.crossWidth minimum/maximum width for rectangleTwo {min,max}
  -- @tparam table options.crossHeight minimum/maximum height for rectangleTwo {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function BrogueRoom:createRandomCenter(cx, cy, options, rng)
    rng = rng or self._rng
    local dims={}
    --- Generate Rectangle One dimensions
    local min=options.roomWidth[1]
    local max=options.roomWidth[2]
    dims.w1=math.floor(rng:random(min,max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    dims.h1=math.floor(rng:random(min,max))

    dims.x1=cx-math.floor(rng:random()*dims.w1)
    dims.y1=cy-math.floor(rng:random()*dims.h1)

    --- Generate Rectangle Two dimensions
    min=options.roomWidth[1]
    max=options.roomWidth[2]
    dims.w2=math.floor(rng:random(min,max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    dims.h2=math.floor(rng:random(min,max))

    dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
    dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
    if dims.x2~=dims.x2 then dims.x2=dims.x1 end
    if dims.y2~=dims.y2 then dims.y2=dims.y1 end

    return BrogueRoom:new(dims):setRNG(rng)
end

--- Create random with no position.
-- @tparam int availWidth Typically the width of the map.
-- @tparam int availHeight Typically the height of the map
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for rectangleOne {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for rectangleOne {min,max}
  -- @tparam table options.crossWidth minimum/maximum width for rectangleTwo {min,max}
  -- @tparam table options.crossHeight minimum/maximum height for rectangleTwo {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function BrogueRoom:createRandom(availWidth, availHeight, options, rng)
    rng = rng or self._rng
    local dims={}
    --- Generate Rectangle One dimensions
    local min=options.roomWidth[1]
    local max=options.roomWidth[2]
    dims.w1=math.floor(rng:random(min,max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    dims.h1=math.floor(rng:random(min,max))

    -- Consider moving these to aw-(w1+w2) and ah-(h1+h2)
    local left=availWidth-dims.w1
    local top=availHeight-dims.h1

    dims.x1=math.floor(rng:random()*left)
    dims.y1=math.floor(rng:random()*top)

    --- Generate Rectangle Two dimensions
    min=options.crossWidth[1]
    max=options.crossWidth[2]
    dims.w2=math.floor(rng:random(min,max))

    min=options.crossHeight[1]
    max=options.crossHeight[2]
    dims.h2=math.floor(rng:random(min,max))

    dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
    dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
    if dims.x2~=dims.x2 then dims.x2=dims.x1 end
    if dims.y2~=dims.y2 then dims.y2=dims.y1 end
    return BrogueRoom:new(dims):setRNG(rng)
end

--- Use two callbacks to confirm room validity.
-- @tparam function isWallCallback A function with two parameters (x, y) that will return true if x, y represents a wall space in a map.
-- @tparam function canBeDugCallback A function with two parameters (x, y) that will return true if x, y represents a map cell that can be made into floorspace.
-- @treturn boolean true if room is valid.
function BrogueRoom:isValid(isWallCallback, canBeDugCallback)
    local dims=self._dims
    if dims.x2~=dims.x2 or dims.y2~=dims.y2 or dims.x1~=dims.x1 or dims.y1~=dims.y1  then
        return false
    end

    local left  =self:getLeft()-1
    local right =self:getRight()+1
    local top   =self:getTop()-1
    local bottom=self:getBottom()+1
    for x=left,right do
        for y=top,bottom do
            if self:_coordIsFloor(x, y) then
                if not isWallCallback(x, y) or not canBeDugCallback(x, y) then
                    return false
                end
            elseif self:_coordIsWall(x, y) then
                self._walls:push(x, y)
            end
        end
    end

    return true
end

--- Create.
-- Function runs a callback to dig the room into a map
-- @tparam function digCallback The function responsible for digging the room into a map.
function BrogueRoom:create(digCallback)
    local value=0
    local left  =self:getLeft()-1
    local right =self:getRight()+1
    local top   =self:getTop()-1
    local bottom=self:getBottom()+1
    for x=left,right do
        for y=top,bottom do
            if self._doors:find(x, y) then
                value=2
            elseif self:_coordIsFloor(x, y) then
                value=0
            else
                value=1
            end
            digCallback(x, y, value)
        end
    end
end

function BrogueRoom:_coordIsFloor(x, y)
    local d=self._dims
    if x>=d.x1 and x<=d.x1+d.w1 and y>=d.y1 and y<=d.y1+d.h1 then
        return true
    elseif x>=d.x2 and x<=d.x2+d.w2 and y>=d.y2 and y<=d.y2+d.h2 then
        return true
    end
    return false
end

function BrogueRoom:_coordIsWall(x, y)
    local dirs=ROT.DIRS.EIGHT
    for i=1,#dirs do
        local dir=dirs[i]
        if self:_coordIsFloor(x+dir[1], y+dir[2]) then return true end
    end
    return false
end

function BrogueRoom:getLeft()   return math.min(self._dims.x1, self._dims.x2) end
function BrogueRoom:getRight()  return math.max(self._dims.x1+self._dims.w1, self._dims.x2+self._dims.w2) end
function BrogueRoom:getTop()    return math.min(self._dims.y1, self._dims.y2) end
function BrogueRoom:getBottom() return math.max(self._dims.y1+self._dims.h1, self._dims.y2+self._dims.h2) end

function BrogueRoom:debug()
    local str=''
    for k,v in pairs(self._dims) do
        str=str..k..'='..v..','
    end
    io.write(str);io.flush()
end

function BrogueRoom:_checkHorizontalEdge(isWallCallback, x, y)
    return self._walls:find(x, y)
        and self._walls:find(x - 1, y)
        and self._walls:find(x + 1, y)
        -- and isWallCallback(x - 1, y)
        -- and isWallCallback(x + 1, y)
end

function BrogueRoom:_checkVerticalEdge(isWallCallback, x, y)
    return self._walls:find(x, y)
        and self._walls:find(x, y - 1)
        and self._walls:find(x, y + 1)
        -- and isWallCallback(x, y - 1)
        -- and isWallCallback(x, y + 1)
end

return BrogueRoom

