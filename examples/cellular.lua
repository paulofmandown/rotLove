--[[ Cellular ]]--
ROT=require 'src.rot'
function love.load()
    f =ROT.Display(80,24)
    cl=ROT.Map.Cellular:new(f:getWidth(), f:getHeight())
    cl:randomize(.5)
    cl:create(calbak)
end
function love.draw() f:draw() end
function love.update()
    love.timer.sleep(.5)
    if cl:create(calbak).changed then
        f:write('changed @ '..os.clock(), 1, 1)
    else
        f:write("didn't change @ "..os.clock(), 1, 1)
    end
end
function calbak(x, y, val)
    f:write(val==1 and '#' or '.', x, y)
end
--]]
