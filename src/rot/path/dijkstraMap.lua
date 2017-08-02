--- DijkstraMap Pathfinding.
-- Based on the DijkstraMap Article on RogueBasin, http://roguebasin.roguelikedevelopment.org/index.php?title=The_Incredible_Power_of_Dijkstra_Maps
-- @module ROT.DijkstraMap
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local DijkstraMap = ROT.Path:extend("DijkstraMap")

--- Constructor.
-- @tparam int goalX x-position of cell that map will 'roll down' to
-- @tparam int goalY y-position of cell that map will 'roll down' to
-- @tparam function passableCallback a function with two parameters (x, y) that returns true if a map cell is passable
-- @tparam table options Options
  -- @tparam[opt=8] int options.topology Directions for movement Accepted values (4 or 8)
function DijkstraMap:init(goalX, goalY, passableCallback, options)
    DijkstraMap.super.init(self, goalX, goalY, passableCallback, options)
    self._map={}
    self._goals={}
    self._dirty = true
    if goalX and goalY then
        self:addGoal(goalX, goalY)
    end
end

--- Establish values for all cells in map.
-- call after ROT.DijkstraMap:new(goalX, goalY, passableCallback)
function DijkstraMap:compute(x, y, callback, topology)
    self:_rebuild()
    local dx, dy = self:dirTowardsGoal(x, y, topology)
    if dx then
        callback(x, y)
    end
    while dx do
        x, y = x + dx, y + dy
        callback(x, y)
        dx, dy = self:dirTowardsGoal(x, y, topology)
    end
end

--- Run a callback function on every cell in the map
-- @tparam function callback A function with x and y parameters that will be run on every cell in the map
function DijkstraMap:create(callback)
    self:_rebuild()
    for i = 1, #self._allCells, 2 do
        local x, y = self._allCells[i], self._allCells[i + 1]
        callback(x, y, self._map[x][y])
    end
end

--- Check if a goal exists at a position.
-- @tparam int x the x-value to check
-- @tparam int y the y-value to check
function DijkstraMap:hasGoal(x, y)
    return not not self:_getGoalIndex(x, y)
end

--- Add new goal.
-- @tparam int x the x-value of the new goal cell
-- @tparam int y the y-value of the new goal cell
function DijkstraMap:addGoal(x, y)
    if not self:_getGoalIndex(x, y) then
        local n = #self._goals
        self._goals[n + 1], self._goals[n + 2] = x, y
        self._dirty = true
    end
    return self
end

local function removePair(t, i)
    local n, x, y = #t, t[i], t[i + 1]
    t[i], t[i + 1] = t[n - 1], t[n]
    t[n - 1], t[n] = nil, nil
    return x, y
end

--- Remove a goal.
-- @tparam int gx the x-value of the goal cell
-- @tparam int gy the y-value of the goal cell
function DijkstraMap:removeGoal(x, y)
    local i = self:_getGoalIndex(x, y)
    if i then
        removePair(self._goals, i)
        self._dirty = true
    end
    return self
end

--- Remove all goals.
function DijkstraMap:clearGoals()
    self._goals = {}
    self._dirty = true
    return self
end

--- Get the direction of the goal from a given position
-- @tparam int x x-value of current position
-- @tparam int y y-value of current position
-- @treturn int xDir X-Direction towards goal. Either -1, 0, or 1
-- @treturn int yDir Y-Direction towards goal. Either -1, 0, or 1
function DijkstraMap:dirTowardsGoal(x, y, topology)
    local low = self._map[x] and self._map[x][y]
    if not low or low == 0 or low == math.huge then return end
    local dir=nil
    for i = 1, topology or self._options.topology do
        local v = ROT.DIRS.FOUR[i] or ROT.DIRS.EIGHT[(i - 4) * 2]
        local tx=(x+v[1])
        local ty=(y+v[2])
        local val = self._map[tx] and self._map[tx][ty]
        if val and i < 5 and val <= low or val < low then
            low=val
            dir=v
        end
    end
    if dir then return dir[1],dir[2] end
end

--- Output map values to console.
-- For debugging, will send a comma separated output of cell values to the console.
-- @tparam boolean[opt=false] returnString Will return the output in addition to sending it to console if true.
function DijkstraMap:debug(returnString)
    self:_rebuild()
    local ls

    if returnString then ls='' end
    for y=1,self._dimensions.h do
        local s=''
        for x=1,self._dimensions.w do
            s=s..self._map[x][y]..','
        end
        io.write(s); io.flush()
        if returnString then ls=ls..s..'\n' end
    end
    if returnString then return ls end
end

function DijkstraMap:_getGoalIndex(x, y)
    for i = 1, #self._goals, 2 do
        if self._goals[i] == x and self._goals[i + 1] == y then
            return i
        end
    end
end

function DijkstraMap:_addCell(x, y, value)
    if not self._map[x] then self._map[x] = {} end
    local nc, ac = #self._nextCells, #self._allCells
    self._nextCells[nc + 1], self._nextCells[nc + 2] = x, y
    self._allCells[ac + 1], self._allCells[ac + 2] = x, y
    self._map[x][y] = value
    return value
end

function DijkstraMap:_visitAdjacent(x, y)
    if not self._passableCallback(x, y) then return end
    
    local low = math.huge
    
    for i = 1, #self._dirs do
        local tx = x + self._dirs[i][1]
        local ty = y + self._dirs[i][2]
        local value = self._map[tx] and self._map[tx][ty]
            or self:_addCell(tx, ty, math.huge)
        
        low = math.min(low, value)
    end
    
    if self._map[x][y] > low + 2 then
        self._map[x][y] = low + 1
    end
end

function DijkstraMap:_rebuild(callback)
    if not self._dirty then return end
    self._dirty = false

    self._nextCells = {}
    self._allCells = {}
    self._map = {}

    for i = 1, #self._goals, 2 do
        self:_addCell(self._goals[i], self._goals[i + 1], 0)
    end

    while #self._nextCells > 0 do
        for i = #self._nextCells - 1, 1, -2 do
            local x, y = removePair(self._nextCells, i)
            self:_visitAdjacent(x, y)
        end
    end
end

return DijkstraMap

