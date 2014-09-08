--[[ Rogue ]]
ROT=require 'vendor/rotLove/rotLove'

function love.load()
    f  =ROT.Display(80, 24)
    rog=ROT.Map.Rogue(f:getWidth(), f:getHeight())
end
function love.draw() f:draw() end
function calbak(x, y, val) f:write(val==1 and '#' or '.', x, y) end
update=true
function love.update()
    if update then
        update=false
        rog:create(calbak)
        for k,v in pairs(rog:getDoors()) do
            f:write('+', v.x, v.y)
        end
    end
end
function love.keypressed(key) update=true end
