local Noise_PATH =({...})[1]:gsub("[%.\\/]noise$", "") .. '/'
local class  =require (Noise_PATH .. 'vendor/30log')

local Noise=class{ __name }

function Noise:__init()
    self.__name='Noise'
end

function Noise:get(x, y) end

return Noise
