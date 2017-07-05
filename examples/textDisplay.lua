--[[ Display, RNG ]]--
    ROT=require 'src.rot'
    function love.load()
		-- text display requires love.graphics to be loaded
		love.window.setMode(800, 600)
        frame=ROT.TextDisplay()
        rand = math.random(1,3)
        rng = rand == 1 and ROT.RNG.Twister:new() or
              rand == 2 and ROT.RNG.LCG:new() or
              ROT.RNG.MWC:new()
        rng:randomseed()
    end
    function love.draw()
        frame:draw()
    end

    x,y,i=1,1,64

    function love.update()
        if x<80 then x=x+1
        else x,y=1,y<24 and y+1 or 1
        end
        i = i<120 and i+1 or 64
        frame:write(string.char(i), x, y, getRandomColor(), getRandomColor())
    end

    function getRandomColor()
        return { r=math.floor(rng:random(0,255)),
                 g=math.floor(rng:random(0,255)),
                 b=math.floor(rng:random(0,255)),
                 a=255}
    end
--]]
