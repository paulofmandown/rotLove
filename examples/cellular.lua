--[[ Cellular ]]--
ROT=require 'vendor/rotLove/rotLove'
function love.load()
    f =ROT.Display(79,29)
    cl=ROT.Map.Cellular:new(f:getWidth(), f:getHeight())
    cl:randomize(.55)
    cl:create(calbak)
end
function love.draw() f:draw() end

i=0
m=4
wait=false

function love.update()
    love.timer.sleep(.5)
    if wait then return end
    cl:create(calbak)
    i=i+1
    if i>m then
        wait=true
        i=0
        cl:randomize(.55)
    end
end
function love.keypressed() wait=false end
function calbak(x, y, val)
    f:write(val==1 and '#' or '.', x, y)
end
--]]
