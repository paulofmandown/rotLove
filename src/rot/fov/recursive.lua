--- Recursive Shadowcasting Field of View calculator.
-- The Recursive shadow casting algorithm developed by Ondřej Žára for rot.js.
-- See http://roguebasin.roguelikedevelopment.org/index.php?title=Recursive_Shadowcasting_in_JavaScript
-- @module ROT.FOV.Recursive
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Recursive=ROT.FOV:extend("Recursive")
--- Constructor.
-- Called with ROT.FOV.Recursive:new()
-- @tparam function lightPassesCallback A function with two parameters (x, y) that returns true if a map cell will allow light to pass through
-- @tparam table options Options
  -- @tparam int options.topology Direction for light movement Accepted values: (4 or 8)
function Recursive:init(lightPassesCallback, options)
    Recursive.super.init(self, lightPassesCallback, options)
end

 Recursive._octants = {
    {-1,  0,  0,  1},
    { 0, -1,  1,  0},
    { 0, -1, -1,  0},
    {-1,  0,  0, -1},
    { 1,  0,  0, -1},
    { 0,  1, -1,  0},
    { 0,  1,  1,  0},
    { 1,  0,  0,  1}
}

--- Compute.
-- Get visibility from a given point
-- @tparam int x x-position of center of FOV
-- @tparam int y y-position of center of FOV
-- @tparam int R radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam boolean callback.visibility Indicates if the cell is seen
function Recursive:compute(x, y, R, callback)
    callback(x, y, 0, true)
    for i=1,#self._octants do
        self:_renderOctant(x,y,self._octants[i], R, callback)
    end
end

--- Compute 180.
-- Get visibility from a given point for a 180 degree arc
-- @tparam int x x-position of center of FOV
-- @tparam int y y-position of center of FOV
-- @tparam int R radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam int dir viewing direction (use ROT.DIR index for values)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam boolean callback.visibility Indicates if the cell is seen
function Recursive:compute180(x, y, R, dir, callback)
    callback(x, y, 0, true)
    local prev=((dir-2+8)%8)+1
    local nPre=((dir-3+8)%8)+1
    local next=((dir  +8)%8)+1

    self:_renderOctant(x, y, self._octants[nPre], R, callback)
    self:_renderOctant(x, y, self._octants[prev], R, callback)
    self:_renderOctant(x, y, self._octants[dir ], R, callback)
    self:_renderOctant(x, y, self._octants[next], R, callback)
end
--- Compute 90.
-- Get visibility from a given point for a 90 degree arc
-- @tparam int x x-position of center of FOV
-- @tparam int y y-position of center of FOV
-- @tparam int R radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam int dir viewing direction (use ROT.DIR index for values)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam boolean callback.visibility Indicates if the cell is seen
function Recursive:compute90(x, y, R, dir, callback)
    callback(x, y, 0, true)
    local prev=((dir-2+8)%8)+1

    self:_renderOctant(x, y, self._octants[dir ], R, callback)
    self:_renderOctant(x, y, self._octants[prev], R, callback)
end

function Recursive:_renderOctant(x, y, octant, R, callback)
    self:_castVisibility(x, y, 1, 1.0, 0.0, R + 1, octant[1], octant[2], octant[3], octant[4], callback)
end

function Recursive:_castVisibility(startX, startY, row, visSlopeStart, visSlopeEnd, radius, xx, xy, yx, yy, callback)
    if visSlopeStart<visSlopeEnd then return end
    for i=row,radius do
        local dx=-i-1
        local dy=-i
        local blocked=false
        local newStart=0

        while dx<=0 do
            dx=dx+1
            local slopeStart=(dx-0.5)/(dy+0.5)
            local slopeEnd=(dx+0.5)/(dy-0.5)

            if slopeEnd<=visSlopeStart then
                if slopeStart<visSlopeEnd then break end
                local mapX=startX+dx*xx+dy*xy
                local mapY=startY+dx*yx+dy*yy

                if dx*dx+dy*dy<radius*radius then
                    callback(mapX, mapY, i, true)
                end
                if not blocked then
                    if not self:_lightPasses(mapX, mapY) and i<radius then
                        blocked=true
                        self:_castVisibility(startX, startY, i+1, visSlopeStart, slopeStart, radius, xx, xy, yx, yy, callback)
                        newStart=slopeEnd
                    end
                elseif not self:_lightPasses(mapX, mapY) then
                    newStart=slopeEnd
                else
                    blocked=false
                    visSlopeStart=newStart
                end
            end
        end
        if blocked then break end
    end
end

return Recursive
