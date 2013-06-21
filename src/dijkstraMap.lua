--- DijkstraMap Pathfinding.
-- Based on the DijkstraMap Article on RogueBasin, http://roguebasin.roguelikedevelopment.org/index.php?title=The_Incredible_Power_of_Dijkstra_Maps
-- @module ROT.DijkstraMap
local DijkstraMap_PATH=({...})[1]:gsub("[%.\\/]dijkstraMap$", "") .. '/'
local class  =require (DijkstraMap_PATH .. 'vendor/30log')

local DijkstraMap=class {  }

--- Constructor.
-- @tparam int goalX x-position of cell that map will 'roll down' to
-- @tparam int goalY y-position of cell that map will 'roll down' to
-- @tparam int mapWidth width of the map
-- @tparam int mapHeight height of the map
-- @tparam function passableCallback a function with two parameters (x, y) that returns true if a map cell is passable
function DijkstraMap(goalX, goalY, mapWidth, mapHeight, passableCallback)
    self._map={}
    self._goal={}
    self._goal.x=x
    self._goal.y=y

    self._dimensions={}
    self._dimensions.w=mapWidth
    self._dimensions.h=mapHeight

    self._passableCallback=passableCallback
end

--- Establish values for all cells in map.
-- call after DijkstraMap:new(goalX, goalY, mapWidth, mapHeight, passableCallback)
function DijkstraMap:compute()
    local stillUpdating={}
    for i=1,self._dimensions.w do
        if not self._map[i] then self._map[i]={} end
        stillUpdating[i]={}
        for j=1,self._dimensions.h do
            stillUpdating[i][j]=true
            self._map[i][j]=1000
        end
    end
    self._map[self._goal.x][self._goal.y]=0

    local passes=0
    while true do
        local nochange=true
        for i,_ in pairs(stillUpdating) do
            for j,_ in pairs(stillUpdating[i]) do
                if self._passableCallback(i, j) then
                    local cellChanged=false
                    local low=math.huge
                    for k,v in pairs(ROT.DIRS.EIGHT) do
                        local tx=(i+v[1])
                        local ty=(j+v[2])
                        if tx>0 and tx<=self._dimensions.w and ty>0 and ty<=self._dimensions.h then
                            local val=self._map[tx][ty]
                            if val and val<low then
                                low=val
                            end
                        end
                    end

                    if self._map[i][j]>low+2 then
                        self._map[i][j]=low+1
                        cellChanged=true
                        nochange=false
                    end
                    if not cellChanged and self._map[i][j]<1000 then stillUpdating[i][j]=nil end
                else stillUpdating[i][j]=nil end
            end
        end
        passes=passes+1
        if nochange then break end
    end
end

--- Get Width of map.
-- @treturn int w width of map
function dijkstraMap:getWidth() return self._dimensions.w end

--- Get Height of map.
-- @treturn int h height of map
function dijkstraMap:getHeight() return self._dimensions.h end

--- Get Dimensions as table.
-- @treturn table dimensions A table of width and height values
  -- @treturn int dimensions.w width of map
  -- @treturn int dimensions.h height of map
function dijkstraMap:getDimensions() return self._dimensions end

--- Get the map table.
-- @treturn table map A 2d array of map values, access like map[x][y]
function dijkstraMap:getMap() return self._map end

--- Get the x-value of the goal cell.
-- @treturn int x x-value of goal cell
function dijkstraMap:getGoalX() return self._goal.x end

--- Get the y-value of the goal cell.
-- @treturn int y y-value of goal cell
function dijkstraMap:getGoalY() return self._goal.y end

--- Get the goal cell as a table.
-- @treturn table goal table containing goal position
  -- @treturn int goal.x x-value of goal cell
function dijkstraMap:getGoal() return self._goal end

--- Set the goal position.
-- Use compute after to calculate a new map without creating a whole new object
-- @tparam int x the new x-value of the goal cell
-- @tparam int y the new y-value of the goal cell
function dijkstraMap:setGoal(x, y)
    self._goal.x=x
    self._goal.y=y
end

--- Get the direction of the goal from a given position
-- @tparam int x x-value of current position
-- @tparam int y y-value of current position
-- @treturn int xDir X-Direction towards goal. Either -1, 0, or 1
-- @treturn int yDir Y-Direction towards goal. Either -1, 0, or 1
function dijkstraMap:dirTowardsGoal(x, y)
    local low=math.huge
    local key=nil
    local dir=nil
    for k,v in pairs(ROT.DIRS.EIGHT) do
        local tx=(i+v[1])
        local ty=(j+v[2])
        if tx>0 and tx<=self._dimensions.w and ty>0 and ty<=self._dimensions.h then
            local val=self._map[tx][ty]
            if val<low then
                low=val
                dir=v
            end
        end
    end
    if val==0 then return nil end
    return dir[1],dir[2]
end

--- Run a callback function on every cell in the map
-- @tparam function callback A function with x and y parameters that will be run on every cell in the map
function dijkstraMap:iterateThroughMap(callback)
    for y=1,self._dimensions.h do
        for x=1,self._dimensions.w do
            callback(x,y)
        end
    end
end

return DijkstraMap
