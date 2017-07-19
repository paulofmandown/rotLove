--[[ ActionScheduler ]]--
ROT=require 'src.rot'

function love.load()
    s  =ROT.Scheduler.Action:new()
    f  =ROT.Display(80,24)
    for i=1,4 do s:add(i,true,i-1) end
end
y=1
function love.update()
    love.timer.sleep(.5)
    c  =s:next()
    dur=ROT.RNG:random(1,20)
    s:setDuration(dur)
    f:writeCenter('TURN: '..c..' for '..dur..' units of time', y)
    y=y<24 and y+1 or 1
end
function love.draw()
    f:draw()
end
--]]
