--[[ String Gen ]]--
ROT = require 'vendor/rotLove/rot'
function love.load()
	frame=Display(80, 24)
	sg = StringGenerator()
	-- where names.txt is a plain-text list of mixed-case names (one per line)
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
	for i=2,24 do
		local name = sg:generate()
		if #name < 80 then
			frame:writeCenter(name, i, getRandomColor(), getRandomColor())
		else i=i-1 end
	end
end
function love.draw()
	frame:draw()
end
function getRandomColor()
	rand = math.random(1,3)
	local rng = rand == 1 and ROT.RNG.twister or
				rand == 2 and ROT.RNG.lcg or
				ROT.RNG.mwc
	return { r=math.floor(rng:random(0,255)),
			 g=math.floor(rng:random(0,255)),
			 b=math.floor(rng:random(0,255)),
			 a=255}
end
--]]
