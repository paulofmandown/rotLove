ROT=require 'src.rot'

data={}

function love.load()
    --f=ROT.Display:new()

    -- use this to stress out the map creation and path finding
    -- should take about a second to do one demo with this
    f=ROT.Display:new(256, 100, .275)

    map=ROT.Map.Uniform(f:getWidth(), f:getHeight())
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
    p1=getRandomFloor(data)
    p2=getRandomFloor(data)
    p3=getRandomFloor(data)
    start=os.clock()
    astar=ROT.Path.AStar(p1[1], p1[2], passableCallback)
    start=os.clock()
    astar:compute(p2[1], p2[2], astarCallback)
    start=os.clock()
    astar:compute(p3[1], p3[2], astarCallback)

    f:write('S', tonumber(p1[1]), tonumber(p1[2]), nil, { 0, 0, 255, 255 })
    f:write('E', tonumber(p2[1]), tonumber(p2[2]), nil, { 0, 0, 255, 255 })
    f:write('E', tonumber(p3[1]), tonumber(p3[2]), nil, { 0, 0, 255, 255 })

end

function astarCallback(x, y)
    f:write('.', x, y, nil, { 136, 0, 0, 255 })
end

function passableCallback(x, y) return data[x..','..y]==0 end

function getRandomFloor(data)
    local key=nil
    while true do
        key=ROT.RNG:random(1,f:getWidth())..','..
            ROT.RNG:random(1,f:getHeight())
        if data[key]==0 then
            return key:split(',')
        end
    end
end

function mapCallback(x, y, val)
    data[x..','..y]=val
    f:write(val==0 and '.' or '#', x, y)
end
