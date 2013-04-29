--[[ Display, RNG ]]--
	ROT = require 'vendor/rotLove/rot'
	function love.load()
        -- Display(widthInCharacters, heightInCharacters, characterScale
        --         defaultForegroundColor, defaultBackgroundColor,
        --         useFullScreen, useVSync, numberOfFsaaSamples)
        -- Defaults shown here
		frame=Display(80, 24, 1, {r=192,g=192,b=192,a=255}, {r=0,g=0,b=0,a=255}, false, false, 3)
        rand = math.random(1,3)
        rng = rand == 1 and ROT.RNG.Twister:new() or
              rand == 2 and ROT.RNG.LCG:new() or
              ROT.RNG.MWC:new()
        rng:randomseed()
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
		return { r=math.floor(rng:random(0,255)),
				 g=math.floor(rng:random(0,255)),
				 b=math.floor(rng:random(0,255)),
				 a=255}
	end
--]]
