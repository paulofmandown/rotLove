--- Corridor object.
-- Used by ROT.Map.Uniform and ROT.Map.Digger to create maps
-- @module ROT.Map.Corridor
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Corridor = ROT.Map.Feature:extend("Corridor")
--- Constructor.
-- Called with ROT.Map.Corridor:new()
-- @tparam int startX x-position of first floospace in corridor
-- @tparam int startY y-position of first floospace in corridor
-- @tparam int endX x-position of last floospace in corridor
-- @tparam int endY y-position of last floospace in corridor
function Corridor:init(startX, startY, endX, endY)
    self._startX       =startX
    self._startY       =startY
    self._endX         =endX
    self._endY         =endY
    self._endsWithAWall=true
end

--- Create random with position.
-- @tparam int x x-position of first floospace in corridor
-- @tparam int y y-position of first floospace in corridor
-- @tparam int dx x-direction of corridor (-1, 0, 1) for (left, none, right)
-- @tparam int dy y-direction of corridor (-1, 0, 1) for (up, none, down)
-- @tparam table options Options
  -- @tparam table options.corridorLength a table for the min and max corridor lengths {min, max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function Corridor:createRandomAt(x, y, dx, dy, options, rng)
    rng=rng and rng or math.random
    local min   =options.corridorLength[1]
    local max   =options.corridorLength[2]
    local length=math.floor(rng:random(min, max))
    return Corridor:new(x, y, x+dx*length, y+dy*length):setRNG(rng)
end

--- Write various information about this corridor to the console.
function Corridor:debug()
    local debugString= 'corridor: '..self._startX..','..self._startY..','..self._endX..','..self._endY
    io.write(debugString);io.flush()
end

--- Use two callbacks to confirm corridor validity.
-- @tparam function isWallCallback A function with two parameters (x, y) that will return true if x, y represents a wall space in a map.
-- @tparam function canBeDugCallback A function with two parameters (x, y) that will return true if x, y represents a map cell that can be made into floorspace.
-- @treturn boolean true if corridor is valid.
function Corridor:isValid(isWallCallback, canBeDugCallback)
    local sx    =self._startX
    local sy    =self._startY
    local dx    =self._endX-sx
    local dy    =self._endY-sy
    local length=1+math.max(math.abs(dx), math.abs(dy))

    if dx~=0 then dx=dx/math.abs(dx) end
    if dy~=0 then dy=dy/math.abs(dy) end
    local nx=dy
    local ny=-dx

    local ok=true

    for i=0,length-1 do
        local x=sx+i*dx
        local y=sy+i*dy

        if not canBeDugCallback(x,    y) then ok=false end
        if not isWallCallback  (x+nx, y+ny) then ok=false end
        if not isWallCallback  (x-nx, y-ny) then ok=false end

        if not ok then
            length=i
            self._endX=x-dx
            self._endY=y-dy
            break
        end
    end

    if length==0 then return false end
    if length==1 and isWallCallback(self._endX+dx, self._endY+dy) then return false end

    local firstCornerBad=not isWallCallback(self._endX+dx+nx, self._endY+dy+ny)
    local secondCornrBad=not isWallCallback(self._endX+dx-nx, self._endY+dy-ny)
    self._endsWithAWall =    isWallCallback(self._endX+dx   , self._endY+dy   )
    if (firstCornerBad or secondCornrBad) and self._endsWithAWall then return false end

    return true
end

--- Create.
-- Function runs a callback to dig the corridor into a map
-- @tparam function digCallback The function responsible for digging the corridor into a map.
function Corridor:create(digCallback)
    local sx    =self._startX
    local sy    =self._startY
    local dx    =self._endX-sx
    local dy    =self._endY-sy

    local length=1+math.max(math.abs(dx), math.abs(dy))
    if dx~=0 then dx=dx/math.abs(dx) end
    if dy~=0 then dy=dy/math.abs(dy) end

    for i=0,length-1 do
        local x=sx+i*dx
        local y=sy+i*dy
        digCallback(x, y, 0)
    end
    return true
end

--- Mark walls as priority for a future feature.
-- Use this for storing the three points at the end of the corridor that you probably want to make sure gets a room attached.
-- @tparam userdata gen The map generator calling this function. Passed as self to the digCallback
-- @tparam function priorityWallCallback The function responsible for receiving and processing the priority walls
function Corridor:createPriorityWalls(priorityWallCallback)
    if not self._endsWithAWall then return end

    local sx    =self._startX
    local sy    =self._startY
    local dx    =self._endX-sx
    local dy    =self._endY-sy

    if dx~=0 then dx=dx/math.abs(dx) end
    if dy~=0 then dy=dy/math.abs(dy) end
    local nx=dy
    local ny=-dx

    priorityWallCallback(self._endX+dx, self._endY+dy)
    priorityWallCallback(self._endX+nx, self._endY+ny)
    priorityWallCallback(self._endX-nx, self._endY-ny)
end

return Corridor
