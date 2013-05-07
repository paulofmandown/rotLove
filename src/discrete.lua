Discrete_PATH =({...})[1]:gsub("[%.\\/]discrete$", "") .. '/'
local class  =require (Discrete_PATH .. 'vendor/30log')

Discrete=FOV:extends{ __name, _lightPasses, _options }

function Discrete:__init(lightPassesCallback, options)
    Discrete.super.__init(self, lightPassesCallback, options)
end

function Discrete:compute(x, y, R, callback)

end

return Discrete
