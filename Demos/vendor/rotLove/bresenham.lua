local Bresenham_PATH =({...})[1]:gsub("[%.\\/]bresenham$", "") .. '/'
local class  =require (Bresenham_PATH .. 'vendor/30log')

local Bresenham=ROT.FOV:extends { __name, _lightPasses, _options }

function Bresenham:__init(lightPassesCallback, options)
    Bresenham.super.__init(self, lightPassesCallback, options)
    self.__name='Bresenham'
end

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

function Bresenham:computeQuick(cx, cy, r, callback)
	visited={}
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
