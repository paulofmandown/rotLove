ROT=require 'vendor/rotLove/rotLove'

data={}

function love.load()
    --f=ROT.Display:new()

    -- use this to stress out the map creation and path finding
    -- should take about a second to do one demo with this
    f=ROT.Display:new(256, 100, .275)

    rng=ROT.RNG.Twister:new()
    rng:randomseed()
    map=ROT.Map.Uniform(f:getWidth(), f:getHeight(), {dugPercentage=.7})
    doTheThing()
end

function love.draw() f:draw() end

update=false
function love.update()
    if update then
        update=false
        doTheThing()
    end
end
function love.keypressed() update=true end

function doTheThing()
    local start=os.clock()
    map:create(mapCallback)
    write('Map Create in '..os.clock()-start)

    p1=getRandomFloor(data)
    p2=getRandomFloor(data)
    p3=getRandomFloor(data)

    start=os.clock()
    dijkstra=ROT.Path.Dijkstra(p1[1], p1[2], passableCallback)
    write('Dijkstra init in '..os.clock()-start)
    start=os.clock()
    dijkstra:compute(p2[1], p2[2], dijkstraCallback)
    write('Dijkstra Compute in '..os.clock()-start)
    start=os.clock()
    dijkstra:compute(p3[1], p3[2], dijkstraCallback)
    write('Dijkstra Compute in '..os.clock()-start)

    f:write('S', tonumber(p1[1]), tonumber(p1[2]), nil, {r=0, g=0, b=255, a=255})
    f:write('E', tonumber(p2[1]), tonumber(p2[2]), nil, {r=0, g=0, b=255, a=255})
    f:write('E', tonumber(p3[1]), tonumber(p3[2]), nil, {r=0, g=0, b=255, a=255})

end

function dijkstraCallback(x, y)
    f:write('.', x, y, nil, {r=136, g=0, b=0, a=255})
end

function passableCallback(x, y) return data[x..','..y]==0 end

function getRandomFloor(data)
    local key=nil
    while true do
        key=rng:random(1,f:getWidth())..','..rng:random(1,f:getHeight())
        if data[key]==0 then
            return key:split(',')
        end
    end
end

function mapCallback(x, y, val)
    data[x..','..y]=val
    f:write(val==0 and '.' or '#', x, y)
end
