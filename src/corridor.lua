local Corridor_PATH =({...})[1]:gsub("[%.\\/]corridor$", "") .. '/'
local class  =require (Corridor_PATH .. 'vendor/30log')

local Corridor = ROT.Map.Feature:extends { _startX, _startY, _endX, _endY, _rng }
function Corridor:__init(startX, startY, endX, endY)
	assert(ROT, 'require rot')
	self._startX       =startX
	self._startY       =startY
	self._endX         =endX
	self._endY         =endY
	self._endsWithAWall=true
	self.__name        ='Corridor'
	self._rng  =ROT.RNG.Twister:new()
    self._rng:randomseed()
end

function Corridor:createRandomAt(x, y, dx, dy, options, rng)
	local min   =options.corridorLength[1]
	local max   =options.corridorLength[2]
	local length=math.floor(rng:random(min, max))
	return self:new(x, y, x+dx*length, y+dy*length)
end

function Corridor:debug()
	local command    = write and write or io.write
	local debugString= 'corridor: '..self._startX..','..self._startY..','..self._endX..','..self._endY
	command(debugString)
end

function Corridor:isValid(gen, isWallCallback, canBeDugCallback)
	local sx    =self._startX
	local sy    =self._startY
	local dx    =self._endX-sx
	local dy    =self._endY-sy
	local length=1+math.max(math.abs(dx), math.abs(dy))

	if dx>0 then dx=dx/math.abs(dx) end
	if dy>0 then dy=dy/math.abs(dy) end
	local nx=dy
	local ny=-dx

	local ok=true

	for i=0,length-1 do
		local x=sx+i*dx
		local y=sy+i*dy

		if not canBeDugCallback(gen,    x,    y) then ok=false end
		if not isWallCallback  (gen, x+nx, y+ny) then ok=false end
		if not isWallCallback  (gen, x-nx, y-ny) then ok=false end

		if not ok then
			length=i
			self._endX=x-dx
			self._endY=y-dy
			break
		end
	end

	if length==0 then return false end
	if length==1 and isWallCallback(gen, self._endX+dx, self._endY+dy) then return false end

	local firstCornerBad=not isWallCallback(gen, self._endX+dx+nx, self._endY+dy+ny)
	local secondCornrBad=not isWallCallback(gen, self._endX+dx-nx, self._endY+dy-ny)
	self._endsWithAWall =    isWallCallback(gen, self._endX+dx   , self._endY+dy   )
	if (firstCornerBad or secondCornrBad) and self._endsWithAWall then return false end

	return true
end

function Corridor:create(gen, digCallback)
	local sx    =self._startX
	local sy    =self._startY
	local dx    =self._endX-sx
	local dy    =self._endY-sy

	local length=1+math.max(math.abs(dx), math.abs(dy))
	if dx~=0 then dx=dx/math.abs(dx) end
	if dy~=0 then dy=dy/math.abs(dy) end

	for i=0,length-1 do
		local x=sx+i*dx
		local y=sy+i*dy
		digCallback(gen, x, y, 0)
	end
	return true
end

function Corridor:createPriorityWalls(gen, priorityWallCallback)
	if not self._endsWithAWall then return end

	local sx    =self._startX
	local sy    =self._startY
	local dx    =self._endX-sx
	local dy    =self._endY-sy
	local length=1+math.max(math.abs(dx), math.abs(dy))

	if dx>0 then dx=dx/math.abs(dx) end
	if dy>0 then dy=dy/math.abs(dy) end
	local nx=dy
	local ny=-dx

	priorityWallCallback(gen, self._endX+dx, self._endY+dy)
	priorityWallCallback(gen, self._endX+nx, self._endY+ny)
	priorityWallCallback(gen, self._endX-nx, self._endY-ny)
end

return Corridor
