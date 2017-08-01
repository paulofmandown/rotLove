--- Visual Display.
-- A Code Page 437 terminal emulator based on AsciiPanel.
-- @module ROT.Display
local Display_Path = (...):gsub(('.[^./\\]*'):rep(2) .. '$', ''):gsub('[./\\]', '/') .. '/'
local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Display = ROT.Class:extend("Display")

--- Constructor.
-- The display constructor. Called when ROT.Display:new() is called.
-- @tparam[opt=80] int w Width of display in number of characters
-- @tparam[opt=24] int h Height of display in number of characters
-- @tparam[opt=1] float scale Window scale modifier applied to glyph dimensions
-- @tparam[opt] table dfg Default foreground color as a table defined as {r,g,b,a}
-- @tparam[opt] table dbg Default background color
-- @tparam[opt=false] boolean fullOrFlags In Love 0.8.0: Use fullscreen In Love 0.9.0: a table defined for love.graphics.setMode
-- @tparam[opt=false] boolean vsync Use vsync
-- @tparam[opt=0] int fsaa Number of fsaa passes
-- @return nil
function Display:init(w, h, scale, dfg, dbg, fullOrFlags, vsync, fsaa)
    self.__name='Display'
    self.widthInChars = w and w or 80
    self.heightInChars= h and h or 24
    self.scale=scale or 1
    self.charWidth=9*self.scale
    self.charHeight=16*self.scale
    self.glyphs={}
    self.chars={{}}
    self.backgroundColors={{}}
    self.foregroundColors={{}}
    self.oldChars={{}}
    self.oldBackgroundColors={{}}
    self.oldForegroundColors={{}}
    self.graphics=love.graphics
    if love.window then
        love.window.setMode(self.charWidth*self.widthInChars, self.charHeight*self.heightInChars, fullOrFlags)
        self.drawQ=self.graphics.draw
    else
        self.graphics.setMode(self.charWidth*self.widthInChars, self.charHeight*self.heightInChars, fullOrFlags, vsync, fsaa)
        self.drawQ=self.graphics.drawq
    end

    self.defaultForegroundColor=dfg and dfg or { 235, 235, 235 }
    self.defaultBackgroundColor=dbg and dbg or { 15, 15, 15 }

    self.graphics.setBackgroundColor(self.defaultBackgroundColor)

    self.canvas=self.graphics.newCanvas(self.charWidth*self.widthInChars, self.charHeight*self.heightInChars)

    self.glyphSprite=self.graphics.newImage(Display_Path .. 'img/cp437.png')
    for i=0,255 do
        local sx=(i%32)*9
        local sy=math.floor(i/32)*16
        self.glyphs[i]=self.graphics.newQuad(sx, sy, 9, 16, self.glyphSprite:getWidth(), self.glyphSprite:getHeight())
    end

    for i=1,self.widthInChars do
        self.chars[i]               = {}
        self.backgroundColors[i]    = {}
        self.foregroundColors[i]    = {}
        self.oldChars[i]            = {}
        self.oldBackgroundColors[i] = {}
        self.oldForegroundColors[i] = {}
        for j=1,self.heightInChars do
            self.chars[i][j]               = 32
            self.backgroundColors[i][j]    = self.defaultBackgroundColor
            self.foregroundColors[i][j]    = self.defaultForegroundColor
            self.oldChars[i][j]            = nil
            self.oldBackgroundColors[i][j] = nil
            self.oldForegroundColors[i][j] = nil
        end
    end
end

--- Draw.
-- The main draw function. This should be called from love.draw() to display any written characters to screen
function Display:draw()
    self.graphics.setCanvas(self.canvas)
    for x=1,self.widthInChars do
        for y=1,self.heightInChars do
            local c =self.chars[x][y]
            local bg=self.backgroundColors[x][y]
            local fg=self.foregroundColors[x][y]
            local px=(x-1)*self.charWidth
            local py=(y-1)*self.charHeight
            if self.oldChars[x][y]            ~= c  or
               self.oldBackgroundColors[x][y] ~= bg or
               self.oldForegroundColors[x][y] ~= fg then

                self:_setColor(bg)
                self.graphics.rectangle('fill', px, py, self.charWidth, self.charHeight)
                if c~=32 and c~=255 then
                    local qd=self.glyphs[c]
                    self:_setColor(fg)
                    self.drawQ(self.glyphSprite, qd, px, py, nil, self.scale)
                end

                self.oldChars[x][y]            = c
                self.oldBackgroundColors[x][y] = bg
                self.oldForegroundColors[x][y] = fg
            end
        end
    end
    self.graphics.setCanvas()
    self.graphics.setColor(255,255,255,255)
    self.graphics.draw(self.canvas)
