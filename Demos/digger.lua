--[[ Digger ]]
ROT=require 'vendor/rotLove/rot'

function love.load()
	f  =Display(80, 24)
	dgr=Digger(f:getWidth(), f:getHeight())
	dgr:create(calbak)
end
function love.draw() f:draw() end
function calbak(x, y, val) f:write(val==1 and '#' or '.', x, y) end
local update=false
function love.update()
	if update then
        update=false
    	dgr:create(calbak)
    end
end
function love.keypressed(key) update=true end
