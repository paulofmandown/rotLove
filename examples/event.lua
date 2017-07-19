--[[ Event Queue ]]--
ROT=require 'src.rot'
function love.load()
    f=ROT.Display(80,24)
    q=ROT.EventQueue()
    q:add('e1', 100)
    q:add('e2', 50)
    q:add('e3', 10)
    q:remove('e2')
    f:writeCenter(tostring(q:get()), 11)
    f:writeCenter(tostring(q:get()), 12)
    f:writeCenter(tostring(q:getTime()), 13)
end
function love.draw() f:draw() end
--]]
