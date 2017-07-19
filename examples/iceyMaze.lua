--[[ Divided Maze ]]
ROT=require 'src.rot'
function love.load()
    -- Icey works better with odd width/height
    f =ROT.Display:new(81,25)
    im=ROT.Map.IceyMaze:new(f:getWidth(), f:getHeight())
    im:create(calbak)
end
local update=false
function love.update()
    if update then
        update=false
        im=ROT.Map.IceyMaze:new(f:getWidth(), f:getHeight())
        im:create(calbak)
    end
end
function love.draw() f:draw() end
function calbak(x,y,val)
    f:write(val==1 and '#' or '.', x, y)
end
function love.keypressed(key) update=true end
