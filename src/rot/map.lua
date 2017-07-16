local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Map = ROT.Class:extend("Map")

function Map:init(width, height)
    self._width = width or ROT.DEFAULT_WIDTH
    self._height = height or ROT.DEFAULT_HEIGHT
end

function Map:create() end

function Map:_fillMap(value)
    local map = {}
    for x = 1, self._width do
        map[x] = {}
        for y = 1, self._height do
            map[x][y] = value
        end
    end
    return map
end

return Map

