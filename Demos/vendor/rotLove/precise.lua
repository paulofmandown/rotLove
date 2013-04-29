Precise_PATH =({...})[1]:gsub("[%.\\/]precise$", "") .. '/'
local class  =require (Precise_PATH .. 'vendor/30log')

Precise=FOV:extends{ __name, _lightPasses, _options }

function Precise:__init(lightPassesCallback, options)
    Precise.super.__init(self, lightPassesCallback, options)
end

function Precise:compute(x, y, R, callback)
    callback(x, y, 0, 1)
    local SHADOWS={}

    local cx, cy, blocks, A1, A2, visibility

    for r=1,R do
        local neighbors=self:_getCircle(x, y, r)
        local neighborCount=#neighbors

        for i=1,neighborCount do
            local cx=neighbors[i][1]
            local cy=neighbors[i][2]
            A1={2*i-1, 2*neighborCount}
            A2={2*i+1, 2*neighborCount}

            blocks    =not self:_lightPasses(cx, cy)
            write('Tile at: '..cx..','..cy)
            write('Blocking: '..(blocks and 'true' or 'false'))
            write('Arc 1: '..table.concat(A1, ','))
            write('Arc 2: '..table.concat(A2, ','))
            write('#SHADOWS: '..#SHADOWS)
            visibility=self:_checkVisibility(A1, A2, blocks, SHADOWS)
            if visibility~=0 then callback(cx, cy, r, visibility) end
            if #SHADOWS==2 and SHADOWS[1][1]==0 and SHADOWS[2][1]==SHADOWS[2][2] then
                break
            end
        end
    end
end

function Precise:_checkVisibility(A1, A2, blocks, SHADOWS)
    if A1[1]>A2[1] then
        local v1=self:_checkVisibility(A1, {A1[2], A1[2]}, blocks, SHADOWS)
        local v2=self:_checkVisibility({0, 1}, A2, blocks, SHADOWS)
        return (v1+v2)/2
    end
    local index1=0
    local edge1 =false
    while index1<#SHADOWS do
        index1=index1+1
        local old =SHADOWS[index1]
        local diff=old[1]*A1[2] - A1[1]*old[2]
        if diff>=0 then
            if diff==0 and (index1)%2==0 then edge1=true end
            break
        end
    end

    local index2=#SHADOWS+1
    local edge2=false
    while index2>1 do
        index2=index2-1
        local old =SHADOWS[index2]
        local diff=A2[1]*old[2] - old[1]*A2[2]
        if diff >= 0 then
            if diff==0 and (index2)%2==1 then edge2=true end
            break
        end
    end
    write('index1: '..index1)
    write('index2: '..index2)
    local visible=true
    if index1==index2 and (edge1 or edge2) then
        visible=false
    elseif edge1 and edge2 and index1+1==index2 and (index2)%2==1 then
        visible=false
    elseif index1>index2 and (index1)%2==1 then
        visible=false
    end
    write('visible: '..(visible and 'true' or 'false'))
    if not visible then return 0 end
    local visibleLength=0
    local remove=index2-index1
    if remove%2==1 then
        if (index1)%2==1 then
            if #SHADOWS>0 then
                local P=SHADOWS[index1]
                visibleLength=(A2[1]*P[2] - P[1]*A2[2]) / (P[2]*A2[2])
                write('visibleLength: '..visibleLength)
            end
            if blocks then table.splice(SHADOWS, index1, remove, {A2}) end
        else
            if #SHADOWS>0 then
                local P=SHADOWS[index2]
                visibleLength=(P[1]*A1[2] - A1[1]*P[2]) / (A1[2]*P[2])
                write('visibleLength: '..visibleLength)
            end
            if blocks then table.splice(SHADOWS, index1, remove, {A1}) end
        end
    else
        if (index1)%2==1 then
            if #SHADOWS>0 then
                local P1=SHADOWS[index1]
                local P2=SHADOWS[index2]
                visibleLength=(P2[1]*P1[2] - P1[1]*P2[2]) / (P1[2]*P2[2])
                write('visibleLength: '..visibleLength)
            end
            if blocks then table.splice(SHADOWS, index1, remove) end
        else
            if blocks then table.splice(SHADOWS, index1, remove, {A1, A2}) end
            return 1
        end
    end

    local arcLength=(A2[1]*A1[2] - A1[1]*A2[2]) / (A1[2]*A2[2])
    return visibleLength/arcLength
end

return Precise
