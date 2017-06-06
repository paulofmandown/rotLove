local USE_30LOG = true
local PATH = (...):gsub('[^./\\]*$', '')

if USE_30LOG then
    local ok, class = pcall(require, PATH .. 'vendor.30log')
    if ok then return class('BaseClass') end
end

-- built-in fallback

local function new (proto, ...)
    local instance = setmetatable({}, proto)
    instance:init(...)
    return instance
end

local function extend (super, name, t)
    t = t or {}
    t.__index, t.super = t, super
    return setmetatable(t, { __call = new, __index = super })
end

return extend(nil, nil, { new = new, extend = extend, init = function()end })

