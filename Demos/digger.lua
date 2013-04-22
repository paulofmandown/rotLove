--[[ Digger ]]
ROT=require 'vendor/rotLove/rot'

function love.load()
	f  =Display(80, 24)
	dgr=Digger(f:getWidth(), f:getHeight())
	dgr:create(calbak)
end
function love.draw() f:draw() end
function calbak(x, y, val) f:write(val==1 and '#' or '.', x, y) end
function love.update()
	love.timer.sleep(1)
	dgr:create(calbak)
end
