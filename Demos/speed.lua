--[[ SpeedScheduler ]]--
ROT= require 'vendor/rotLove/rot'
class= require 'vendor/rotLove/vendor/30log'

actor=class { speed, number }
function actor:__init(speed, number)
	self.speed=speed
	self.number=number
end
function actor:getSpeed() return self.speed end

function love.load()
	f=Display(80, 24)
	rng=ROT.RNG.Twister:new()
    rng:randomseed()
	s=SpeedScheduler:new()
	for i=1,4 do
		a=actor:new(rng:random(1,100), i)
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
