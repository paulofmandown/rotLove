local Bresenham_PATH =({...})[1]:gsub("[%.\\/]bresenham$", "") .. '/'
local class  =require (Bresenham_PATH .. 'vendor/30log')

local Bresenham=ROT.FOV:extends { __name, _lightPasses, _options }

function Bresenham:__init(lightPassesCallback, options)
    Bresenham.super.__init(self, lightPassesCallback, options)
    self.__name='Bresenham'
end

function Bresenham:compute(cx, cy, r, callback)
    local visited={}
    callback(cx,cy,r)
    visited[ROT.Point(cx, cy):hashCode()]=0
    --[[]]
    local thePoints=self:_getCircle(cx, cy, r)
    for _,p in pairs(thePoints) do
        local x,y=p[1],p[2]
        local line=ROT.Line(cx,cy,x, y):getPoints()
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
