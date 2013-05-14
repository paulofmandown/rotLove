local Feature_PATH =({...})[1]:gsub("[%.\\/]feature$", "") .. '/'
local class  =require (Feature_PATH .. 'vendor/30log')

local Feature = class {  }
Feature.__name='Feature'
function Feature:isValid(gen, canBeDugCallback) end
function Feature:create(gen, digCallback) end
function Feature:debug() end
function Feature:createRandomAt(x, y, dx, dy, options) end
return Feature
