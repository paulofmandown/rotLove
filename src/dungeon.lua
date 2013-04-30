local Dungeon_PATH =({...})[1]:gsub("[%.\\/]dungeon$", "") .. '/'
local class  =require (Dungeon_PATH .. 'vendor/30log')

local Dungeon = ROT.Map:extends { _rooms, _corridors }

function Dungeon:__init(width, height)
	Dungeon.super.__init(self, width, height)
	self._rooms    ={}
	self._corridors={}
end

function Dungeon:getRooms() return self._rooms end
function Dungeon:getCorridors() return self._corridors end

return Dungeon
