--[[ Divided Maze ]]
ROT=require 'vendor/rotLove/rot'
function love.load()
	f =Display(80,24)
	dm=DividedMaze:new(f:getWidth(), f:getHeight())
	dm:create(calbak)
end
function love.draw() f:draw() end
function love.update()
	love.timer.sleep(1)
	local time=os.clock()
	dm:create(calbak)
end
function calbak(x,y,val)
	f:write(val==1 and '#' or '.', x, y)
end
--]]
