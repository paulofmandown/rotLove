RogueLike Toolkit in Love
=========
Bringing rot.js functionality to Love2D

Currently Implemented:
Display          - via [rlLove](https://github.com/paulofmandown/rlLove), only supports cp437 emulation rather than full font support.
rng              - via [RandmLua](http://love2d.org/forums/viewtopic.php?f=5&t=3424), doesn't support state export
String Generator - Direct Port from rot.js

Demos
=========
```lua
-- Display, RNG Demo
ROT = require 'vendor/rotLove/rot'
function love.load()
	frame=Display(80, 24)
end
function love.draw()
	frame:draw()
end

x,y,i=1,1,1

function love.update()
	if x<80 then x=x+1
	else x,y=1,y<24 and y+1 or 1
	end
	i = i<255 and i+1 or 1
	frame:write(string.char(i), x, y, getRandomColor(), getRandomColor())
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
```

```lua
-- Display, StringGen, RNG Demo
ROT = require 'vendor/rotLove/rot'
function love.load()
	frame=Display(80, 24)
	sg = StringGenerator()
	-- where names.txt is a plain-text list of mixed-case names (one per line)
	for name in io.lines('names.txt') do
		sg:observe(name)
	end
end
time=0
function love.update(dt)
	time=time+dt
	if time<1 then return end

	time=time-1
	frame:clear()
	for i=1,24 do
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
```
