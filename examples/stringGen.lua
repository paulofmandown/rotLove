--[[ String Gen ]]--
ROT = require 'vendor/rotLove/rotLove'
function love.load()
    -- make your display
    frame=ROT.Display()
    -- now make your string generator
    sg = ROT.StringGenerator()
    -- read in your names.
    -- where names.txt is a plain-text list of mixed-case names (one per line)
    for name in io.lines('names.txt') do
        -- .observe(string) reads a string and learns from it.
        sg:observe(name)
    end
    -- .getStats() will tell you how many words your string gen has seen
                              -- how many different contexts it has seen
                                 -- (i.e.: the context of the letter 'n' in seen is 'see')
                              -- and how many
    frame:writeCenter(sg:getStats(), 1)
    for i=2,24 do
        local name = sg:generate()
        if #name < 80 then
            frame:writeCenter(name, i)
        else i=i-1 end
    end
end
time=5.01
function love.update() end
function love.draw() frame:draw() end
--]]
