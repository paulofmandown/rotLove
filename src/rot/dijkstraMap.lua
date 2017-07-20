--- DijkstraMap Pathfinding.
-- Based on the DijkstraMap Article on RogueBasin, http://roguebasin.roguelikedevelopment.org/index.php?title=The_Incredible_Power_of_Dijkstra_Maps
-- @module ROT.DijkstraMap
local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local DijkstraMap = ROT.Class:extend("DijkstraMap")

--- Constructor.
-- @tparam int goalX x-position of cell that map will 'roll down' to
-- @tparam int goalY y-position of cell that map will 'roll down' to
-- @tparam int mapWidth width of the map
-- @tparam int mapHeight height of the map
-- @tparam function passableCallback a function with two parameters (x, y) that returns true if a map cell is passable
function DijkstraMap:init(goalX, goalY, mapWidth, mapHeight, passableCallback)
    self._map={}
    self._goals={}
    table.insert(self._goals, {x=goalX, y=goalY})

    self._dimensions={}
    self._dimensions.w=mapWidth
    self._dimensions.h=mapHeight

    self._dirs={}
    local d=ROT.DIRS.EIGHT
    self._dirs ={d[1],
                 d[3],
                 d[5],
                 d[7],
                 d[2],
                 d[4],
                 d[6],
                 d[8] }

    self._passableCallback=passableCallback
end

--- Establish values for all cells in map.
-- call after ROT.DijkstraMap:new(goalX, goalY, mapWidth, mapHeight, passableCallback)
function DijkstraMap:compute()
    if #self._goals<1 then return
    elseif #self._goals==1 then return self:_singleGoalCompute()
    else return self:_manyGoalCompute() end
end

function DijkstraMap:_manyGoalCompute()
    local stillUpdating={}
    for i=1,self._dimensions.w do
        self._map[i]={}
        stillUpdating[i]={}
        for j=1,self._dimensions.h do
            stillUpdating[i][j]=true
            self._map[i][j]=math.huge
        end
    end

    for _,v in pairs(self._goals) do
        self._map[v.x][v.y]=0
    end

    local passes=0
    while true do
        local nochange=true
        for i,_ in pairs(stillUpdating) do
            for j,_ in pairs(stillUpdating[i]) do
                if self._passableCallback(i, j) then
                    local cellChanged=false
                    local low=math.huge
                    for _,v in pairs(self._dirs) do
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

function DijkstraMap:_singleGoalCompute()
    local g=self._goals[1]
    for i=1,self._dimensions.w do
        self._map[i]={}
        for j=1,self._dimensions.h do
            self._map[i][j]=math.huge
        end
    end

    self._map[g.x][g.y]=0

    local val=1
    local wq={}
    local pq={}
    local ds=self._dirs

    table.insert(wq, {g.x, g.y})

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

--- Add new goal position.
-- Inserts a new cell to be used as a goal.
-- @tparam int gx the new x-value of the goal cell
-- @tparam int gy the new y-value of the goal cell
function DijkstraMap:addGoal(gx, gy)
    table.insert(self._goals, {x=gx, y=gy})
end

--- Remove all goals.
-- Will delete all goal cells. You must insert another goal before computing.
-- You can specify one goal to be inserted after the goal remove takes place.
-- The method only checks that the coordinates are provided before setting the new goal cell.
-- @tparam[opt=nil] int gx Will use this value as the x-coordinate of a new goal cell to be inserted
-- @tparam[opt=nil] int gy Will use this value as the y-coordinate of a new goal cell to be inserted
function DijkstraMap:removeGoals(gx, gy)
    while table.remove(self._goals) do end
    if gx and gy then table.insert(self._goals, {x=gx, y=gy}) end
end

--- Output map values to console.
-- For debugging, will send a comma separated output of cell values to the console.
-- @tparam boolean[opt=false] returnString Will return the output in addition to sending it to console if true.
function DijkstraMap:writeMapToConsole(returnString)
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

--- Get the goal cell as a table.
-- @treturn table goal table containing goal position
  -- @treturn int goal.x x-value of goal cell
function DijkstraMap:getGoals() return self._goals end

--- Get the direction of the goal from a given position
-- @tparam int x x-value of current position
-- @tparam int y y-value of current position
-- @treturn int xDir X-Direction towards goal. Either -1, 0, or 1
-- @treturn int yDir Y-Direction towards goal. Either -1, 0, or 1
function DijkstraMap:dirTowardsGoal(x, y)
    local low=self._map[x][y]
    if low==0 then return nil end
    local dir=nil
    for _,v in pairs(self._dirs) do
        local tx=(x+v[1])
        local ty=(y+v[2])
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
