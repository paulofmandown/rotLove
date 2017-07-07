local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Path = ROT.Class:extend("Path")

function Path:init(toX, toY, passableCallback, options)
    self._toX  =toX
    self._toY  =toY
    self._fromX=nil
    self._fromY=nil
    self._passableCallback=passableCallback
    self._options= { topology=8 }

    if options then for k,_ in pairs(options) do self._options[k]=options[k] end end

    self._dirs= self._options.topology==8 and ROT.DIRS.EIGHT or ROT.DIRS.FOUR
    if self._options.topology==8 then
        self._dirs ={self._dirs[1],
                     self._dirs[3],
                     self._dirs[5],
                     self._dirs[7],
                     self._dirs[2],
                     self._dirs[4],
                     self._dirs[6],
                     self._dirs[8] }
    end
end

function Path:compute() end

function Path:_getNeighbors(cx, cy)
    local result={}
    for i=1,#self._dirs do
        local dir=self._dirs[i]
        local x=cx+dir[1]
        local y=cy+dir[2]
        if self._passableCallback(x, y) then
            table.insert(result, {x, y})
        end
    end
    return result
end

return Path
