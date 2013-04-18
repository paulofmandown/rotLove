--[[ Display, RNG ]]--
	ROT = require 'vendor/rotLove/rot'
	function love.load()
		frame=Display(80, 24)
	end
	function love.draw()
		frame:draw()
	end

	x,y,i=1,1,1

	function love.update()
		if x<80 then x=x+1
		else x,y=1,y<24 and y+1 or 1
		end
		i = i<255 and i+1 or 1
		frame:write(string.char(i), x, y, getRandomColor(), getRandomColor())
	end

	function getRandomColor()
		rand = math.random(1,3)
		local rng = rand == 1 and ROT.RNG.twister or
					rand == 2 and ROT.RNG.lcg or
					ROT.RNG.mwc
		return { r=math.floor(rng:random(0,255)),
				 g=math.floor(rng:random(0,255)),
				 b=math.floor(rng:random(0,255)),
				 a=255}
	end
--]]
