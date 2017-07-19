--- Bresenham Based Ray-Casting FOV calculator.
-- See http://en.wikipedia.org/wiki/Bresenham's_line_algorithm.
-- Included for sake of having options. Provides three functions for computing FOV
-- @module ROT.FOV.Bresenham
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Bresenham=ROT.FOV:extend("Bresenham")
--- Constructor.
-- Called with ROT.FOV.Bresenham:new()
-- @tparam function lightPassesCallback A function with two parameters (x, y) that returns true if a map cell will allow light to pass through
-- @tparam table options Options
  -- @tparam int options.topology Direction for light movement Accepted values: (4 or 8)
  -- @tparam boolean options.useDiamond If true, the FOV will be a diamond shape as opposed to a circle shape.
function Bresenham:init(lightPassesCallback, options)
    Bresenham.super.init(self, lightPassesCallback, options)
end

--- Compute.
-- Get visibility from a given point.
-- This method cast's rays from center to points on a circle with a radius 3-units longer than the provided radius.
-- A list of cell's within the radius is kept. This list is checked at the end to verify that each cell has been passed to the callback.
-- @tparam int cx x-position of center of FOV
-- @tparam int cy y-position of center of FOV
-- @tparam int r radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam number callback.visibility The cell's visibility rating (from 0-1). How well can you see this cell?
function Bresenham:compute(cx, cy, r, callback)
    local notvisited={}
    for x=-r,r do
        for y=-r,r do
            notvisited[ROT.Point(cx+x, cy+y):hashCode()]={cx+x, cy+y}
        end
    end

    callback(cx,cy,1,1)
    notvisited[ROT.Point(cx, cy):hashCode()]=nil

    local thePoints=self:_getCircle(cx, cy, r+3)
    for _,p in pairs(thePoints) do
        local x,y=p[1],p[2]
        local line=ROT.Line(cx,cy,x, y):getPoints()
        for i=2,#line.points do
            local point=line.points[i]
            if self:_oob(cx-point.x, cy-point.y, r) then break end
            if notvisited[point:hashCode()] then
                callback(point.x, point.y, i, 1-(i/r))
                notvisited[point:hashCode()]=nil
            end
            if not self:_lightPasses(point.x, point.y) then
                break
            end
        end
    end

    for _,v in pairs(notvisited) do
        local x,y=v[1],v[2]
        local line=ROT.Line(cx,cy,x, y):getPoints()
        for i=2,#line.points do
            local point=line.points[i]
            if self:_oob(cx-point.x, cy-point.y, r) then break end
            if notvisited[point:hashCode()] then
                callback(point.x, point.y, i, 1-(i/r))
                notvisited[point:hashCode()]=nil
            end
            if not self:_lightPasses(point.x, point.y) then
                break
            end
        end
    end

end

--- Compute Thorough.
-- Get visibility from a given point.
-- This method cast's rays from center to every cell within the given radius.
-- This method is much slower, but is more likely to not generate any anomalies within the field.
-- @tparam int cx x-position of center of FOV
-- @tparam int cy y-position of center of FOV
-- @tparam int r radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam number callback.visibility The cell's visibility rating (from 0-1). How well can you see this cell?
function Bresenham:computeThorough(cx, cy, r, callback)
    local visited={}
    callback(cx,cy,r)
    visited[ROT.Point(cx, cy):hashCode()]=0
    for x=-r,r do for y=-r,r do
        local line=ROT.Line(cx,cy,x+cx, y+cy):getPoints()
        for i=2,#line.points do
            local point=line.points[i]
            if self:_oob(cx-point.x, cy-point.y, r) then break end
            if not visited[point:hashCode()] then
                callback(point.x, point.y, r)
                visited[point:hashCode()]=0
            end
            if not self:_lightPasses(point.x, point.y) then
                break
            end
        end
    end end
end

--- Compute Thorough.
-- Get visibility from a given point. The quickest method provided.
-- This method cast's rays from center to points on a circle with a radius 3-units longer than the provided radius.
-- Unlike compute() this method stops at that point. It will likely miss cell's for fields with a large radius.
-- @tparam int cx x-position of center of FOV
-- @tparam int cy y-position of center of FOV
-- @tparam int r radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam number callback.visibility The cell's visibility rating (from 0-1). How well can you see this cell?
function Bresenham:computeQuick(cx, cy, r, callback)
    local visited={}
    callback(cx,cy,1, 1)
    visited[ROT.Point(cx, cy):hashCode()]=0

    local thePoints=self:_getCircle(cx, cy, r+3)
    for _,p in pairs(thePoints) do
        local x,y=p[1],p[2]
        local line=ROT.Line(cx,cy,x, y):getPoints()
        for i=2,#line.points do
            local point=line.points[i]
            if self:_oob(cx-point.x, cy-point.y, r) then break end
            if not visited[point:hashCode()] then
                callback(point.x, point.y, i, 1-(i*i)/(r*r))
                visited[point:hashCode()]=0
            end
            if not self:_lightPasses(point.x, point.y) then
                break
            end
        end
    end
end

function Bresenham:_oob(x, y, r)
    if not self._options.useDiamond then
        local ab=((x*x)+(y*y))
        local c =(r*r)
        return ab > c
    else
        return math.abs(x)+math.abs(y)>r
    end
end

return Bresenham
