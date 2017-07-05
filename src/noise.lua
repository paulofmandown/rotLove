local ROT = require((...):gsub('[^./\\]*$', '') .. 'rot')
local Noise = ROT.Class:extend("Noise")

function Noise:get() end

return Noise
