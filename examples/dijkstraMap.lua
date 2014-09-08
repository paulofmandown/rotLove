ROT=require 'vendor/rotLove/rotLove'

data={}

function love.load()
    f=ROT.Display:new()

    -- use this to stress out the map creation and path finding
    -- should take about a second to do one demo with this
    --f=ROT.Display:new(256, 100, .275)

    rng=ROT.RNG.Twister:new()
    rng:randomseed()
    map=ROT.Map.Rogue(f:getWidth(), f:getHeight())
end

update=true
function love.update()
    if update then
        update=false
        doTheThing()
    end
end

function doTheThing()
    map:create(mapCallback)
    local start=os.clock()
    local tile=getRandomFloor()
    local dmap=ROT.DijkstraMap:new(tile[1], tile[2], f:getWidth(), f:getHeight(), passableCallback)
    --[[
        local tile=getRandomFloor()
        dmap:addGoal(tile[1], tile[2])
        local tile=getRandomFloor()
        dmap:addGoal(tile[1], tile[2])
        local tile=getRandomFloor()
        dmap:addGoal(tile[1], tile[2])
        local tile=getRandomFloor()
        dmap:addGoal(tile[1], tile[2])
        local tile=getRandomFloor()
        dmap:addGoal(tile[1], tile[2])
        local tile=getRandomFloor()
        dmap:addGoal(tile[1], tile[2])
        local tile=getRandomFloor()
        dmap:addGoal(tile[1], tile[2])
        local tile=getRandomFloor()
        dmap:addGoal(tile[1], tile[2])
        local tile=getRandomFloor()
        dmap:addGoal(tile[1], tile[2])
    --]]
    dmap:compute()
    dmap:writeMapToConsole()
    write('O: '..os.clock()-start)

end

function getRandomFloor()
    local key=nil
    while true do
        local i=rng:random(1,f:getWidth())
        local j=rng:random(1,f:getHeight())
        if data[i][j]==0 then
            return {i,j}
        end
    end
end

function love.keypressed() update=true end

function passableCallback(x, y) return data[x][y]==0 end

function mapCallback(x, y, val)
    if not data[x] then data[x]={} end
    data[x][y]=val
end
