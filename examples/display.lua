ROT = require 'vendor/rotLove/rot'
function love.load()
  -- create a display object with the following.
    -- Display(widthInCharacters(80), heightInCharacters(24), characterScale(1)
    --         defaultForegroundColor({r=235, g=235, b=235, a=255}),
    --         defaultBackgroundColor({r=15 , g=15 , b=15 , a=255}),
    --         useFullScreen, useVSync, numberOfFsaaSamples (false, false, 0))
    display=ROT.Display:new()
  -- and write some things out.
    local x_position=1
    local y_position=1
    display:write('some string or character', x_position, y_position)

  -- or write something to the center
    y_position=5
    display:writeCenter('another string/character', y_position)

  -- you can clear the display with:
  -- display:clear()

  -- and you can specify an area to clear with:
  -- display:clear(char, x_position, y_position, width, height)
    -- defaults are: ' ', 1, 1, displayWidthInChars, displayHeightInChars
end
function love.draw()
    display:draw()
end
function love.update() end
