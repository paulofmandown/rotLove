--- rotLove Demo runner
-- specify which example you'd like to see on the command line

if arg[2] == "rtd" then
	local mod = love.filesystem.getDirectoryItems("examples")
	for i=#mod, 1, -1 do
		if not mod[i]:match("%.lua$") then
			table.remove(mod, i)
		else
			mod[i] = mod[i]:gsub("%.lua$", "")
		end
	end
	math.randomseed(os.time())
	arg[2] = mod[math.random(1, #mod)]
	print("running " .. arg[2])
end

if arg[2] then
	require("examples.".. arg[2])
else
	local mod = love.filesystem.getDirectoryItems("examples")
	io.write([[

ERROR: Please specify a demo, for example:
	love . preciseWithMovingPlayer
you can get a random one using
	love . rtd

]])
	for i=1, #mod do
		modname = mod[i]
		if modname:match("%.lua$") then
			modname = string.sub(modname, 1, -5)
			if i % 2 == 0 then
				io.write(modname..'\n')
			else
				while #modname < 30 do
					modname = modname .. ' '
				end
				io.write(modname)
			end
		end
	end
	io.write('\n\n')
	love.event.push('quit')
end
