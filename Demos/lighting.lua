ROT= require 'vendor/rotLove/rot'

function love.load()
    f=ROT.Display()--175, 80, .375)
    colorhandler=ROT.Color:new()
    rng=ROT.RNG.Twister:new()
    rng:randomseed()
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
    mapData={}
    lightData={}
    map= ROT.Map.Cellular:new(f:getWidth(), f:getHeight())
    map:randomize(.5)
    for i=1,5 do map:create(mapCallback) end
    -- Uncomment this to run the cellular create as many times as possible
    --while map:create(mapCallback) do end
    fov=ROT.FOV.Bresenham:new(lightPasses, {topology=4})
    lighting=ROT.Lighting(reflectivityCB, {range=12, passes=2})
    lighting:setFOV(fov)
    for i=1,3 do
        local point=getRandomFloor()
        local color=getRandomColor()
        lighting:setLight(tonumber(point[1]),tonumber(point[2]), color)
    end
    lighting:compute(lightingCallback)
    local ambientLight={r=100, g=100, b=100, a=255}
    for k,_ in pairs(mapData) do
        local parts=k:split(',')
        local x    =tonumber(parts[1])
        local y    =tonumber(parts[2])
        local baseColor=mapData[k]>0 and {r=100, g=100, b=100, a=255} or {r=50, g=50, b=50, a=255}
        local light=ambientLight
        if lightData[k] then
            light=colorhandler:add(light, lightData[k])
        end
        local finalColor=colorhandler:multiply(baseColor, light)
        f:write(' ', x, y, nil, finalColor)
    end
end

function lightingCallback(x, y, color)
    local key=x..','..y
    lightData[x..','..y]=color
end

function getRandomColor()
    return { r=math.floor(rng:random(0,255)),
             g=math.floor(rng:random(0,255)),
             b=math.floor(rng:random(0,255)),
             a=255}
end

function getRandomFloor()
    local key=nil
    while true do
        key=rng:random(1,f:getWidth())..','..rng:random(1,f:getHeight())
        if mapData[key]==1 then
            return key:split(',')
        end
    end
end

function reflectivityCB(lighting, x, y)
    local key=x..','..y
    return mapData[key]==1 and .3 or 0
end

function lightPasses(fov, x, y)
    return mapData[x..','..y]==1
end

function mapCallback(x, y, val)
    mapData[x..','..y]=val
end
