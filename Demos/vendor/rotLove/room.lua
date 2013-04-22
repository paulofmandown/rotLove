Room_PATH =({...})[1]:gsub("[%.\\/]room$", "") .. '/'
local class  =require (Room_PATH .. 'vendor/30log')

Room = Feature:extends { _x1, _x2, _y1, _y2, _doorX, _doorY, _rng }
function Room:__init(x1, y1, x2, y2, doorX, doorY)
	assert(ROT or twister, 'require rot or RandomLua')
	self._x1   =x1
	self._x2   =x2
	self._y1   =y1
	self._y2   =y2
	self._doors= {}
	if doorX then
		self._doors[doorX..','..doorY] = 1
	end
	self.__name='Room'
	self._rng  =ROT.RNG.twister and ROT.RNG.twister or twister and twister

end

function Room:createRandomAt(x, y, dx, dy, options)
	local rng =ROT.RNG.twister and ROT.RNG.twister or twister and twister
	local min  =options.roomWidth[1]
	local max  =options.roomWidth[2]
	local width=min+math.floor(rng:random(min, max))

	local min   =options.roomHeight[1]
	local max   =options.roomHeight[2]
	local height=min+math.floor(rng:random(min,max))

	if dx==1 then
		local y2=y-math.floor(rng:random()*height)
		return Room:new(x+1, y2, x+width, y2+height-1, x, y)
	end
	if dx==-1 then
		local y2=y-math.floor(rng:random()*height)
		return Room:new(x-width, y2, x-1, y2+height-1, x, y)
	end
	if dy==1 then
		local x2=x-math.floor(rng:random()*width)
		return Room:new(x2, y+1, x2+width-1, y+height, x, y)
	end
	if dy==-1 then
		local x2=x-math.floor(rng:random()*width)
		return Room:new(x2, y-height, x2+width-1, y-1, x, y)
	end
end

function Room:createRandomCenter(cx, cy, options)
	local rng=ROT.RNG.twister
	local min  =options.roomWidth[1]
	local max  =options.roomWidth[2]
	local width=min+math.floor(rng:random()*(max-min+1))

	local min   =options.roomHeight[1]
	local max   =options.roomHeight[2]
	local height=min+math.floor(rng:random()*(max-min+1))

	local x1=cx-math.floor(rng:random()*width)
	local y1=cy-math.floor(rng:random()*height)
	local x2=x1+width-1
	local y2=y1+height-1

	return Room:new(x1, y1, x2, y2)
end

function Room:createRandom(availWidth, availHeight, options)
	local min  =options.roomWidth[1]
	local max  =options.roomWidth[2]
	local width=min+math.floor(self._rng:random()*(max-min+1))

	local min   =options.roomHeight[1]
	local max   =options.roomHeight[2]
	local height=min+math.floor(self._rng:random()*(max-min+1))

	local left=availWidth-width-1
	local top =availHeight-height-1

	local x1=math.floor(self._rng:random()*left)
	local y1=math.floor(self._rng:random()*top)
	local x2=x1+width-1
	local y2=y1+height-1

	return Room:new(x1, x2, y1, y2)
end

function Room:addDoor(x, y)
	self._doors[x..','..y]=1
end

function Room:getDoors(callback)
	for k,_ in pairs(self._doors) do
		local parts=k:split(',')
		callback(tonumber(parts[1]), tonumber(parts[2]))
	end
end

function Room:clearDoors()
	self._doors={}
	return self
end

function Room:debug()
	local command    = write and write or io.write
	local debugString= 'room    : '..self._x1..','..self._y1..','..self._x2..','..self._y2
	command(debugString)
end

function Room:isValid(gen, isWallCallback, canBeDugCallback)
	local left  =self._x1-1
	local right =self._x2+1
	local top   =self._y1-1
	local bottom=self._y2+1
	for x=left,right do
		for y=top,bottom do
			if x==left or x==right or y==top or y==bottom then
				if not isWallCallback(gen, x, y) then return false end
			else
				if not canBeDugCallback(gen, x, y) then return false end
			end
		end
	end
	return true
end

function Room:create(gen, digCallback)
	local left  =self._x1-1
	local top   =self._y1-1
	local right =self._x2+1
	local bottom=self._y2+1
	local value=0
	for x=left,right do
		for y=top,bottom do
			if self._doors[x..','..y] then
				value=2
			elseif x==left or x==right or y==top or y==bottom then
				value=1
			else
				value=0
			end
			digCallback(gen, x, y, value)
		end
	end
end

function Room:getCenter()
	return {math.round((self._x1+self._x2)/2),
			math.round((self._y1+self._y2)/2)}
end

function Room:getLeft()   return self._x1 end
function Room:getRight()  return self._x2 end
function Room:getTop()    return self._y1 end
function Room:getBottom() return self._y2 end



return Room
