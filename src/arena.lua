--- The Arena map generator.
-- Generates an arena style map. All cells except for the extreme borders are floors. The borders are walls.
-- @module ROT.Map.Arena
local Arena_PATH =({...})[1]:gsub("[%.\\/]arena$", "") .. '/'
local class  =require (Arena_PATH .. 'vendor/30log')

local Arena = ROT.Map:extends { }

--- Constructor.
-- Called with ROT.Map.Arena:new(width, height)
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
function Arena:__init(width, height)
	Arena.super.__init(self, width, height)
	self.__name = 'Arena'
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.Arena self
function Arena:create(callback)
	local w=self._width
	local h=self._height
	for i=1,w do
		for j=1,h do
			local empty= i>1 and j>1 and i<w and j<h
			callback(i, j, empty and 0 or 1)
		end
	end
	return self
end

return Arena
