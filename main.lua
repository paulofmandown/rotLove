--- rotLove Demo runner
-- specify which example you'd like to see on the command line
--
-- to list all available examples, do:
--    love . list

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
    io.write([[
ERROR: Please specify a demo, for example:
    love . preciseWithMovingPlayer
you can get a random one using
    love . rtd
]])

    love.event.push('quit')
end
