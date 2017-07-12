--[[ Precise Shadowcasting ]]--

setmetatable(_G, { __newindex = function (k, v) error('global ' .. v, 2) end })
local ROT=require 'src.rot'
setmetatable(_G, nil)

function calbak(x, y, val)
    map[x..','..y]=val
end

function lightCalbak(fov, x, y)
    local key=x..','..y
    if map[key] then
        return map[key]==0
    end
    return false
end

function computeCalbak(x, y, r, v)
    local key  =x..','..y
    if not map[key] then return end
    field[key]=1
    seen[key]=1
end

function placePlayer()
    local key =nil
    local char='#'
    while true do
        key=ROT.RNG:random(1,f:getWidth())..','..
            ROT.RNG:random(1,f:getHeight())
        if map[key]==0 then
            pos = key:split(',')
            player.x, player.y=tonumber(pos[1]), tonumber(pos[2])
            f:write('@', player.x, player.y)
            break
        end
    end
end

function love.load()
    f  =ROT.Display(80, 24)
    map={}
    field={}
    seen={}
    seenColor={ 100, 100, 100, 255 }
    fieldColor={ 225, 225, 225, 255 }
    fieldbg={ 50, 50, 50, 255 }
    update=false
    player={x=1, y=1}
    doTheThing()
end

function doTheThing()
    uni=ROT.Map.Uniform:new(f:getWidth(), f:getHeight())
    uni:create(calbak)
    fov=ROT.FOV.Precise:new(lightCalbak)--, {topology=4})
    placePlayer()
    fov:compute(player.x, player.y, 10, computeCalbak)
end

function love.update()
    if update then
        update=false
        seen={}
        doTheThing()
    end
    f:clear()
    for x=1,f:getWidth() do
        for y=1,f:getHeight() do
            local key=x..','..y
            if seen[key] then
                char=key==player.x..','..player.y and '@' or map[key]==0 and '.' or map[key]==1 and '#'
                f:write(char, x, y, field[key] and fieldColor or seenColor, field[key] and fieldbg or nil)
            end
        end
    end
    local s='Use numpad/vimkeys to move!'
    f:write(s, f:getWidth()-#s, f:getHeight())
end
function love.keypressed(key)
    local newPos={0,0}
    if     key=='kp1' then newPos={-1, 1}
    elseif key=='kp2' or key=='j' then newPos={ 0, 1}
    elseif key=='kp3' then newPos={ 1, 1}
    elseif key=='kp4' or key=='h' then newPos={-1, 0}
    elseif key=='kp5' then newPos={ 0, 0}
    elseif key=='kp6' or key=='l' then newPos={ 1, 0}
    elseif key=='kp7' then newPos={-1,-1}
    elseif key=='kp8' or key=='k' then newPos={ 0,-1}
    elseif key=='kp9' then newPos={ 1,-1}
    else
        update=true
    end
    if newPos~={0,0} then
        local newx = player.x+newPos[1]
        local newy = player.y+newPos[2]
        if map[newx..','..newy]==0 then
            field={}
            player.x=newx
            player.y=newy
            fov:compute(player.x, player.y, 10, computeCalbak)
        end
    end

end
function love.draw() f:draw() end
