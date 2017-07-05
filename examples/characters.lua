ROT=require 'src.rot'
DSP=ROT.Display:new()
function love.load()
    local y=1
    local x=3
    for i=1,255 do
        local str=tostring(i):lpad('0', 3)..' '..string.char(i)
        DSP:write(str, x, y)
        y=y<DSP:getHeight() and y+1 or 1
        x=y==1 and x+7 or x
    end
end
function love.update(dt) if dt then love.timer.sleep(1) end end
function love.draw() DSP:draw() end
