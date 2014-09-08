--[[ Uniform ]]
ROT=require 'vendor/rotLove/rotLove'

function love.load()
    f  =ROT.Display(79, 29)
    uni=ROT.Map.Uniform(f:getWidth(), f:getHeight(),
                   {roomDugPercentage=.65,
                    roomWidth={4,20},
                    roomHeight={3,7},
                    crossWidth={3,12},
                    crossHeight={2,5}})
end
function love.draw() f:draw() end
function calbak(x, y, val) f:write(val==1 and '#' or '.', x, y) end
update=true
function love.update()
    if update then
        f:clear()
        update=false
        uni:create(calbak)
        for k,v in pairs(uni:getDoors()) do
            f:write('+', v.x, v.y)
        end
    end
end
function love.keypressed(key) update=true end
