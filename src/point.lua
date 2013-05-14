local Point_PATH =({...})[1]:gsub("[%.\\/]point$", "") .. '/'
local class  =require (Point_PATH .. 'vendor/30log')

local Point=class { x, y }
Point.__name='Point'
function Point:__init(x, y)
    self.x=x
    self.y=y
end

function Point:hashCode()
    local prime =31
    local result=1
    result=prime*result+self.x
    result=prime*result+self.y
    return result
end

function Point:equals(other)
    if self==other                  then return true  end
    if other==nil                   or
    not other.is_a(Point)           or
    (other.x and other.x ~= self.x) or
    (other.y and other.y ~= self.y) then return false end
    return true
end

function Point:adjacentPoints()
    local points={}
    local i     =1
    for ox=-1,1 do for oy=-1,1 do
        points[i]=Point(self.x+ox,self.y+oy)
        i=i+1
    end end
    return points
end

return Point
