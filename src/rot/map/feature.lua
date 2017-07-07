local ROT = require((...):gsub(('.[^./\\]*'):rep(2) .. '$', ''))
local Feature = ROT.Class:extend("Feature")

function Feature:isValid() end
function Feature:create() end
function Feature:debug() end
function Feature:createRandomAt() end
return Feature
