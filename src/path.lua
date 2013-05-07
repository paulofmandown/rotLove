--    +-- lolwut
--    V
local Path_PATH=({...})[1]:gsub("[%.\\/]path$", "") .. '/'
local class  =require (Path_PATH .. 'vendor/30log')

local Path=class { _toX, _toY, _fromX, _fromY, _passableCallback, _options, _dirs}

function Path:__init(toX, toY, passableCallback, options)
    self._toX  =toX
    self._toY  =toY
    self._fromX=nil
    self._fromY=nil
    self._passableCallback=passableCallback
    self._options= { topology=8 }

    if options then for k,_ in pairs(options) do self._options[k]=options[k] end end

    self._dirs= self._options.topology==8 and ROT.DIRS.EIGHT or ROT.DIRS.FOUR
end

function Path:compute(fromX, fromY, callback) end

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
