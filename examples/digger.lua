--[[ Digger ]]
ROT=require 'vendor/rotLove/rotLove'

function love.load()
    f  =ROT.Display(80, 24)
    dgr=ROT.Map.Digger(f:getWidth(), f:getHeight(),
                   {roomDugPercentage=.65,
                    roomWidth={4,20},
                    roomHeight={3,7},
                    crossWidth={3,12},
                    crossHeight={2,5},
                    nocorridorsmode=true})
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
