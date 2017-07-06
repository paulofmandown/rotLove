--- Precise Shadowcasting Field of View calculator.
-- The Precise shadow casting algorithm developed by Ondřej Žára for rot.js.
-- See http://roguebasin.roguelikedevelopment.org/index.php?title=Precise_Shadowcasting_in_JavaScript
-- @module ROT.FOV.Precise
local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Precise=ROT.FOV:extend("Precise")
--- Constructor.
-- Called with ROT.FOV.Precise:new()
-- @tparam function lightPassesCallback A function with two parameters (x, y) that returns true if a map cell will allow light to pass through
-- @tparam table options Options
  -- @tparam int options.topology Direction for light movement Accepted values: (4 or 8)
function Precise:init(lightPassesCallback, options)
    Precise.super.init(self, lightPassesCallback, options)
end

--- Compute.
-- Get visibility from a given point
-- @tparam int x x-position of center of FOV
-- @tparam int y y-position of center of FOV
-- @tparam int R radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam number callback.visibility The cell's visibility rating (from 0-1). How well can you see this cell?
function Precise:compute(x, y, R, callback)
    callback(x, y, 0, 1)
    local SHADOWS={}

    local blocks, A1, A2, visibility

    for r=1,R do
        local neighbors=self:_getCircle(x, y, r)
        local neighborCount=#neighbors

        for i=0,neighborCount-1 do
            local cx=neighbors[i+1][1]
            local cy=neighbors[i+1][2]
            A1={i>0 and 2*i-1 or 2*neighborCount-1, 2*neighborCount}
            A2={2*i+1, 2*neighborCount}

            blocks    =not self:_lightPasses(cx, cy)
            visibility=self:_checkVisibility(A1, A2, blocks, SHADOWS)
            if visibility>0 then callback(cx, cy, r, visibility) end
            if #SHADOWS==2 and SHADOWS[1][1]==0 and SHADOWS[2][1]==SHADOWS[2][2] then
                break
            end
        end
    end
end

local function splice(t, i, rn, it) -- table, index, numberToRemove, insertTable
    if rn>0 then
        for _=1,rn do
            table.remove(t, i)
        end
    end
    if it and #it>0 then
        for idx=i,i+#it-1 do
            local el=table.remove(it, 1)
            if el then table.insert(t, idx, el) end
        end
    end
end

function Precise:_checkVisibility(A1, A2, blocks, SHADOWS)
    if A1[1]>A2[1] then
        local v1=self:_checkVisibility(A1, {A1[2], A1[2]}, blocks, SHADOWS)
        local v2=self:_checkVisibility({0, 1}, A2, blocks, SHADOWS)
        return (v1+v2)/2
    end
    local index1=1
    local edge1 =false
    while index1<=#SHADOWS do
        local old =SHADOWS[index1]
        local diff=old[1]*A1[2] - A1[1]*old[2]
        if diff>=0 then
            if diff==0 and (index1)%2==1 then edge1=true end
            break
        end
        index1=index1+1
    end

    local index2=#SHADOWS
    local edge2=false
    while index2>0 do
        local old =SHADOWS[index2]
        local diff=A2[1]*old[2] - old[1]*A2[2]
        if diff >= 0 then
            if diff==0 and (index2)%2==0 then edge2=true end
            break
        end
        index2=index2-1
    end
    local visible=true
    if index1==index2 and (edge1 or edge2) then
        visible=false
    elseif edge1 and edge2 and index1+1==index2 and (index2)%2==0 then
        visible=false
    elseif index1>index2 and (index1)%2==0 then
        visible=false
    end
    if not visible then return 0 end
    local visibleLength=0
    local remove=index2-index1+1
    if remove%2==1 then
        if (index1)%2==0 then
            if #SHADOWS>0 then
                local P=SHADOWS[index1]
                visibleLength=(A2[1]*P[2] - P[1]*A2[2]) / (P[2]*A2[2])
            end
            if blocks then splice(SHADOWS, index1, remove, {A2}) end
        else
            if #SHADOWS>0 then
                local P=SHADOWS[index2]
                visibleLength=(P[1]*A1[2] - A1[1]*P[2]) / (A1[2]*P[2])
            end
            if blocks then splice(SHADOWS, index1, remove, {A1}) end
        end
    else
        if (index1)%2==0 then
            if #SHADOWS>0 then
                local P1=SHADOWS[index1]
                local P2=SHADOWS[index2]
                visibleLength=(P2[1]*P1[2] - P1[1]*P2[2]) / (P1[2]*P2[2])
            end
            if blocks then splice(SHADOWS, index1, remove) end
        else
            if blocks then splice(SHADOWS, index1, remove, {A1, A2}) end
            return 1
        end
    end

    local arcLength=(A2[1]*A1[2] - A1[1]*A2[2]) / (A1[2]*A2[2])
    return visibleLength/arcLength
end

return Precise
