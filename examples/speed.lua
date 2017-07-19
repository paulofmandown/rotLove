--[[ SpeedScheduler ]]--
ROT=require 'src.rot'

actor=ROT.Class:extend("actor", {speed, number})
function actor:init(speed, number)
    self.speed=speed
    self.number=number
end
function actor:getSpeed() return self.speed end

function love.load()
    f=ROT.Display(80, 24)
    s=ROT.Scheduler.Speed:new()
    for i=1,4 do
        a=actor:new(ROT.RNG:random(1,100), i)
        s:add(a, true)
        f:writeCenter('Added '..i..', with speed: '..a:getSpeed(), i)
    end
end
y=5
function love.update()
    love.timer.sleep(.5)
    f:writeCenter('TURN: '..s:next().number, y)
    y=y<24 and y+1 or 5
end
function love.draw() f:draw() end
--]]
