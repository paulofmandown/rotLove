--[[ Arena ]]--
ROT=require 'src.rot'
function love.load()
    f=ROT.Display:new(80,24)
    m=ROT.Map.Arena:new(f:getWidth(), f:getHeight())
    function callbak(x,y,val)
        f:write(val == 1 and '#' or '.', x, y)
    end
    m:create(callbak)
end
function love.draw() f:draw() end
--]]
