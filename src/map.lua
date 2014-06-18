local Map_PATH =({...})[1]:gsub("[%.\\/]map$", "") .. '/'
local class  =require (Map_PATH .. 'vendor/30log')

local Map=class { }
Map.__name= 'Map'
function Map:__init(width, height)
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
