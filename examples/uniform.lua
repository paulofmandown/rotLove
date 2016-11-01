--[[ Uniform ]]
ROT=require 'rotLove/rotLove'

function love.load()
	f  =ROT.Display(80, 24)
	uni=ROT.Map.Uniform(f:getWidth(), f:getHeight())
	uni:create(calbak)
end
function love.draw() f:draw() end
function calbak(x, y, val) f:write(val==1 and '#' or '.', x, y) end
update=false
function love.update()
    if update then
        update=false
        uni:create(calbak)
    end
end
function love.keypressed(key) update=true end
