ROT=require 'vendor/rotLove/rot'
function love.load()
	f =Display(81,25)
	em=EllerMaze:new(f:getWidth(), f:getHeight())
	em:create(calbak)
end
function love.draw() f:draw() end
function love.update()
	em:create(calbak)
	love.timer.sleep(1)
end
ellerStr=''
function calbak(x,y,val)
	f:write(val==1 and '#' or '.', x, y)
end
