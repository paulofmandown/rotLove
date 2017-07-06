local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Line = ROT.Class:extend("Line")

function Line:init(x1, y1, x2, y2)
    self.x1=x1
    self.y1=y1
    self.x2=x2
    self.y2=y2
    self.points={}
end
function Line:getPoints()
    local dx =math.abs(self.x2-self.x1)
    local dy =math.abs(self.y2-self.y1)
    local sx =self.x1<self.x2 and 1 or -1
    local sy =self.y1<self.y2 and 1 or -1
    local err=dx-dy

    while true do
        table.insert(self.points, ROT.Point:new(self.x1, self.y1))
        if self.x1==self.x2 and self.y1==self.y2 then break end
        local e2=err*2
        if e2>-dx then
            err=err-dy
            self.x1 =self.x1+sx
        end
        if e2<dx then
            err=err+dx
            self.y1 =self.y1+sy
        end
    end
    return self
end

return Line