end

--- Contains point.
-- Returns true if point x,y can be drawn to display.
function Display:contains(x, y)
    return x>0 and x<=self:getWidth() and y>0 and y<=self:getHeight()
end

function Display:getCharHeight() return self.charHeight end
function Display:getCharWidth() return self.charWidth end
function Display:getWidth() return self:getWidthInChars() end
function Display:getHeight() return self:getHeightInChars() end
function Display:getHeightInChars() return self.heightInChars end
function Display:getWidthInChars() return self.widthInChars end
function Display:getDefaultBackgroundColor() return self.defaultBackgroundColor end
function Display:getDefaultForegroundColor() return self.defaultForegroundColor end

--- Get a character.
-- returns the character being displayed at position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn string The character
function Display:getCharacter(x, y)
    local c=self.chars[x][y]
    return c and string.char(c) or nil
end

--- Get a background color.
-- returns the current background color of the character written to position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn table The background color as a table defined as {r,g,b,a}
function Display:getBackgroundColor(x, y) return self.backgroundColors[x][y] end

--- Get a foreground color.
-- returns the current foreground color of the character written to position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn table The foreground color as a table defined as {r,g,b,a}
function Display:getForegroundColor(x, y) return self.foregroundColors[x][y] end

--- Set Default Background Color.
-- Sets the background color to be used when it is not provided
-- @tparam table c The background color as a table defined as {r,g,b,a}
function Display:setDefaultBackgroundColor(c)
    self.defaultBackgroundColor=c and c or self.defaultBackgroundColor
end

--- Set Defaul Foreground Color.
-- Sets the foreground color to be used when it is not provided
-- @tparam table c The foreground color as a table defined as {r,g,b,a}
function Display:setDefaultForegroundColor(c)
    self.defaultForegroundColor=c and c or self.defaultForegroundColor
end

--- Clear the screen.
-- By default wipes the screen to the default background color.
-- You can provide a character, x-position, y-position, width, height, fore-color and back-color
-- and write the same character to a portion of the screen
-- @tparam[opt=' '] string c A character to write to the screen - may fail for strings with a length > 1
-- @tparam[opt=1] int x The x-position from which to begin the wipe
-- @tparam[opt=1] int y The y-position from which to begin the wipe
-- @tparam[opt] int w The number of chars to wipe in the x direction
-- @tparam[opt] int h Then number of chars to wipe in the y direction
-- @tparam[opt] table fg The color used to write the provided character
-- @tparam[opt] table bg the color used to fill in the background of the cleared space
function Display:clear(c, x, y, w, h, fg, bg)
    c = c or ' '
    w = w or self.widthInChars
    local s = c:rep(self.widthInChars)
    x =self:_validateX(x, s)
    y =self:_validateY(y)
    h =self:_validateHeight(y, h)
    fg=self:_validateForegroundColor(fg)
    bg=self:_validateBackgroundColor(bg)
    for i=0,h-1 do
        self:_writeValidatedString(s, x, y+i, fg, bg)
    end
end

--- Clear canvas.
-- runs the clear method of the Love2D canvas object being used to write to the screen
function Display:clearCanvas()
    self.canvas:clear()
end

--- Write.
-- Writes a string to the screen
-- @tparam string s The string to be written
-- @tparam[opt=1] int x The x-position where the string will be written
-- @tparam[opt=1] int y The y-position where the string will be written
-- @tparam[opt] table fg The color used to write the provided string
-- @tparam[opt] table bg the color used to fill in the string's background
function Display:write(s, x, y, fg, bg)
    ROT.assert(s, "Display:write() must have string as param")
    x = self:_validateX(x, s)
    y = self:_validateY(y, s)
    fg= self:_validateForegroundColor(fg)
    bg= self:_validateBackgroundColor(bg)

    self:_writeValidatedString(s, x, y, fg, bg)
end

