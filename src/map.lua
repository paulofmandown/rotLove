local ROT = require((...):gsub('[^./\\]*$', '') .. 'rot')
local Map = ROT.Class:extend("Map")

function Map:init(width, height)
	self._width = width and width or ROT.DEFAULT_WIDTH
	self._height= height and height or ROT.DEFAULT_HEIGHT
end

function Map:create() end

function Map:_fillMap(value)
	local map={}
	for  i=1,self._width do
		table.insert(map, {})
		for _=1,self._height do table.insert(map[i], value) end
	end
	return map
end

return Map
