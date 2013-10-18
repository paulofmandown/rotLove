--- Visual Display.
-- A UTF-8 based text display.
-- @module ROT.TextDisplay
local TextDisplay_Path = ({...})[1]:gsub("[%.\\/]textDisplay$", "") .. '/'
local class=require (TextDisplay_Path .. 'vendor/30log')
local TextDisplay=class {  }
TextDisplay.__name='TextDisplay'

--- Constructor.
-- The display constructor. Called when ROT.TextDisplay:new() is called.
-- @tparam[opt=80] int w Width of display in number of characters
-- @tparam[opt=24] int h Height of display in number of characters
-- @tparam[opt] string|file|data font Any valid object accepted by love.graphics.newFont
-- @tparam[opt=10] int size font size
-- @tparam[opt] table dfg Default foreground color as a table defined as {r,g,b,a}
-- @tparam[opt] table dbg Default background color
-- @tparam[opt=false] boolean full Use fullscreen
-- @tparam[opt=false] boolean vsync Use vsync
-- @tparam[opt=0] int fsaa Number of fsaa passes
-- @return nil
function TextDisplay:__init(w, h, font, size, dfg, dbg, full, vsync, fsaa)
    self._font    =love.graphics.newFont(font)
    self._fontSize=size and size or 10
    if self._font then love.graphics.setFont(self._font, self._fontSize)
    else
        love.graphics.setFont(self._fontSize)
        self._font=love.graphics.getFont()
    end
    self._charWidth    =self._font:getWidth(' ')
    self._charHeight   =self._font:getHeight()
    self._widthInChars =w and w or 80
    self._heightInChars=h and h or 24
    self._full         = full and full or false
    self._vsync        = vsync and vsync or false
    self._fsaa         = fsaa and fsaa or 0

    love.graphics.setMode(self._charWidth*self._widthInChars, self._charHeight*self._heightInChars, self._full, self._vsync, self._fsaa)

    self.defaultForegroundColor=dfg and dfg or {r=235,g=235,b=235,a=255}
    self.defaultBackgroundColor=dbg and dgb or {r=15,g=15,b=15,a=255}

    love.graphics.setBackgroundColor(self.defaultBackgroundColor.r,
                                     self.defaultBackgroundColor.g,
                                     self.defaultBackgroundColor.b,
                                     self.defaultBackgroundColor.a)

    self._canvas=love.graphics.newCanvas(self._charWidth*self._widthInChars, self._charHeight*self._heightInChars)

    self._chars              ={}
    self._backgroundColors   ={}
    self._foregroundColors   ={}
    self._oldChars           ={}
    self._oldBackgroundColors={}
    self._oldForegroundColors={}

    for i=1,self._widthInChars do
        self._chars[i]               = {}
        self._backgroundColors[i]    = {}
        self._foregroundColors[i]    = {}
        self._oldChars[i]            = {}
        self._oldBackgroundColors[i] = {}
        self._oldForegroundColors[i] = {}
        for j=1,self._heightInChars do
            self._chars[i][j]               = ' '
            self._backgroundColors[i][j]    = self.defaultBackgroundColor
            self._foregroundColors[i][j]    = self.defaultForegroundColor
            self._oldChars[i][j]            = nil
            self._oldBackgroundColors[i][j] = nil
            self._oldForegroundColors[i][j] = nil
        end
    end
end

function TextDisplay:draw()
    love.graphics.setCanvas(self._canvas)
    for x=1,self._widthInChars do for y=1,self._heightInChars do
        local c =self._chars[x][y]
        local bg=self._backgroundColors[x][y]
        local fg=self._foregroundColors[x][y]
        local px=(x-1)*self._charWidth
        local py=(y-1)*self._charHeight
        if self._oldChars[x][y]            ~= c  or
           self._oldBackgroundColors[x][y] ~= bg or
           self._oldForegroundColors[x][y] ~= fg then

            self:_setColor(bg)
            love.graphics.rectangle('fill', px, py, self._charWidth, self._charHeight)
            self:_setColor(fg)
            love.graphics.print(c, px, py)
            self._oldChars[x][y]            = c
            self._oldBackgroundColors[x][y] = bg
            self._oldForegroundColors[x][y] = fg
        end
    end end
    love.graphics.setCanvas()
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(self._canvas)
end

function TextDisplay:getCharHeight() return self._charHeight end
function TextDisplay:getCharWidth() return self._charWidth end
function TextDisplay:getWidth() return self:getWidthInChars() end
function TextDisplay:getHeight() return self:getHeightInChars() end
function TextDisplay:getHeightInChars() return self._heightInChars end
function TextDisplay:getWidthInChars() return self._widthInChars end
function TextDisplay:getDefaultBackgroundColor() return self.defaultBackgroundColor end
function TextDisplay:getDefaultForegroundColor() return self.defaultForegroundColor end

