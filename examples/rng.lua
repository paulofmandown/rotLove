ROT=require 'rotLove/rotLove'
function love.load()
	f=ROT.Display:new()
	doTheThing()
end

function doTheThing()
	local arbitraryNum=math.floor(os.clock())%3
	local rng=arbitraryNum==0 and ROT.RNG.Twister() or
			  arbitraryNum==1 and ROT.RNG.LCG() or
			  arbitraryNum==2 and ROT.RNG.MWC()

	f:write(tostring(rng), 1, 1)

	rng:randomseed()
	local state=rng:getState()
	for i=2,f:getHeight()/2 do
		f:writeCenter(tostring(rng:random()), i)
	end
	rng:setState(state)
	for i=f:getHeight()/2+2,f:getHeight() do
		f:writeCenter(tostring(rng:random()), i)
	end
end

function love:draw() f:draw() end

update=false
function love.update()
	if update then
		update=false
		f:clear()
		doTheThing()
	end
end

function love.keypressed() update=true end
