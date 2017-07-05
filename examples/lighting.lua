ROT=require 'src.rot'

function love.load()
    f=ROT.Display(80, 24)
    colorhandler=ROT.Color:new()
    rng=ROT.RNG.Twister:new()
    rng:randomseed()
    maps={
        "Arena",
        "DividedMaze",
        "IceyMaze",
        "EllerMaze",
        "Cellular",
        "Digger",
        "Uniform",
        "Rogue",
        "Brogue",
    }
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
	f:clear()
    mapData={}
    lightData={}
    -- Map type defaults to random or you can hard-code it here
    mapType=maps[rng:random(1,#maps)]
    map= ROT.Map[mapType]:new(f:getWidth(), f:getHeight())
    if map.randomize then
        floorValue=1
        map:randomize(.5)
        for i=1,5 do
            map:create(mapCallback)
        end
    else
        floorValue=0
        map:create(mapCallback)
    end
    fov=ROT.FOV.Precise:new(lightPasses, {topology=4})
    lighting=ROT.Lighting(reflectivityCB, {range=12, passes=2})
    lighting:setFOV(fov)
    for i=1,10 do
        local point=getRandomFloor()
        f:write('*',tonumber(point[1]),tonumber(point[2]))
        lighting:setLight(tonumber(point[1]),tonumber(point[2]), getRandomColor())
    end
    lighting:compute(lightingCallback)
    local ambientLight={r=0, g=0, b=0, a=255}
    for k,_ in pairs(mapData) do
        local parts=k:split(',')
        local x    =tonumber(parts[1])
        local y    =tonumber(parts[2])
        local baseColor=mapData[k]==floorValue and {r=125, g=125, b=125, a=255} or {r=50, g=50, b=50, a=255}
        local light=ambientLight
        local char=f:getCharacter(x, y)
        if lightData[k] then
            light=colorhandler:add(light, lightData[k])
        end
        local finalColor=colorhandler:multiply(baseColor, light)
        char=not lightData[k] and ' ' or char~=' ' and char or mapData[x..','..y]~=floorValue and '#' or ' '

        f:write(char, x, y, light, finalColor)
    end
    mapData=nil
    lightData=nil
    map=nil
    lighting=nil
    fov=nil
end

function lightingCallback(x, y, color)
    local key=x..','..y
    lightData[x..','..y]=color
end

function getRandomColor()
    return { r=math.floor(rng:random(0,125)),
             g=math.floor(rng:random(0,125)),
             b=math.floor(rng:random(0,125)),
             a=255}
end

function getRandomFloor()
    local key=nil
    while true do
        key=rng:random(1,f:getWidth())..','..rng:random(1,f:getHeight())
        if mapData[key]==floorValue then
            return key:split(',')
        end
    end
end

function reflectivityCB(lighting, x, y)
    local key=x..','..y
    return mapData[key]==floorValue and .3 or 0
end

function lightPasses(fov, x, y)
    return mapData[x..','..y]==floorValue
end

function mapCallback(x, y, val)
    mapData[x..','..y]=val
end
