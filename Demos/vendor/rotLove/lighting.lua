local Lighting_PATH=({...})[1]:gsub("[%.\\/]lighting$", "") .. '/'
local class  =require (Lighting_PATH .. 'vendor/30log')

local Lighting=class {  }

function Lighting:__init(reflectivityCallback, options)
    self._reflectivityCallback=reflectivityCallback
    self._options={passes=1, emissionThreshold=100, range=10}
    self._fov=nil
    self._lights={}
    self._reflectivityCache={}
    self._fovCache={}

    self._colorHandler=ROT.Color:new()

    if options then for k,_ in pairs(options) do self._options[k]=options[k] end end
end

function Lighting:setFOV(fov)
    self._fov=fov
    self._fovCache={}
    return self
end

function Lighting:setLight(x, y, color)
    local key=x..','..y
    if color then
        self._lights[key]=type(color)=='string' and self._colorHandler:fromString(color) or color
    else
        self._lights[key]=nil
    end
    return self
end

function Lighting:compute(lightingCallback)
    local doneCells={}
    local emittingCells={}
    local litCells={}

    for k,_ in pairs(self._lights) do
        local light=self._lights[k]
        if not emittingCells[k] then emittingCells[k]={r=0,g=0,b=0,a=255} end
        self._colorHandler:add_(emittingCells[k], light)
    end

    for i=1,self._options.passes do
        self:_emitLight(emittingCells, litCells, doneCells)
        if i<self._options.passes then
            emittingCells=self:_computeEmitters(litCells, doneCells)
        end
    end

    for k,_ in pairs(litCells) do
        local parts=k:split(',')
        local x=tonumber(parts[1])
        local y=tonumber(parts[2])
        lightingCallback(x, y, litCells[k])
    end

    return self

end

function Lighting:_emitLight(emittingCells, litCells, doneCells)
    for k,_ in pairs(emittingCells) do
        local parts=k:split(',')
        local x=tonumber(parts[1])
        local y=tonumber(parts[2])
        self:_emitLightFromCell(x, y, emittingCells[k], litCells)
        doneCells[k]=1
    end
    return self
end

function Lighting:_computeEmitters(litCells, doneCells)
    local result={}
    if not litCells then return nil end
    for k,_ in pairs(litCells) do
        if not doneCells[k] then
            local color=litCells[k]

            local reflectivity
            if self._reflectivityCache and self._reflectivityCache[k] then
                reflectivity=self._reflectivityCache[k]
            else
                local parts=k:split(',')
                local x=tonumber(parts[1])
                local y=tonumber(parts[2])
                reflectivity=self:_reflectivityCallback(x, y)
                self._reflectivityCache[k]=reflectivity
            end

            if reflectivity>0 then
                local emission ={}
                local intensity=0
                for l,_ in pairs(color) do
                    if l~='a' then
                        local part=math.round(color[l]*reflectivity)
                        emission[l]=part
                        intensity=intensity+part
                    end
                end
                if intensity>self._options.emissionThreshold then
                    result[k]=emission
                end
            end
        end
    end

    return result
end

function Lighting:_emitLightFromCell(x, y, color, litCells)
    local key=x..','..y
    local fov
    if self._fovCache[key] then fov=self._fovCache[key]
    else fov=self:_updateFOV(x, y)
    end
    local result
    local formFactor
    for k,_ in pairs(fov) do
        formFactor=fov[k]
        if not litCells[k] then
            litCells[k]={r=0,g=0,b=0,a=255}
        end
        for l,_ in pairs(color) do
            if l~='a' then
                litCells[k][l]=litCells[k][l]+math.round(color[l]*formFactor)
            end
        end
    end
    return self
end

function Lighting:_updateFOV(x, y)
    local key1=x..','..y
    local cache={}
    self._fovCache[key1]=cache
    local range=self._options.range
    local function cb(x, y, r, vis)
        local key2=x..','..y
        local formFactor=vis*(1-r/range)
        if formFactor==0 then return end
        cache[key2]=formFactor
    end
    self._fov:compute(x, y, range, cb)

    return cache
end

return Lighting
