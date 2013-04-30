local Cellular_PATH =({...})[1]:gsub("[%.\\/]cellular$", "") .. '/'
local class  =require (Cellular_PATH .. 'vendor/30log')

local Cellular = ROT.Map:extends { _rng, _options, _map }

function Cellular:__init(width, height, options)
	assert(ROT, 'must require rot')
	Cellular.super.__init(self, width, height)
	self.__name='Cellular'
	self._options={
					born    ={5,6,7,8},
					survive ={4,5,6,7,8},
					topology=8
				  }
	if options then
		for k,v in pairs(options) do
			self._options[k]=v
		end
	end
	local t=self._options.topology
	assert(t==8 or t==4, 'topology must be 8 or 4')
	self._dirs = t==8 and ROT.DIRS.EIGHT or t==4 and ROT.DIRS.FOUR

	self._rng = ROT.RNG.Twister:new()
    self._rng:randomseed()

end

function Cellular:randomize(prob)
	if not self._map then self._map = self:_fillMap(0) end
	for i=1,self._width do
		for j=1,self._height do
			self._map[i][j]= self._rng:random() < prob and 1 or 0
		end
	end
	return self
end

function Cellular:set(x, y, value)
	self._map[x][y]=value
end

function Cellular:create(callback)
	local newMap =self:_fillMap(0)
	local born   =self._options.born
	local survive=self._options.survive
	local changed=false

	for j=1,self._height do
		for i=1,self._width do
			local cur   =self._map[i][j]
			local ncount=self:_getNeighbors(i, j)
			if cur>0 and table.indexOf(survive, ncount)>0 then
				newMap[i][j]=1
			elseif cur<=0 and table.indexOf(born, ncount)>0 then
				newMap[i][j]=1
			end
			if callback then callback(i, j, newMap[i][j]) end
			if not changed and newMap[i][j]~=self._map[i][j] then changed=true end
		end
	end
	self._map=newMap
	return changed
end

function Cellular:_getNeighbors(cx, cy)
	local rst=0
	for i=1,#self._dirs do
		local dir=self._dirs[i]
		local x  =cx+dir[1]
		local y  =cy+dir[2]
		if x>0 and x<=self._width and y>0 and y<=self._height then
			rst= self._map[x][y]==1 and rst+1 or rst
		end
	end
	return rst
end

return Cellular