--- Write Center.
-- write a string centered on the middle of the screen
-- @tparam string s The string to be written
-- @tparam[opt=1] int y The y-position where the string will be written
-- @tparam[opt] table fg The color used to write the provided string
-- @tparam[opt] table bg the color used to fill in the string's background
function Display:writeCenter(s, y, fg, bg)
    ROT.assert(s, "Display:writeCenter() must have string as param")
    ROT.assert(#s<self.widthInChars, "Length of ",s," is greater than screen width")
    y = y and y or math.floor((self:getHeightInChars() - 1) / 2)
    y = self:_validateY(y, s)
    fg= self:_validateForegroundColor(fg)
    bg= self:_validateBackgroundColor(bg)

    local x=math.floor((self.widthInChars-#s)/2)
    self:_writeValidatedString(s, x, y, fg, bg)
end

function Display:_writeValidatedString(s, x, y, fg, bg)
    for i=1,#s do
        self.backgroundColors[x+i-1][y] = bg
        self.foregroundColors[x+i-1][y] = fg
        self.chars[x+i-1][y]            = s:byte(i)
    end
end


function Display:_validateX(x, s)
    x = x and x or 1
    ROT.assert(x>0 and x<=self.widthInChars, "X value must be between 0 and ",self.widthInChars)
    ROT.assert((x+#s)-1<=self.widthInChars, "X value plus length of String must be between 0 and ",self.widthInChars)
    return x
end
function Display:_validateY(y)
    y = y and y or 1
    ROT.assert(y>0 and y<=self.heightInChars, "Y value must be between 0 and ",self.heightInChars)
    return y
end
function Display:_validateForegroundColor(c)
    c = c or self.defaultForegroundColor
    ROT.assert(#c > 2, 'Foreground Color must have at least 3 components')
    for i = 1, #c do c[i]=self:_clamp(c[i]) end
    return c
end
function Display:_validateBackgroundColor(c)
    c = c or self.defaultBackgroundColor
    ROT.assert(#c > 2, 'Background Color must have at least 3 components')
    for i = 1, #c do c[i]=self:_clamp(c[i]) end
    return c
end
function Display:_validateHeight(y, h)
    h=h and h or self.heightInChars-y+1
    ROT.assert(h>0, "Height must be greater than 0. Height provided: ",h)
    ROT.assert(y+h-1<=self.heightInChars, "Height + y value must be less than screen height. y, height: ",y,', ',h)
    return h
end
function Display:_setColor(c)
    love.graphics.setColor(c or self.defaultForegroundColor)
end
function Display:_clamp(n)
    return n<0 and 0 or n>255 and 255 or n
end

--- Draw text.
-- Draws a text at given position. Optionally wraps at a maximum length.
-- @tparam number x
-- @tparam number y
-- @tparam string text May contain color/background format specifiers, %c{name}/%b{name}, both optional. %c{}/%b{} resets to default.
-- @tparam number maxWidth wrap at what width (optional)?
-- @treturn number lines drawn
function Display:drawText(x, y, text, maxWidth)
    local fg
    local bg
    local cx = x
    local cy = y
    local lines = 1
    if not maxWidth then maxWidth = self.widthInChars-x end

    local tokens = ROT.Text.tokenize(text, maxWidth)

    while #tokens > 0 do -- interpret tokenized opcode stream
        local token = table.remove(tokens, 1)
        if token.type == ROT.Text.TYPE_TEXT then
            local isSpace, isPrevSpace, isFullWidth, isPrevFullWidth
            for i = 1, #token.value do
                local cc = token.value:byte(i)
                local c = token.value:sub(i, i)
                -- TODO: chars will never be full-width without special handling
                -- TODO: ... so the next 15 lines or so do some pointless stuff
                -- Assign to `true` when the current char is full-width.
                isFullWidth = (cc > 0xff00 and cc < 0xff61)
                    or (cc > 0xffdc and cc < 0xffe8)
                    or cc > 0xffee
                -- Current char is space, whatever full-width or half-width both are OK.
                isSpace = c:byte() == 0x20 or c:byte() == 0x3000
                -- The previous char is full-width and
                -- current char is nether half-width nor a space.
                if isPrevFullWidth and not isFullWidth and not isSpace then
                    cx = cx + 1 -- add an extra position
                end
                -- The current char is full-width and
                -- the previous char is not a space.
                if isFullWidth and not isPrevSpace then
                    cx = cx + 1 -- add an extra position
                end
                fg = (fg == '' or not fg) and self.defaultForegroundColor
                    or type(fg) == 'string' and ROT.Color.fromString(fg) or fg
                bg = (bg == '' or not bg) and self.defaultBackgroundColor
                    or type(bg) == 'string' and ROT.Color.fromString(bg) or bg
                self:_writeValidatedString(c, cx, cy, fg, bg)
                cx = cx + 1
                isPrevSpace = isSpace
                isPrevFullWidth = isFullWidth
            end
        elseif token.type == ROT.Text.TYPE_FG then
            fg = token.value or nil
        elseif token.type == ROT.Text.TYPE_BG then
            bg = token.value or nil
        elseif token.type == ROT.Text.TYPE_NEWLINE then
            cx = x
            cy = cy + 1
            lines = lines + 1
        end
    end

    return lines
end


return Display
