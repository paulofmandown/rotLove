local Display_Path = ({...})[1]:gsub("[%.\\/]display$", "") .. '/'
local class=require (Display_Path .. 'vendor/30log')

local Display = class {
	__name,
	color,
	widthInChars,
	heightInChars,
	charWidth,
	charHeight,
	defaultBackgroundColor,
	defaultForegroundColor,
	full,
	vsync,
	fsaa,
	glyphSprite,
	glyphs,
	chars,
	backgroundColors,
	foregroundColors,
	oldChars,
	oldBackgroundColors,
	oldForegroundColors,
	canvas
}

--[[ Init/Constructor
	   Create a new 'terminal' with:
	      rlLove  ='Path/to/RLLove_Folder/rlLove'
	      terminal=RLLove(w, h, dfg, dbg, full, vsync, fsaa)
	    where
	    w    = width of terminal in number of characters (dictates what populates love.graphics.setMode)
	    h    = height of terminal in number of characters (dictates what populates love.graphics.setMode)
        scale= glyphSize (1: charWidth=9, charHeight=16)
	    dfg  = default foreground color of type [red, green, blue, alpha]
	    dbg  = default background color of type [red, green, blue, alpha]
	    full = boolean for use full screen (populates love.graphics.setMode)
	    vsync= boolean for use vsync (populates love.graphics.setMode)
	    fsaa = number of fsaa samples (populates love.graphics.setMode)
  ]]
function Display:__init(w, h, scale, dfg, dbg, full, vsync, fsaa)
	self.__name='Display'
	self.widthInChars = w and w or 80
	self.heightInChars= h and h or 24
	self.full         = full and full or false
	self.vsync        = vsync and vsync or false
	self.fsaa         = fsaa and fsaa or 0
    self.scale=scale and scale or 1
	self.charWidth=self.scale*9
	self.charHeight=self.scale*16
	self.glyphs={}
	self.chars={{}}
	self.backgroundColors={{}}
	self.foregroundColors={{}}
	self.oldChars={{}}
	self.oldBackgroundColors={{}}
	self.oldForegroundColors={{}}
	love.graphics.setMode(self.charWidth*self.widthInChars, self.charHeight*self.heightInChars, self.full, self.vsync, self.fsaa)

	self.defaultForegroundColor=dfg and dfg or {r=235, g=235, b=235, a=255}
	self.defaultBackgroundColor=dbg and dgb or {r=15, g=15, b=15, a=255}

	love.graphics.setBackgroundColor(self.defaultBackgroundColor.r,
									 self.defaultBackgroundColor.g,
									 self.defaultBackgroundColor.b,
									 self.defaultBackgroundColor.a)

	self.canvas=love.graphics.newCanvas(self.charWidth*self.widthInChars, self.charHeight*self.heightInChars)

	-- Populate the glyph image table
	self.glyphSprite=love.graphics.newImage(Display_Path .. 'img/cp437.png')
	for i=0,255 do
		sx=(i%32)*9
		sy=math.floor(i/32)*16
		self.glyphs[i]=love.graphics.newQuad(sx, sy, 9, 16, self.glyphSprite:getWidth(), self.glyphSprite:getHeight())
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

function Display:draw()
	love.graphics.setCanvas(self.canvas)
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

		   		self:setColor(bg)
		   		love.graphics.rectangle('fill', px, py, self.charWidth, self.charHeight)
                if c~=32 and c~=255 then
    		   		local qd=self.glyphs[c]
	       	   		self:setColor(fg)
		      		love.graphics.drawq(self.glyphSprite, qd, px, py, nil, self.scale)
                end

				self.oldChars[x][y]            = c
				self.oldBackgroundColors[x][y] = bg
				self.oldForegroundColors[x][y] = fg
			end
		end
	end
	love.graphics.setCanvas()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(self.canvas)
end

-- Gets
function Display:getCharHeight() return self.charHeight end
function Display:getCharWidth() return self.charWidth end
function Display:getWidth() return self:getWidthInChars() end
function Display:getHeight() return self:getHeightInChars() end
function Display:getHeightInChars() return self.heightInChars end
function Display:getWidthInChars() return self.widthInChars end
function Display:getDefaultBackgroundColor() return self.defaultBackgroundColor end
function Display:getDefaultForegroundColor() return self.defaultForegroundColor end
function Display:getCharacter(x, y) return string.char(self.chars[x][y]) end
function Display:getBackgroundColor(x, y) return self.backgroundColors[x][y] end
function Display:getForegroundColor(x, y) return self.foregroundColors[x][y] end
-- Sets
function Display:setDefaultBackgroundColor(c)
	self.defaultBackgroundColor=c and c or self.color.black
