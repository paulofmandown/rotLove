local USE_30LOG = true
local PATH = (...):gsub(('.[^./\\]*'):rep(2) .. '$', '')

local BaseClass

-- try loading 30log

if not BaseClass and USE_30LOG then
    local ok, class = pcall(require, PATH .. '.vendor.30log')
    if ok then BaseClass = class('BaseClass') end
end

-- fallback if no class library present

if not BaseClass then
    BaseClass = {}

    function BaseClass:new (...)
        local t = setmetatable({}, self)
        t:init(...)
        return t
    end

    function BaseClass:extend (name, t)
        t = t or {}
        t.__index = t
        t.super = self
        return setmetatable(t, { __call = self.new, __index = self })
    end

    function BaseClass:init ()
    end
end

return BaseClass

