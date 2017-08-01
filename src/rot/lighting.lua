--- Lighting Calculator.
-- based on a traditional FOV for multiple light sources and multiple passes.
-- @module ROT.Lighting
local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Lighting = ROT.Class:extend("Lighting")

local PointSet = ROT.Type.PointSet
local Grid = ROT.Type.Grid

--- Constructor.
-- @tparam function reflectivityCallback Callback to retrieve cell reflectivity must return float(0..1)
  -- @tparam int reflectivityCallback.x x-position of cell
  -- @tparam int reflectivityCallback.y y-position of cell
-- @tparam table options Options
  -- @tparam[opt=1] int options.passes Number of passes. 1 equals to simple FOV of all light sources, >1 means a *highly simplified* radiosity-like algorithm.
  -- @tparam[opt=100] int options.emissionThreshold Cells with emissivity > threshold will be treated as light source in the next pass.
  -- @tparam[opt=10] int options.range Max light range
function Lighting:init(reflectivityCallback, options)
    self._reflectivityCallback=reflectivityCallback
    self._options={passes=1, emissionThreshold=100, range=10}
    self._fov=nil
    self._lights = Grid()
    self._reflectivityCache = Grid()
    self._fovCache = Grid()

    if options then for k,_ in pairs(options) do self._options[k]=options[k] end end
end

--- Set FOV
-- Set the Field of View algorithm used to calculate light emission
-- @tparam userdata fov Class/Module used to calculate fov Must have compute(x, y, range, cb) method. Typically you would supply ROT.FOV.Precise:new() here.
-- @treturn ROT.Lighting self
-- @see ROT.FOV.Precise
-- @see ROT.FOV.Bresenham
function Lighting:setFOV(fov)
    self._fov=fov
    self._fovCache = Grid()
    return self
end

--- Add or remove a light source
-- @tparam int x x-position of light source
-- @tparam int y y-position of light source
-- @tparam nil|string|table color An string accepted by Color:fromString(str) or a color table. A nil value here will remove the light source at x, y
-- @treturn ROT.Lighting self
-- @see ROT.Color
function Lighting:setLight(x, y, color)
    self._lights:setCell(x, y,
        type(color)=='string' and ROT.Color.fromString(color) or color or nil)
    return self
end

--- Compute.
-- Compute the light sources and lit cells
-- @tparam function lightingCallback Will be called with (x, y, color) for every lit cell
-- @treturn ROT.Lighting self
function Lighting:compute(lightingCallback)
    local doneCells = PointSet()
    local emittingCells = Grid()
    local litCells = Grid()

    for _, x, y, light in self._lights:each() do
        local emitted = emittingCells:getCell(x, y)
        if not emitted then
            emitted = { 0, 0, 0 }
            emittingCells:setCell(x, y, emitted)
        end
        ROT.Color.add_(emitted, light)
    end

    for i=1,self._options.passes do
        self:_emitLight(emittingCells, litCells, doneCells)
        if i<self._options.passes then
            emittingCells=self:_computeEmitters(litCells, doneCells)
        end
    end

    for _, x, y, value in litCells:each() do
        lightingCallback(x, y, value)
    end

    return self

end

function Lighting:_emitLight(emittingCells, litCells, doneCells)
    for _, x, y, v in emittingCells:each() do
        self:_emitLightFromCell(x, y, v, litCells)
        doneCells:push(x, y)
    end
    return self
end

function Lighting:_computeEmitters(litCells, doneCells)
    local result=Grid()
    if not litCells then return nil end
    for _, x, y, color in litCells:each() do
        if not doneCells:find(x, y) then

            local reflectivity = self._reflectivityCache:getCell(x, y)
            if not reflectivity then
                reflectivity = self:_reflectivityCallback(x, y)
                self._reflectivityCache:setCell(x, y, reflectivity)
            end

            if reflectivity>0 then
                local emission ={}
                local intensity=0
                for l, c in ipairs(color) do
                    if l < 4 then
                        local part=math.floor(c*reflectivity)
                        emission[l]=part
                        intensity=intensity+part
                    end
                end
                if intensity>self._options.emissionThreshold then
                    result:setCell(x, y, emission)
                end
            end
        end
    end

    return result
end

function Lighting:_emitLightFromCell(x, y, color, litCells)
    local fov = self._fovCache:getCell(x, y) or self:_updateFOV(x, y)
    for _, x, y, formFactor in fov:each() do
        local cellColor = litCells:getCell(x, y)
        if not cellColor then
            cellColor = { 0, 0, 0 }
            litCells:setCell(x, y, cellColor)
        end
        for l = 1, 3 do
            cellColor[l] = cellColor[l] + math.floor(color[l]*formFactor)
        end
    end
    return self
end

function Lighting:_updateFOV(x, y)
    local cache = Grid()
    self._fovCache:setCell(x, y, cache)
    local range=self._options.range
    local function cb(x, y, r, vis)
        local formFactor=vis*(1-r/range)
        if formFactor==0 then return end
        cache:setCell(x, y, formFactor)
    end
    self._fov:compute(x, y, range, cb)

    return cache
end

return Lighting

