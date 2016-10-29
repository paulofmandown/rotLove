--[[ Brogue ]]
ROT=require 'rotLove/rotLove'

function love.load()
    f  =ROT.Display(80, 30)
    brg=ROT.Map.Brogue(f:getWidth(), f:getHeight())
    brg:create(calbak,true)
end
function love.draw() f:draw() end
function calbak(x, y, val) f:write(val==3 and '*' or val==2 and '+' or val==1 and '#' or '.', x, y) end
local update=false
function love.update()
    if update then
        update=false
        brg:create(calbak)
    end
end
function love.keypressed(key) update=true end
