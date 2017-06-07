local Feature_PATH =({...})[1]:gsub("[%.\\/]feature$", "") .. '/'
local class  =require (Feature_PATH .. 'vendor/30log')

local Feature = class("Feature")
function Feature:isValid() end
function Feature:create() end
function Feature:debug() end
function Feature:createRandomAt() end
return Feature
