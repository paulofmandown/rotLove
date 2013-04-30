--[[ String Gen ]]--
ROT = require 'vendor/rotLove/rot'
function love.load()
	frame=ROT.Display(80, 24)
	sg = ROT.StringGenerator()
	-- where names.txt is a plain-text list of mixed-case names (one per line)
	-- Provided is a list of Dunmer Names from UESP
	for name in io.lines('names.txt') do
		sg:observe(name)
	end
	frame:writeCenter(sg:getStats(), 1)
end
time=5.01
function love.update(dt)
	time=time+dt
	if time<5 then return
	else time=time-5 end
	frame:clear(nil, nil, 2, nil, 22)
	frame:write('Dunmer', 1, 23)
	frame:write('Names',  1, 24)
	for i=2,24 do
		local name = sg:generate()
		if #name < 80 then
			frame:writeCenter(name, i)
		else i=i-1 end
	end
end
function love.draw()
	frame:draw()
end
--]]
