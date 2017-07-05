--[[ Rogue ]]
ROT=require 'src.rot'

function love.load()
    f  =ROT.Display(80, 24)
    rog=ROT.Map.Rogue(f:getWidth(), f:getHeight())
    rog:create(calbak)
end
function love.draw() f:draw() end
function calbak(x, y, val) f:write(val==1 and '#' or '.', x, y) end
update=false
function love.update()
    if update then
        update=false
        rog:create(calbak)
    end
end
function love.keypressed(key) update=true end
