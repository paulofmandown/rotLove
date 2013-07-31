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
function DijkstraMap:__init(goalX, goalY, mapWidth, mapHeight, passableCallback)
    self._map={}
    self._goal={}
    self._goal.x=goalX
    self._goal.y=goalY

    self._dimensions={}
    self._dimensions.w=mapWidth
    self._dimensions.h=mapHeight

    self._passableCallback=passableCallback
end

--- Establish values for all cells in map.
-- call after DijkstraMap:new(goalX, goalY, mapWidth, mapHeight, passableCallback)
function DijkstraMap:compute()
    for i=1,self._dimensions.w do
        self._map[i]={}
        for j=1,self._dimensions.h do
            self._map[i][j]=math.huge
        end
    end
    self._map[self._goal.x][self._goal.y]=0

    local val=1
    local wq={}
    local pq={}
    local ds=ROT.DIRS.EIGHT

    table.insert(wq, {self._goal.x, self._goal.y})

    while true do
        while #wq>0 do
            local t=table.remove(wq,1)
            for _,d in pairs(ds) do
                local x=t[1]+d[1]
                local y=t[2]+d[2]
                if self._passableCallback(x,y) and self._map[x][y]>val then
                    self._map[x][y]=val
                    table.insert(pq,{x,y})
                end
            end
        end
        if #pq<1 then break end
        val=val+1
        while #pq>0 do table.insert(wq, table.remove(pq)) end
    end
end

--- Get Width of map.
-- @treturn int w width of map
function DijkstraMap:getWidth() return self._dimensions.w end

--- Get Height of map.
-- @treturn int h height of map
function DijkstraMap:getHeight() return self._dimensions.h end

--- Get Dimensions as table.
-- @treturn table dimensions A table of width and height values
  -- @treturn int dimensions.w width of map
  -- @treturn int dimensions.h height of map
function DijkstraMap:getDimensions() return self._dimensions end

--- Get the map table.
-- @treturn table map A 2d array of map values, access like map[x][y]
function DijkstraMap:getMap() return self._map end

--- Get the x-value of the goal cell.
-- @treturn int x x-value of goal cell
function DijkstraMap:getGoalX() return self._goal.x end

--- Get the y-value of the goal cell.
-- @treturn int y y-value of goal cell
function DijkstraMap:getGoalY() return self._goal.y end

--- Get the goal cell as a table.
-- @treturn table goal table containing goal position
  -- @treturn int goal.x x-value of goal cell
function DijkstraMap:getGoal() return self._goal end

--- Set the goal position.
-- Use compute after to calculate a new map without creating a whole new object
-- @tparam int x the new x-value of the goal cell
-- @tparam int y the new y-value of the goal cell
function DijkstraMap:setGoal(x, y)
    self._goal.x=x and x or self._goal.x
    self._goal.y=y and y or self._goal.y
end

--- Get the direction of the goal from a given position
-- @tparam int x x-value of current position
-- @tparam int y y-value of current position
-- @treturn int xDir X-Direction towards goal. Either -1, 0, or 1
-- @treturn int yDir Y-Direction towards goal. Either -1, 0, or 1
function DijkstraMap:dirTowardsGoal(x, y)
    local low=self._map[x][y]
    if low==0 then return nil end
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

    if dir then return dir[1],dir[2] end
    return nil
end

--- Run a callback function on every cell in the map
-- @tparam function callback A function with x and y parameters that will be run on every cell in the map
function DijkstraMap:iterateThroughMap(callback)
    for y=1,self._dimensions.h do
        for x=1,self._dimensions.w do
            callback(x,y)
        end
    end
end

return DijkstraMap
