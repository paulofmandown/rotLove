--[[ Bresenham Line of Sight ]]--
ROT=require 'vendor/rotLove/rot'

function calbak(x, y, val)
    map[x..','..y]=val
    f:write(val==1 and '#' or '.', x, y, {r=110, g=110, b=110, a=255}, {r=0, g=0, b=0, a=255})
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
    local color= {r=121, g=121, b=0, a=255}
    f:write(r>0 and f:getCharacter(x, y) or '@', x, y, nil, color)
end
local player={x=1, y=1}
function placePlayer()
    local key =nil
    local char='#'
    local rng=ROT.RNG.Twister:new()
    rng:randomseed()
    while true do
        key=rng:random(1,f:getWidth())..','..rng:random(1,f:getHeight())
        if map[key]==0 then
            pos = key:split(',')
            player.x, player.y=tonumber(pos[1]), tonumber(pos[2])
            f:write('@', player.x, player.y)
            break
        end
    end
end

function love.load()
    f  =ROT.Display(40, 25)
    map={}
    doTheThing()
end
function doTheThing()
    mapgen=ROT.Map.Arena:new(f:getWidth(), f:getHeight())
    mapgen:create(calbak)
    fov=ROT.FOV.Bresenham:new(lightCalbak, {useDiamond=true})
    placePlayer()
    fov:compute(player.x, player.y, 10, computeCalbak)
end
local update=false
function love.update()
    if update then
        update=false
        doTheThing()
    end
end
function love.keypressed() update=true end
function love.draw() f:draw() end