--- Get a character.
-- returns the character being displayed at position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn string The character
function TextDisplay:getCharacter(x, y)
    local c=self.chars[x][y]
    return c and string.char(c) or nil
end
--- Get a background color.
-- returns the current background color of the character written to position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn table The background color as a table defined as {r,g,b,a}
function TextDisplay:getBackgroundColor(x, y) return self._backgroundColors[x][y] end

--- Get a foreground color.
-- returns the current foreground color of the character written to position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn table The foreground color as a table defined as {r,g,b,a}
function TextDisplay:getForegroundColor(x, y) return self._foregroundColors[x][y] end

--- Set Default Background Color.
-- Sets the background color to be used when it is not provided
-- @tparam table c The background color as a table defined as {r,g,b,a}
function TextDisplay:setDefaultBackgroundColor(c)
    self.defaultBackgroundColor=c and c or self.defaultBackgroundColor
end

--- Set Defaul Foreground Color.
-- Sets the foreground color to be used when it is not provided
-- @tparam table c The foreground color as a table defined as {r,g,b,a}
function TextDisplay:setDefaultForegroundColor(c)
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
function TextDisplay:clear(c, x, y, w, h, fg, bg)
    c =c and c or ' '
    w =w and w or self._widthInChars
    local s=''
    for i=1,w do
        s=s..c
    end
    x =self:_validateX(x, s)
    y =self:_validateY(y)
    h =self:_validateHeight(y, h)
    fg=self:_validateForegroundColor(fg)
    bg=self:_validateBackgroundColor(bg)
    for i=0,h do
        self:_writeValidatedString(s, x, y+i, fg, bg)
    end
end

--- Clear canvas.
-- runs the clear method of the Love2D canvas object being used to write to the screen
function TextDisplay:clearCanvas()
    self._canvas:clear()
end

--- Write.
-- Writes a string to the screen
-- @tparam string s The string to be written
-- @tparam[opt=1] int x The x-position where the string will be written
-- @tparam[opt=1] int y The y-position where the string will be written
-- @tparam[opt] table fg The color used to write the provided string
-- @tparam[opt] table bg the color used to fill in the string's background
function TextDisplay:write(s, x, y, fg, bg)
    assert(s, "Display:write() must have string as param")
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
function TextDisplay:writeCenter(s, y, fg, bg)
    assert(s, "Display:writeCenter() must have string as param")
    assert(#s<self._widthInChars, "Length of "..s.." is greater than screen width")
    y = y and y or math.floor((self:getHeightInChars() - 1) / 2)
    y = self:_validateY(y, s)
    fg= self:_validateForegroundColor(fg)
    bg= self:_validateBackgroundColor(bg)

    local x=math.floor((self._widthInChars-#s)/2)
    self:_writeValidatedString(s, x, y, fg, bg)
end

function TextDisplay:_writeValidatedString(s, x, y, fg, bg)
    for i=1,#s do
        self._backgroundColors[x+i-1][y] = bg
        self._foregroundColors[x+i-1][y] = fg
        self._chars[x+i-1][y]            = s:sub(i,i)
    end
end


function TextDisplay:_validateX(x, s)
    x = x and x or 1
    assert(x>0 and x<=self._widthInChars, "X value must be between 0 and "..self._widthInChars)
    assert((x+#s)-1<=self._widthInChars, "X value plus length of String must be between 0 and "..self._widthInChars..' string: '..s..'; x:'..x)
    return x
end
function TextDisplay:_validateY(y)
    y = y and y or 1
    assert(y>0 and y<=self._heightInChars, "Y value must be between 0 and "..self._heightInChars)
    return y
end
function TextDisplay:_validateForegroundColor(c)
    c = c and c or self.defaultForegroundColor
    for k,_ in pairs(c) do c[k]=self:_clamp(c[k]) end
    assert(c.a and c.r and c.g and c.b, 'Foreground Color must be of type { r = int, g = int, b = int, a = int }')
    return c
end
function TextDisplay:_validateBackgroundColor(c)
    c = c and c or self.defaultBackgroundColor
    for k,_ in pairs(c) do c[k]=self:_clamp(c[k]) end
    assert(c.a and c.r and c.g and c.b, 'Background Color must be of type { r = int, g = int, b = int, a = int }')
    return c
end
function TextDisplay:_validateHeight(y, h)
    h=h and h or self._heightInChars-y
    assert(h>0, "Height must be greater than 0. Height provided: "..h)
    assert(y+h<=self._heightInChars, "Height + y value must be less than screen height. y, height: "..y..', '..h)
    return h
end
function TextDisplay:_setColor(c)
    c = c and c or self.defaultForegroundColor
    love.graphics.setColor(c.r, c.g, c.b, c.a)
end
function TextDisplay:_clamp(n)
    return n<0 and 0 or n>255 and 255 or n
end
return TextDisplay
