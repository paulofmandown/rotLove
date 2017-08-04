--[[ Brogue ]]
ROT=require 'src.rot'

function love.load()
    f  =ROT.Display(80, 30)
    brg=ROT.Map.Brogue(f:getWidth(), f:getHeight())
    brg:create(calbak,true)
    for _, room in ipairs(brg:getRooms()) do
        room:getDoors(function(x, y) f:write('+', x, y) end)
    end
end
function love.draw() f:draw() end
function calbak(x, y, val)
    f:write(val==1 and '#' or '.', x, y)
end
local update=false
function love.update()
    if update then
        update=false
        brg:create(calbak)
        for _, room in ipairs(brg:getRooms()) do
            room:getDoors(function(x, y) f:write('+', x, y) end)
        end
    end
end
function love.keypressed(key) update=true end
