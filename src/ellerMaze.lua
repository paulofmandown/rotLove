--- The Eller Maze Map Generator.
-- See http://homepages.cwi.nl/~tromp/maze.html for explanation
-- @module ROT.Map.EllerMaze

local EllerMaze_PATH =({...})[1]:gsub("[%.\\/]ellerMaze$", "") .. '/'
local class  =require (EllerMaze_PATH .. 'vendor/30log')

local EllerMaze = ROT.Map:extends { _rng }


--- Constructor.
-- Called with ROT.Map.EllerMaze:new(width, height)
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
function EllerMaze:__init(width, height)
	EllerMaze.super.__init(self, width, height)
	self.__name='EllerMaze'
	self._rng  =ROT.RNG.Twister:new()
    self._rng:randomseed()
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.EllerMaze self
function EllerMaze:create(callback)
	local map =self:_fillMap(1)
	local w   =math.ceil((self._width-2)/2)
	local rand=9/24
	local L   ={}
	local R   ={}

	for i=1,w do
		table.insert(L,i)
		table.insert(R,i)
	end
	table.insert(L,w)
	local j=2
	while j<self._height-2 do
		for i=1,w do
			local x=2*i
			local y=j
			map[x][y]=0

			if i~=L[i+1] and self._rng:random()>rand then
				self:_addToList(i, L, R)
				map[x+1][y]=0
			end

			if i~=L[i] and self._rng:random()>rand then
				self:_removeFromList(i, L, R)
			else
				map[x][y+1]=0
			end
		end
		j=j+2
	end
	--j=self._height%2==1 and self._height-2 or self._height-3
	for i=1,w do
		local x=2*i
		local y=j
		map[x][y]=0

		if i~=L[i+1] and (i==L[i] or self._rng:random()>rand) then
			self:_addToList(i, L, R)
			map[x+1][y]=0
		end

		self:_removeFromList(i, L, R)
	end
	for i=1,self._width do
		for j=1,self._height do
			callback(i, j, map[i][j])
		end
	end
	return self
end

function EllerMaze:_removeFromList(i, L, R)
	R[L[i]]=R[i]
	L[R[i]]=L[i]
	R[i]   =i
	L[i]   =i
end

function EllerMaze:_addToList(i, L, R)
	R[L[i+1]]=R[i]
	L[R[i]]  =L[i+1]
	R[i]     =i+1
	L[i+1]   =i
end

return EllerMaze