end
function Display:setDefaultForegroundColor(c)
	self.defaultForegroundColor=c and c or {r=235, g=235, b=235, a=255}
end


-- other
--[[ Clear a designated rectangle of space with specified char and colors
	 c  = Character to use in wipe (nil defaults to space)
	 x  = x-coord of top-left of clearing box (defaults to 1)
	 y  = y-coord of top-left of clearing box (defaults to 1)
	 w  = distance x of clearing box (defaults to widthInChars)
	 h  = distance y of clearing box (defaults to heightInChars)
	 fg = foreground color to use (defaults to defaultForegroundColor)
	 bg = background color to use (defaults to defaultBackgroundColor)
]]
function Display:clear(c, x, y, w, h, fg, bg)
	c =c and c or ' '
	w =w and w or self.widthInChars
	local s=''
	for i=1,w do
		s=s..c
	end
	x =self:validateX(x, s)
	y =self:validateY(y)
	h =self:validateHeight(y, h)
	fg=self:validateForegroundColor(fg)
	bg=self:validateBackgroundColor(bg)
	for i=0,h do
		self:writeValidatedString(s, x, y+i, fg, bg)
	end
end

function Display:clearCanvas()
	self.canvas:clear()
end

--[[ Write character or string to the display
     s  = String/Char to write            (required)
     x  = x Position in display           (optional)
     y  = y Position in display           (optional)
     fg = foreground color of char/string (optional)
     bg = background color of char/string (optional)
]]
function Display:write(s, x, y, fg, bg)
	assert(s, "Display:write() must have string as param")
	x = self:validateX(x, s)
	y = self:validateY(y, s)
	fg= self:validateForegroundColor(fg)
	bg= self:validateBackgroundColor(bg)

	self:writeValidatedString(s, x, y, fg, bg)
end

function Display:writeCenter(s, y, fg, bg)
	assert(s, "Display:writeCenter() must have string as param")
	assert(#s<self.widthInChars, "Length of "..s.." is greater than screen width")
	y = y and y or math.floor((self:getHeightInChars() - 1) / 2)
	y = self:validateY(y, s)
	fg= self:validateForegroundColor(fg)
	bg= self:validateBackgroundColor(bg)

	local x=math.floor((self.widthInChars-#s)/2)
	self:writeValidatedString(s, x, y, fg, bg)
end

function Display:writeValidatedString(s, x, y, fg, bg)
	for i=1,#s do
		self.backgroundColors[x+i-1][y] = bg
		self.foregroundColors[x+i-1][y] = fg
		self.chars[x+i-1][y]            = s:byte(i)
	end
end


function Display:validateX(x, s)
	x = x and x or 1
	assert(x>0 and x<=self.widthInChars, "X value must be between 0 and "..self.widthInChars)
	assert((x+#s)-1<=self.widthInChars, "X value plus length of String must be between 0 and "..self.widthInChars)
	return x
end
function Display:validateY(y)
	y = y and y or 1
	assert(y>0 and y<=self.heightInChars, "Y value must be between 0 and "..self.heightInChars)
	return y
end
function Display:validateForegroundColor(c)
	c = c and c or self.defaultForegroundColor
    for k,_ in pairs(c) do c[k]=self:_clamp(c[k]) end
	assert(c.a and c.r and c.g and c.b, 'Foreground Color must be of type { r = int, g = int, b = int, a = int }')
	return c
end
function Display:validateBackgroundColor(c)
	c = c and c or self.defaultBackgroundColor
    for k,_ in pairs(c) do c[k]=self:_clamp(c[k]) end
	assert(c.a and c.r and c.g and c.b, 'Background Color must be of type { r = int, g = int, b = int, a = int }')
	return c
end
function Display:validateHeight(y, h)
	h=h and h or self.heightInChars-y
	assert(h>0, "Height must be greater than 0. Height provided: "..h)
	assert(y+h<=self.heightInChars, "Height + y value must be less than screen height. y, height: "..y..', '..h)
	return h
end
function Display:setColor(c)
	c = c and c or self.defaultForegroundColor
	love.graphics.setColor(c.r, c.g, c.b, c.a)
end
function Display:_clamp(n)
    return n<0 and 0 or n>255 and 255 or n
end
return Display
