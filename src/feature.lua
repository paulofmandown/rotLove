local ROT = require((...):gsub('[^./\\]*$', '') .. 'rot')
local Feature = ROT.Class:extend("Feature")

function Feature:isValid() end
function Feature:create() end
function Feature:debug() end
function Feature:createRandomAt() end
return Feature
