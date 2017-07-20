--[[ Digger ]]
ROT=require 'src.rot'

local update=false
function love.load()
    f  =ROT.Display(80, 24)
    dgr=ROT.Map.Digger(f:getWidth(), f:getHeight())
    update=true
end
function love.draw() f:draw() end
function calbak(x, y, val) f:write(val==1 and '#' or '.', x, y) end
function love.update()
    if update then
        update=false
        dgr:create(calbak)
        local doors=dgr:getDoors()
        for k,v in pairs(doors) do
            f:write('+', v.x, v.y)
        end
    end
end
function love.keypressed(key)
    ROT.RNG:setSeed(key)
    update=true
end
