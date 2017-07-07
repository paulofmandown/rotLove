local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Noise = ROT.Class:extend("Noise")

function Noise:get() end

return Noise
