--[[ Uniform ]]
ROT=require 'src.rot'

update=false
function love.load()
    f  =ROT.Display(80, 24)
    uni=ROT.Map.Uniform(f:getWidth(), f:getHeight())
    update=true
end
function love.draw() f:draw() end
function calbak(x, y, val) f:write(val==1 and '#' or '.', x, y) end
function love.update()
    if update then
        update=false
        uni:create(calbak)
        local rooms=uni:getDoors()
        for k,v in pairs(rooms) do
            f:write('+', v.x, v.y)
        end
    end
end
function love.keypressed(key) update=true end
