local BaseClass = {}

function BaseClass:new(...)
    local t = setmetatable({}, self)
    t:init(...)
    return t
end

function BaseClass:extend(name, t)
    t = t or {}
    t.__index = t
    t.super = self
    return setmetatable(t, { __call = self.new, __index = self })
end

function BaseClass:init()
end

return BaseClass

