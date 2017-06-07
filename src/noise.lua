local Noise_PATH =({...})[1]:gsub("[%.\\/]noise$", "") .. '/'
local class  =require (Noise_PATH .. 'vendor/30log')

local Noise=class("Noise")

function Noise:get() end

return Noise
