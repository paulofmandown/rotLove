--[[ SimpleScheduler ]]--
ROT= require 'vendor/rotLove/rot'
function love.load()
	f=Display(80, 24)
	s=SimpleScheduler:new()
	for i=1,3 do s:add(i, true) end
end
function love.update()
	love.timer.sleep(.5)
	f:writeCenter('TURN: '..s:next())
end
function love.draw() f:draw() end
--]]

