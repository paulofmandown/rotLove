--[[ Divided Maze ]]
ROT=require 'vendor/rotLove/rot'
function love.load()
	-- Icey works better with odd width/height
	f =Display:new(81,25)
	im=IceyMaze:new(f:getWidth(), f:getHeight(), 0)
	im:create(calbak)
end
local update=false
function love.update()
    if update then
        update=false
        im=IceyMaze:new(f:getWidth(), f:getHeight(), ROT.RNG.twister:random()*5)
	    im:create(calbak)
    end
end
function love.draw() f:draw() end
function calbak(x,y,val)
	f:write(val==1 and '#' or '.', x, y)
end
function love.keypressed(key) update=true end
