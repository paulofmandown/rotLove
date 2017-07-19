--[[ Event Queue ]]--
ROT=require 'src.rot'
function love.load()
    love.window.setMode(800, 600)
    f=ROT.Display(80,24)
    f:drawText(30, 11, "%c{brown}Everything is all right%c{}, just relax.")
end
function love.draw() f:draw() end
--]]
