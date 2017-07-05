ROT=require 'src.rot'
function love.load()
    f =ROT.Display(79,29)
    cl=ROT.Map.Cellular:new(f:getWidth(), f:getHeight())
    cl:randomize(.55)
    cl:create(calbak)
end
function love.draw() f:draw() end

wait=false
id=2
largest=2
largestCount=0
function love.update()
    local start=os.clock()
    cl:randomize(.55)
    if wait then return end
    local cellStart=os.clock()
    for i=1,5 do cl:create(calbak) end
    for x=1,f:getWidth() do
        for y=1,f:getHeight() do
            if cl._map[x][y]==1 then
                local count=fillBlob(x,y,cl._map, id)
                if count>largestCount then
                    largest=id
                    largestCount=count
                end
                id=id+1
            end
        end
    end
    writeMap()
    largest=2
    id=2
    largestCount=0
    wait=true
    i=0
end
function love.keypressed() wait=false end
function writeMap()
    for x=1,f:getWidth() do
        for y=1,f:getHeight() do
            f:write(cl._map[x][y]==largest and '.' or '#', x, y)
        end
    end
end

function calbak(x, y, val)
    f:write(val==1 and '#' or '.', x, y)
end

function fillBlob(x,y,m,id)
    m[x][y]=id
    local todo={{x,y}}
    local dirs=ROT.DIRS.EIGHT
    local size=1
    repeat
        local pos=table.remove(todo, 1)
        for i=1,#dirs do
            local rx=pos[1]+dirs[i][1]
            local ry=pos[2]+dirs[i][2]
            if rx<1 or rx>f:getWidth() or ry<1 or ry>f:getHeight() then

            elseif m[rx][ry]==1 then
                m[rx][ry]=id
                table.insert(todo,{ rx, ry })
                size=size+1
            end
        end
    until #todo==0
    return size
end
