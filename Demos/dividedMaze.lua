--[[ Divided Maze ]]
ROT=require 'vendor/rotLove/rot'
function love.load()
	f =ROT.Display(80,24)
	dm=ROT.Map.DividedMaze:new(f:getWidth(), f:getHeight())
	dm:create(calbak)
end
function love.draw() f:draw() end
local update=false
function love.update()
	if update then
        update=false
    	dm:create(calbak)
    end
end
function calbak(x,y,val)
	f:write(val==1 and '#' or '.', x, y)
end
function love.keypressed(key) update=true end
