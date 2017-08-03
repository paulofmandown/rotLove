--[[ Rogue ]]
ROT=require 'src.rot'
movers={}
colors={}
table.insert(colors, ROT.Color.fromString('blue'))
table.insert(colors, ROT.Color.fromString('red'))
table.insert(colors, ROT.Color.fromString('green'))
table.insert(colors, ROT.Color.fromString('yellow'))
function love.load()
    f  =ROT.Display()
    maps={
        "DividedMaze",
        "IceyMaze",
        "EllerMaze",
    }
    dothething()
end
function love.keypressed()
    dothething()
end
tsl=0
tbf=1/30
function love.update(dt)
    --tsl=tsl+dt
    if true then --tsl>tbf then
        tsl=tsl-tbf
        for _,mover in pairs(movers) do
            local dir={dijkMap:dirTowardsGoal(mover.x, mover.y)}
            if dir[1] and dir[2] and mover.x and mover.y then
                f:write(map[mover.x][mover.y], mover.x, mover.y, nil, ROT.Color.interpolate(mover.color, mover.oc))
                mover.x=mover.x+dir[1]
                mover.y=mover.y+dir[2]
                local oc=f:getBackgroundColor(mover.x, mover.y)
                mover.oc=oc==f:getDefaultBackgroundColor() and ROT.Color.fromString('dimgrey') or oc
                f:write('@', mover.x, mover.y, nil, mover.color)
            end
        end
    end
end

function dothething()
    mapType=maps[ROT.RNG:random(1,#maps)]
    rog= ROT.Map[mapType]:new(f:getWidth(), f:getHeight())
    map={}
    for i=1,f:getWidth() do map[i]={} end
    if rog.randomize then
        floorValue=1
        rog:randomize(.5)
        for i=1,5 do
            rog:create(calbak)
        end
    else
        floorValue=0
        rog:create(calbak)
    end
    --rog:randomize(.5)
    --while rog:create(calbak) do end
    rog:create(calbak)
    while true do
        local x=math.random(1,f:getWidth())
        local y=math.random(1,f:getHeight())

        if map[x][y]=='.' then
            dijkMap=ROT.Path.DijkstraMap(x,y,dijkCalbak)
            break
        end
    end
    dijkMap:compute()
    movers={}
    while #movers<40 do
        local x=math.random(1,f:getWidth())
        local y=math.random(1,f:getHeight())

        if map[x][y]=='.' then
            table.insert(movers, {x=x,y=y,color=getRandomColor(),oc=f:getDefaultBackgroundColor()})
        end
    end

    --[[while true do
        local dir=dijkMap:dirTowardsGoal(mover.x, mover.y)
        if not dir then break end
        mover.x=mover.x+dir[1]
        mover.y=mover.y+dir[2]
        local x=mover.x
        local y=mover.y
        f:write(map[x][y], x, y, nil, { 125, 15, 15, 255 })
    end--]]
end


function love.draw() f:draw() end
function calbak(x, y, val)
    map[x][y]=val==floorValue and '.' or '#'
    f:write(map[x][y], x, y)
end
function dijkCalbak(x,y) return map[x][y]=='.' end

function getRandomColor()
    return { math.floor(ROT.RNG:random(0,255)),
             math.floor(ROT.RNG:random(0,255)),
             math.floor(ROT.RNG:random(0,255)),
             255}
end
