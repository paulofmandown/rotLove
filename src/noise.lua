local Noise_PATH =({...})[1]:gsub("[%.\\/]noise$", "") .. '/'
local class  =require (Noise_PATH .. 'vendor/30log')

local Noise=class{ __name }
Noise.__name='Noise'

function Noise:get(x, y) end

return Noise
