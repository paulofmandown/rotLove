local Arena_PATH =({...})[1]:gsub("[%.\\/]arena$", "") .. '/'
local class  =require (Arena_PATH .. 'vendor/30log')

local Arena = ROT.Map:extends { }

function Arena:__init(width, height)
	Arena.super.__init(self, width, height)
	self.__name = 'Arena'
end

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
