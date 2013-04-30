local IceyMaze_PATH =({...})[1]:gsub("[%.\\/]iceyMaze$", "") .. '/'
local class  =require (IceyMaze_PATH .. 'vendor/30log')

local IceyMaze = ROT.Map:extends { _regularity, _rng }

function IceyMaze:__init(width, height, regularity)
	assert(ROT or twister, 'require rot or require RandomLua, IceyMaze requires twister() be available')
	IceyMaze.super.__init(self, width, height)
	self.__name     ='IceyMaze'
	self._regularity= regularity and regularity or 0
	self._rng       =ROT.RNG.Twister:new()
    self._rng:randomseed()
end

function IceyMaze:create(callback)
	local w=self._width
	local h=self._height
	local map=self:_fillMap(1)
	w= w%2==1 and w-1 or w-2
	h= h%2==1 and h-1 or h-2

	local cx, cy, nx, ny = 1, 1, 1, 1
	local done   =0
	local blocked=false
	local dirs={
				{0,0},
				{0,0},
				{0,0},
				{0,0}
			   }
	repeat
		cx=2+2*math.floor(self._rng:random()*(w-1)/2)
		cy=2+2*math.floor(self._rng:random()*(h-1)/2)
		if done==0 then map[cx][cy]=0 end
		if map[cx][cy]==0 then
			self:_randomize(dirs)
			repeat
				if math.floor(self._rng:random()*(self._regularity+1))==0 then self:_randomize(dirs) end
				blocked=true
				for i=1,4 do
					nx=cx+dirs[i][1]*2
					ny=cy+dirs[i][2]*2
					if self:_isFree(map, nx, ny, w, h) then
						map[nx][ny]=0
						map[cx+dirs[i][1]][cy+dirs[i][2]]=0

						cx=nx
						cy=ny
						blocked=false
						done=done+1
						break
					end
				end
			until blocked
		end
	until done+1>=w*h/4

	for i=1,self._width do
		for j=1,self._height do
			callback(i, j, map[i][j])
		end
	end
	self._map=nil
	return self
end

function IceyMaze:_randomize(dirs)
	for i=1,4 do
		dirs[i][1]=0
		dirs[i][2]=0
	end
	local rand=math.floor(self._rng:random()*4)
	if rand==0 then
		dirs[1][1]=-1
		dirs[3][2]=-1
		dirs[2][1]= 1
		dirs[4][2]= 1
	elseif rand==1 then
		dirs[4][1]=-1
		dirs[2][2]=-1
		dirs[3][1]= 1
		dirs[1][2]= 1
	elseif rand==2 then
		dirs[3][1]=-1
		dirs[1][2]=-1
		dirs[4][1]= 1
		dirs[2][2]= 1
	elseif rand==3 then
		dirs[2][1]=-1
		dirs[4][2]=-1
		dirs[1][1]= 1
		dirs[3][2]= 1
	end
end

function IceyMaze:_isFree(map, x, y, w, h)
	if x<2 or y<2 or x>w or y>h then return false end
	return map[x][y]~=0
end

return IceyMaze
