--- 30Log by Roland Yonaba see LICENSE.txt
local type, pairs, setmetatable, rawget, baseMt, _instances, _classes, class = type, pairs, setmetatable, rawget, {}, {}, {}
local function deep_copy(t, dest)
  local t, r = t or {}, dest or {}
  for k,v in pairs(t) do
    if type(v) == 'table' and k ~= "__index" then r[k] = deep_copy(v) else r[k] = v end
  end
  return r
end
local function instantiate(self,...)
  local instance = {} ; _instances[instance] = tostring(instance)
  if self.__init then
        if type(self.__init) == 'table' then deep_copy(self.__init, instance) else self.__init(instance, ...) end
    end
  return setmetatable(instance,self)
end
local function extends(self,extra_params)
  local heirClass = class(extra_params)
  heirClass.__index, heirClass.super = heirClass, self
  return setmetatable(heirClass,self)
end
baseMt = { __call = function (self,...) return self:new(...) end, __tostring = function(self,...)
    if _instances[self] then return ('object (of %s): <%s>'):format((rawget(getmetatable(self),'__name') or 'Unnamed'), _instances[self]) end
    return _classes[self] and ('class (%s): <%s>'):format((rawget(self,'__name') or 'Unnamed'),_classes[self]) or self
end}
class = function(attr)
  local c = deep_copy(attr) ; _classes[c] = tostring(c)
  c.new, c.extends, c.__index, c.__call, c.__tostring = instantiate, extends, c, baseMt.__call, baseMt.__tostring
    return setmetatable(c,baseMt)
end
-- End 30Log


local ROT=class {
    DEFAULT_WIDTH =80,
    DEFAULT_HEIGHT=24,

    DIRS= {FOUR={
                { 0,-1},
                { 1, 0},
                { 0, 1},
                {-1, 0}
               },
           EIGHT={
                { 0,-1},
                { 1,-1},
                { 1, 0},
                { 1, 1},
                { 0, 1},
                {-1, 1},
                {-1, 0},
                {-1,-1}
               }
          }
}

-- New Table Functions
-- returns random table element, nil if length is 0
function table.random(theTable)
    isATable(theTable)
    if #theTable==0 then return nil end
    return theTable[math.floor(math.random(#theTable))]
end
-- returns random valid index, nil if length is 0
function table.randomi(theTable)
    isATable(theTable)
    if #theTable==0 then return nil end
    return math.floor(math.random(#theTable))
end
-- randomly reorders the elements of the provided table and returns the result
function table.randomize(theTable)
    isATable(theTable)
    local result={}
    while #theTable>0 do
        table.insert(result, table.remove(theTable, table.randomi(theTable)))
    end
    return result
end
-- add js slice function
function table.slice (values,i1,i2)
    local res = {}
    local n = #values
    -- default values for range
    i1 = i1 or 1
    i2 = i2 or n
    if i2 < 0 then
        i2 = n + i2 + 1
    elseif i2 > n then
        i2 = n
    end
    if i1 < 1 or i1 > n then
        return {}
    end
    local k = 1
    for i = i1,i2 do
        res[k] = values[i]
        k = k + 1
    end
    return res
end
-- add js indexOf function
function table.indexOf(values,value)
    if values then
        for i=1,#values do
            if values[i] == value then return i end
        end
        if type(value)=='table' then return table.indexOfTable(values, value) end
    end
    return 0
end

-- extended for use with tables of tables
function table.indexOfTable(values, value)
    if type(value)~='table' then return 0 end
    for k,v in ipairs(values) do
        if #v==#value then
            local match=true
            for i=1,#v do
                if v[i]~=value[i] then match=false end
            end
            if match then return k end
        end
    end
    return 0
end

-- asserts the type of 'theTable' is table
function isATable(theTable)
    assert(type(theTable)=='table', "bad argument #1 to 'random' (table expected got "..type(theTable)..")")
end

-- New String functions
-- first letter capitalized
function string:capitalize()
    return self:sub(1,1):upper() .. self:sub(2)
end
-- returns string of length n consisting of only char c
function charNTimes(c, n)
    assert(#c==1, 'character must be a string of length 1')
    local s=''
    for _=1,n and n or 2 do
        s=s..c
    end
    return s
end
-- left pad with c char, repeated n times
function string:lpad(c, n)
    c=c and c or '0'
    n=n and n or 2
    local s=''
    while #s < n-#self do s=s..c end
    return s..self
end
-- right pad with c char, repeated n times
function string:rpad(c, n)
    c=c and c or '0'
    n=n and n or 2
    while #self < n do self=self..c end
    return self
end
-- add js split function
function string:split(delim, maxNb)
    -- Eliminate bad cases...
    if string.find(self, delim) == nil then
        return { self }
    end
    local result = {}
    if delim == '' or not delim then
        for i=1,#self do
            result[i]=self:sub(i,i)
        end
        return result
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(self, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(self, lastPos)
    end
    return result
end

function math.round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

-- io.write(arg..'\n')
function write(str)
    io.write(str..'\n')
end

-- ROT.RNG is derived from RandomLua
-- see LICENSE.txt for RandomLua license

--- The RNG Prototype.
-- The base class that is extended by all rng classes
-- @module ROT.RNG
ROT.RNG=class {  }
function ROT.RNG:__init()
    self.__name='RNG'
end

function ROT.RNG:normalize(n) --keep numbers at (positive) 32 bits
    return n % 0x80000000
end

function ROT.RNG:bit_and(a, b)
    local r = 0
    for m = 0, 31 do
        if (a % 2 == 1) and (b % 2 == 1) then r = r + 2^m end
        if a % 2 ~= 0 then a = a - 1 end
        if b % 2 ~= 0 then b = b - 1 end
        a = a / 2 b = b / 2
    end
    return self:normalize(r)
end

function ROT.RNG:bit_or(a, b)
    local r = 0
    for m = 0, 31 do
        if (a % 2 == 1) or (b % 2 == 1) then r = r + 2^m end
        if a % 2 ~= 0 then a = a - 1 end
        if b % 2 ~= 0 then b = b - 1 end
        a = a / 2 b = b / 2
    end
    return self:normalize(r)
end

function ROT.RNG:bit_xor(a, b)
    local r = 0
    for m = 0, 31 do
        if a % 2 ~= b % 2 then r = r + 2^m end
        if a % 2 ~= 0 then a = a - 1 end
        if b % 2 ~= 0 then b = b - 1 end
        a = a / 2 b = b / 2
    end
    return self:normalize(r)
end

function ROT.RNG:random(a,b)
    return math.random(a,b)
end

function ROT.RNG:getWeightedValue(tbl)
    local total=0
    for _,v in pairs(tbl) do
        total=total+v
    end
    local rand=self:random()*total
    local part=0
    for k,v in pairs(tbl) do
        part=part+v
        if rand<part then return k end
    end
    return nil
end


--- Seed.
-- get the host system's time in milliseconds as a positive 32 bit number
-- @return number
function ROT.RNG:seed()
    --return self:normalize(tonumber(tostring(os.time()):reverse()))
    return self:normalize(os.time() * 1000 + (os.clock() * 1000))
end

--- Mersenne Twister. A random number generator based on RandomLua
-- @module ROT.RNG.Twister
ROT.RNG.Twister=ROT.RNG:extends { }

function ROT.RNG.Twister:__init()
    self.__name='Twister'
    self.mt={}
    self.index=0
end

--- Seed.
-- seed the rng
-- @tparam[opt=os.clock()] number s A number to base the rng from
function ROT.RNG.Twister:randomseed(s)
    if not s then s = self:seed() end
    self._seed=s
    self.mt[0] = self:normalize(s)
    for i = 1, 623 do
        self.mt[i] = self:normalize(0x6c078965 * self:bit_xor(self.mt[i-1], math.floor(self.mt[i-1] / 0x40000000)) + i)
    end
end

--- Random.
-- get a random number
-- @tparam[opt=0] int a lower threshold for random numbers
-- @tparam[opt=1] int b upper threshold for random numbers
-- @treturn number a random number
function ROT.RNG.Twister:random(a, b)
    local y
    if self.index == 0 then
        for i = 0, 623 do
            --y = bit_or(math.floor(self.mt[i] / 0x80000000) * 0x80000000, self.mt[(i + 1) % 624] % 0x80000000)
            y = self.mt[(i + 1) % 624] % 0x80000000
            self.mt[i] = self:bit_xor(self.mt[(i + 397) % 624], math.floor(y / 2))
            if y % 2 ~= 0 then self.mt[i] = self:bit_xor(self.mt[i], 0x9908b0df) end
        end
    end
    y = self.mt[self.index]
    y = self:bit_xor(y, math.floor(y / 0x800))
    y = self:bit_xor(y, self:bit_and(self:normalize(y * 0x80), 0x9d2c5680))
    y = self:bit_xor(y, self:bit_and(self:normalize(y * 0x8000), 0xefc60000))
    y = self:bit_xor(y, math.floor(y / 0x40000))
    self.index = (self.index + 1) % 624
    if not a then return y / 0x80000000
    elseif not b then
        if a == 0 then return y
        else return 1 + (y % a)
        end
    else
        return a + (y % (b - a + 1))
    end
end

--- Get current rng state
-- Returns a table that can be given to the rng to return it to this state.
-- Any RNG of the same type will always produce the same values from this state.
-- @treturn table A table that represents the current state of the rng
function ROT.RNG.Twister:getState()
    local newmt={}
    for i=0,623 do
        newmt[i]=self.mt[i]
    end
    return { mt=newmt, index=self.index, _seed=self._seed}
end

--- Set current rng state
-- used to return an rng to a known/previous state
-- @tparam table stateTable The table retrieved from .getState()
function ROT.RNG.Twister:setState(stateTable)
    assert(stateTable.mt, 'bad state table: need stateTable.mt')
    assert(stateTable.index, 'bad state table: need stateTable.index')
    assert(stateTable._seed, 'bad state table: need stateTable._seed')

    self.mt=stateTable.mt
    self.index=stateTable.index
    self._seed=stateTable._seed
end

--- Linear Congruential Generator. A random number generator based on RandomLua
-- @module ROT.RNG.LCG
ROT.RNG.LCG=ROT.RNG:extends { }

--- Constructor.
-- Called with ROT.RNG.LCG:new(r)
-- @tparam[opt] string r Choose to populate the rng with values from numerical recipes or mvc as opposed to Ansi C. Accepted values 'nr', 'mvc'
function ROT.RNG.LCG:__init(r)
    self.__name='LCG'
    self.a= 1103515245   -- Ansi C
    self.c= 12345
    self.m= 0x10000

    if r=='nr' then self.a, self.c, self.m = 1664525, 1013904223, 0x10000       -- Numerical Recipes
    elseif r=='mvc' then self.a, self.c, self.m = 214013, 2531011, 0x10000 end  -- MVC
end

--- Random.
-- get a random number
-- @tparam[opt=0] int a lower threshold for random numbers
-- @tparam[opt=1] int b upper threshold for random numbers
-- @treturn number a random number
function ROT.RNG.LCG:random(a, b)
    local y = (self.a * self.x + self.c) % self.m
    self.x = y
    if not a then return y / 0x10000
    elseif not b then
        if a == 0 then return y
        else return 1 + (y % a) end
    else
        return a + (y % (b - a + 1))
    end
end

--- Seed.
-- seed the rng
-- @tparam[opt=os.clock()] number s A number to base the rng from
function ROT.RNG.LCG:randomseed(s)
    if not s then s = self:seed() end
    self._seed=s
    self.x = self:normalize(s)
end

--- Get current rng state
-- Returns a table that can be given to the rng to return it to this state.
-- Any RNG of the same type will always produce the same values from this state.
-- @treturn table A table that represents the current state of the rng
function ROT.RNG.LCG:getState()
    return { a=self.a, c=self.c, m=self.m, x=self.x, _seed=self._seed}
end

--- Set current rng state
-- used to return an rng to a known/previous state
-- @tparam table stateTable The table retrieved from .getState()
function ROT.RNG.LCG:setState(stateTable)
    assert(stateTable.a, 'bad stateTable: need stateTable.a')
    assert(stateTable.c, 'bad stateTable: need stateTable.c')
    assert(stateTable.m, 'bad stateTable: need stateTable.m')
    assert(stateTable.x, 'bad stateTable: need stateTable.x')
    assert(stateTable._seed, 'bad stateTable: need stateTable._seed')

    self.a=stateTable.a
    self.c=stateTable.c
    self.m=stateTable.m
    self.x=stateTable.x
    self._seed=stateTable._seed
end

--- Multiply With Carry. A random number generator based on RandomLua
-- @module ROT.RNG.MWC
ROT.RNG.MWC=ROT.RNG:extends {  }

--- Constructor.
-- Called with ROT.RNG.MWC:new(r)
-- @tparam[opt] string r Choose to populate the rng with values from numerical recipes or mvc as opposed to Ansi C. Accepted values 'nr', 'mvc'
function ROT.RNG.MWC:__init(r)
    self.__name='MWC'

    self.a= 1103515245
    self.c= 12345
    self.ic=self.c
    self.m= 0x10000

    if r=='nr' then self.a, self.c, self.m = 1664525, 1013904223, 0x10000
    elseif r=='mvc' then self.a, self.c, self.m = 214013, 2531011, 0x10000 end
end

--- Random.
-- get a random number
-- @tparam[opt=0] int a lower threshold for random numbers
-- @tparam[opt=1] int b upper threshold for random numbers
-- @treturn number a random number
function ROT.RNG.MWC:random(a, b)
    local m = self.m
    local t = self.a * self.x + self.c
    local y = t % m
    self.x = y
    self.c = math.floor(t / m)
    if not a then return y / 0x10000
    elseif not b then
        if a == 0 then return y
        else return 1 + (y % a) end
    else
        return a + (y % (b - a + 1))
    end
end

--- Seed.
-- seed the rng
-- @tparam[opt=os.clock()] number s A number to base the rng from
function ROT.RNG.MWC:randomseed(s)
    if not s then s = self:seed() end
    self._seed=s
    self.c = self.ic
    self.x = self:normalize(s)
end

--- Get current rng state
-- Returns a table that can be given to the rng to return it to this state.
-- Any RNG of the same type will always produce the same values from this state.
-- @treturn table A table that represents the current state of the rng
function ROT.RNG.MWC:getState()
    return { a=self.a, c=self.c, ic=self.ic, m=self.m, x=self.x, _seed=self._seed}
end

--- Set current rng state
-- used to return an rng to a known/previous state
-- @tparam table stateTable The table retrieved from .getState()
function ROT.RNG.MWC:setState(stateTable)
    assert(stateTable.a, 'bad stateTable: need stateTable.a')
    assert(stateTable.c, 'bad stateTable: need stateTable.c')
    assert(stateTable.ic, 'bad stateTable: need stateTable.ic')
    assert(stateTable.m, 'bad stateTable: need stateTable.m')
    assert(stateTable.x, 'bad stateTable: need stateTable.x')
    assert(stateTable._seed, 'bad stateTable: need stateTable._seed')

    self.a=stateTable.a
    self.c=stateTable.c
    self.ic=stateTable.ic
    self.m=stateTable.m
    self.x=stateTable.x
    self._seed=stateTable._seed
end

-- Display is derived from AsciiPanel
-- See LICENSE.txt for AsciiPanel license

--- Visual Display.
-- A Code Page 437 terminal emulator based on AsciiPanel.
-- @module ROT.Display
local Display_Path = ({...})[1]:gsub("[%.\\/]rotLove$", "") .. '/'
ROT.Display = class { }

--- Constructor.
-- The display constructor. Called when ROT.Display:new() is called.
-- @tparam[opt=80] int w Width of display in number of characters
-- @tparam[opt=24] int h Height of display in number of character
-- @tparam[opt] table dfg Default foreground color as a table defined as {r,g,b,a}
-- @tparam[opt] table dbg Default background color
-- @tparam[opt=false] boolean fullOrFlags In Love 0.8.0: Use fullscreen In Love 0.9.0: a table defined for love.graphics.setMode
-- @tparam[opt=false] boolean vsync Use vsync
-- @tparam[opt=0] int fsaa Number of fsaa passes
-- @return nil
function ROT.Display:__init(w, h, scale, dfg, dbg, fullOrFlags, vsync, fsaa)
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
        print('<=080')
        self.graphics.setMode(self.charWidth*self.widthInChars, self.charHeight*self.heightInChars, fullOrFlags, vsync, fsaa)
        self.drawQ=self.graphics.drawq
    end


    self.defaultForegroundColor=dfg and dfg or {r=235,g=235,b=235,a=255}
    self.defaultBackgroundColor=dbg and dbg or {r=15,g=15,b=15,a=255}

    self.graphics.setBackgroundColor(self.defaultBackgroundColor.r,
                                     self.defaultBackgroundColor.g,
                                     self.defaultBackgroundColor.b,
                                     self.defaultBackgroundColor.a)

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
function ROT.Display:draw()
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
function ROT.Display:contains(x, y)
    return x>0 and x<=self:getWidth() and y>0 and y<=self:getHeight()
end

function ROT.Display:getCharHeight() return self.charHeight end
function ROT.Display:getCharWidth() return self.charWidth end
function ROT.Display:getWidth() return self:getWidthInChars() end
function ROT.Display:getHeight() return self:getHeightInChars() end
function ROT.Display:getHeightInChars() return self.heightInChars end
function ROT.Display:getWidthInChars() return self.widthInChars end
function ROT.Display:getDefaultBackgroundColor() return self.defaultBackgroundColor end
function ROT.Display:getDefaultForegroundColor() return self.defaultForegroundColor end

--- Get a character.
-- returns the character being displayed at position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn string The character
function ROT.Display:getCharacter(x, y) return string.char(self.chars[x][y]) end

--- Get a background color.
-- returns the current background color of the character written to position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn table The background color as a table defined as {r,g,b,a}
function ROT.Display:getBackgroundColor(x, y) return self.backgroundColors[x][y] end

--- Get a foreground color.
-- returns the current foreground color of the character written to position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn table The foreground color as a table defined as {r,g,b,a}
function ROT.Display:getForegroundColor(x, y) return self.foregroundColors[x][y] end

--- Set Default Background Color.
-- Sets the background color to be used when it is not provided
-- @tparam table c The background color as a table defined as {r,g,b,a}
function ROT.Display:setDefaultBackgroundColor(c)
    self.defaultBackgroundColor=c and c or self.defaultBackgroundColor
end

--- Set Defaul Foreground Color.
-- Sets the foreground color to be used when it is not provided
-- @tparam table c The foreground color as a table defined as {r,g,b,a}
function ROT.Display:setDefaultForegroundColor(c)
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
function ROT.Display:clear(c, x, y, w, h, fg, bg)
    c =c and c or ' '
    w =w and w or self.widthInChars
    local s=''
    for _=1,w do
        s=s..c
    end
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
function ROT.Display:clearCanvas()
    self.canvas:clear()
end

--- Write.
-- Writes a string to the screen
-- @tparam string s The string to be written
-- @tparam[opt=1] int x The x-position where the string will be written
-- @tparam[opt=1] int y The y-position where the string will be written
-- @tparam[opt] table fg The color used to write the provided string
-- @tparam[opt] table bg the color used to fill in the string's background
function ROT.Display:write(s, x, y, fg, bg)
    assert(s, "ROT.Display:write() must have string as param")
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
function ROT.Display:writeCenter(s, y, fg, bg)
    assert(s, "ROT.Display:writeCenter() must have string as param")
    assert(#s<self.widthInChars, "Length of "..s.." is greater than screen width")
    y = y and y or math.floor((self:getHeightInChars() - 1) / 2)
    y = self:_validateY(y, s)
    fg= self:_validateForegroundColor(fg)
    bg= self:_validateBackgroundColor(bg)

    local x=math.floor((self.widthInChars-#s)/2)
    self:_writeValidatedString(s, x, y, fg, bg)
end

function ROT.Display:_writeValidatedString(s, x, y, fg, bg)
    for i=1,#s do
        self.backgroundColors[x+i-1][y] = bg
        self.foregroundColors[x+i-1][y] = fg
        self.chars[x+i-1][y]            = s:byte(i)
    end
end


function ROT.Display:_validateX(x, s)
    x = x and x or 1
    assert(x>0 and x<=self.widthInChars, "X value must be between 0 and "..self.widthInChars)
    assert((x+#s)-1<=self.widthInChars, "X value plus length of String must be between 0 and "..self.widthInChars)
    return x
end
function ROT.Display:_validateY(y)
    y = y and y or 1
    assert(y>0 and y<=self.heightInChars, "Y value must be between 0 and "..self.heightInChars)
    return y
end
function ROT.Display:_validateForegroundColor(c)
    c = c and c or self.defaultForegroundColor
    for k,_ in pairs(c) do c[k]=self:_clamp(c[k]) end
    assert(c.a and c.r and c.g and c.b, 'Foreground Color must be of type { r = int, g = int, b = int, a = int }')
    return c
end
function ROT.Display:_validateBackgroundColor(c)
    c = c and c or self.defaultBackgroundColor
    for k,_ in pairs(c) do c[k]=self:_clamp(c[k]) end
    assert(c.a and c.r and c.g and c.b, 'Background Color must be of type { r = int, g = int, b = int, a = int }')
    return c
end
function ROT.Display:_validateHeight(y, h)
    h=h and h or self.heightInChars-y
    assert(h>0, "Height must be greater than 0. Height provided: "..h)
    assert(y+h<=self.heightInChars, "Height + y value must be less than screen height. y, height: "..y..', '..h)
    return h
end
function ROT.Display:_setColor(c)
    c = c and c or self.defaultForegroundColor
    love.graphics.setColor(c.r, c.g, c.b, c.a)
end
function ROT.Display:_clamp(n)
    return n<0 and 0 or n>255 and 255 or n
end

--- Visual Display.
-- A UTF-8 based text display.
-- @module ROT.TextDisplay
ROT.TextDisplay=class { }

--- Constructor.
-- The display constructor. Called when ROT.TextDisplay:new() is called.
-- @tparam[opt=80] int w Width of display in number of characters
-- @tparam[opt=24] int h Height of display in number of characters
-- @tparam[opt] string|file|data font Any valid object accepted by love.graphics.newFont
-- @tparam[opt=10] int size font size
-- @tparam[opt] table dfg Default foreground color as a table defined as {r,g,b,a}
-- @tparam[opt] table dbg Default background color
-- @tparam[opt=false] boolean fullOrFlags In Love 0.8.0: Use fullscreen In Love 0.9.0: a table defined for love.graphics.setMode
-- @tparam[opt=false] boolean vsync Use vsync
-- @tparam[opt=0] int fsaa Number of fsaa passes
-- @return nil
function ROT.TextDisplay:__init(w, h, font, size, dfg, dbg, fullOrFlags, vsync, fsaa)
    self.graphics =love.graphics
    self._fontSize=size or 10
    self._font    =font and self.graphics.newFont(font, size) or self.graphics.newFont(self._fontSize)
    self.graphics.setFont(self._font)
    self._charWidth    =self._font:getWidth(' ')
    self._charHeight   =self._font:getHeight()
    self._widthInChars =w and w or 80
    self._heightInChars=h and h or 24
    local w=love.window or self.graphics
    w.setMode(self._charWidth*self._widthInChars, self._charHeight*self._heightInChars, fullOrFlags, vsync, fsaa)

    self.defaultForegroundColor=dfg and dfg or {r=235,g=235,b=235,a=255}
    self.defaultBackgroundColor=dbg and dbg or {r=15,g=15,b=15,a=255}

    self.graphics.setBackgroundColor(self.defaultBackgroundColor.r,
                                     self.defaultBackgroundColor.g,
                                     self.defaultBackgroundColor.b,
                                     self.defaultBackgroundColor.a)

    self._canvas=self.graphics.newCanvas(self._charWidth*self._widthInChars, self._charHeight*self._heightInChars)

    self._chars              ={}
    self._backgroundColors   ={}
    self._foregroundColors   ={}
    self._oldChars           ={}
    self._oldBackgroundColors={}
    self._oldForegroundColors={}

    for x=1,self._widthInChars do
        self._chars[x]               = {}
        self._backgroundColors[x]    = {}
        self._foregroundColors[x]    = {}
        self._oldChars[x]            = {}
        self._oldBackgroundColors[x] = {}
        self._oldForegroundColors[x] = {}
        for y=1,self._heightInChars do
            self._chars[x][y]               = ' '
            self._backgroundColors[x][y]    = self.defaultBackgroundColor
            self._foregroundColors[x][y]    = self.defaultForegroundColor
            self._oldChars[x][y]            = nil
            self._oldBackgroundColors[x][y] = nil
            self._oldForegroundColors[x][y] = nil
        end
    end
end

function ROT.TextDisplay:draw()
    self.graphics.setCanvas(self._canvas)
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
            self.graphics.rectangle('fill', px, py, self._charWidth, self._charHeight)
            self:_setColor(fg)
            self.graphics.print(c, px, py)
            self._oldChars[x][y]            = c
            self._oldBackgroundColors[x][y] = bg
            self._oldForegroundColors[x][y] = fg
        end
    end end
    self.graphics.setCanvas()
    self.graphics.setColor(255,255,255,255)
    self.graphics.draw(self._canvas)
end

--- Contains point.
-- Returns true if point x,y can be drawn to display.
function ROT.TextDisplay:contains(x, y)
    return x>0 and x<=self:getWidth() and y>0 and y<=self:getHeight()
end

function ROT.TextDisplay:getCharHeight() return self._charHeight end
function ROT.TextDisplay:getCharWidth() return self._charWidth end
function ROT.TextDisplay:getWidth() return self:getWidthInChars() end
function ROT.TextDisplay:getHeight() return self:getHeightInChars() end
function ROT.TextDisplay:getHeightInChars() return self._heightInChars end
function ROT.TextDisplay:getWidthInChars() return self._widthInChars end
function ROT.TextDisplay:getDefaultBackgroundColor() return self.defaultBackgroundColor end
function ROT.TextDisplay:getDefaultForegroundColor() return self.defaultForegroundColor end

--- Get a character.
-- returns the character being displayed at position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn string The character
function ROT.TextDisplay:getCharacter(x, y) return self._chars[x][y] end

--- Get a background color.
-- returns the current background color of the character written to position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn table The background color as a table defined as {r,g,b,a}
function ROT.TextDisplay:getBackgroundColor(x, y) return self._backgroundColors[x][y] end

--- Get a foreground color.
-- returns the current foreground color of the character written to position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn table The foreground color as a table defined as {r,g,b,a}
function ROT.TextDisplay:getForegroundColor(x, y) return self._foregroundColors[x][y] end

--- Set Default Background Color.
-- Sets the background color to be used when it is not provided
-- @tparam table c The background color as a table defined as {r,g,b,a}
function ROT.TextDisplay:setDefaultBackgroundColor(c)
    self.defaultBackgroundColor=c and c or self.defaultBackgroundColor
end

--- Set Defaul Foreground Color.
-- Sets the foreground color to be used when it is not provided
-- @tparam table c The foreground color as a table defined as {r,g,b,a}
function ROT.TextDisplay:setDefaultForegroundColor(c)
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
function ROT.TextDisplay:clear(c, x, y, w, h, fg, bg)
    c =c and c or ' '
    w =w and w or self._widthInChars
    local s=''
    for _=1,w do
        s=s..c
    end
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
function ROT.TextDisplay:clearCanvas()
    self._canvas:clear()
end

--- Write.
-- Writes a string to the screen
-- @tparam string s The string to be written
-- @tparam[opt=1] int x The x-position where the string will be written
-- @tparam[opt=1] int y The y-position where the string will be written
-- @tparam[opt] table fg The color used to write the provided string
-- @tparam[opt] table bg the color used to fill in the string's background
function ROT.TextDisplay:write(s, x, y, fg, bg)
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
function ROT.TextDisplay:writeCenter(s, y, fg, bg)
    assert(s, "Display:writeCenter() must have string as param")
    assert(#s<self._widthInChars, "Length of "..s.." is greater than screen width")
    y = y and y or math.floor((self:getHeightInChars() - 1) / 2)
    y = self:_validateY(y, s)
    fg= self:_validateForegroundColor(fg)
    bg= self:_validateBackgroundColor(bg)

    local x=math.floor((self._widthInChars-#s)/2)
    self:_writeValidatedString(s, x, y, fg, bg)
end

function ROT.TextDisplay:_writeValidatedString(s, x, y, fg, bg)
    for i=1,#s do
        self._backgroundColors[x+i-1][y] = bg
        self._foregroundColors[x+i-1][y] = fg
        local c=s:sub(i,i)
        --if self._font:getWidth(c)~=self._charWidth then write('HELP') end
        self._chars[x+i-1][y]            = c
    end
end


function ROT.TextDisplay:_validateX(x, s)
    x = x and x or 1
    assert(x>0 and x<=self._widthInChars, "X value must be between 0 and "..self._widthInChars)
    assert((x+#s)-1<=self._widthInChars, "X value plus length of String must be between 0 and "..self._widthInChars..' string: '..s..'; x:'..x)
    return x
end
function ROT.TextDisplay:_validateY(y)
    y = y and y or 1
    assert(y>0 and y<=self._heightInChars, "Y value must be between 0 and "..self._heightInChars)
    return y
end
function ROT.TextDisplay:_validateForegroundColor(c)
    c = c and c or self.defaultForegroundColor
    for k,_ in pairs(c) do c[k]=self:_clamp(c[k]) end
    assert(c.a and c.r and c.g and c.b, 'Foreground Color must be of type { r = int, g = int, b = int, a = int }')
    return c
end
function ROT.TextDisplay:_validateBackgroundColor(c)
    c = c and c or self.defaultBackgroundColor
    for k,_ in pairs(c) do c[k]=self:_clamp(c[k]) end
    assert(c.a and c.r and c.g and c.b, 'Background Color must be of type { r = int, g = int, b = int, a = int }')
    return c
end
function ROT.TextDisplay:_validateHeight(y, h)
    h=h and h or self._heightInChars-y
    assert(h>0, "Height must be greater than 0. Height provided: "..h)
    assert(y+h<=self._heightInChars, "Height + y value must be less than screen height. y, height: "..y..', '..h)
    return h
end
function ROT.TextDisplay:_setColor(c)
    c = c and c or self.defaultForegroundColor
    love.graphics.setColor(c.r, c.g, c.b, c.a)
end
function ROT.TextDisplay:_clamp(n)
    return n<0 and 0 or n>255 and 255 or n
end

--- Random String Generator.
-- Learns from provided strings, and generates similar strings.
-- @module ROT.StringGenerator
ROT.StringGenerator = class { }

--- Constructor.
-- Called with ROT.StringGenerator:new()
-- @tparam table options A table with the following fields:
    -- @tparam[opt=false] boolean options.words Use word mode
    -- @tparam[opt=3] int options.order Number of letters/words to be used as context
    -- @tparam[opt=0.001] number options.prior A default priority for characters/words
function ROT.StringGenerator:__init(options, rng)
    self.__name   ='StringGenerator'
    self._options = {words=false,
                     order=3,
                     prior=0.001
                    }
    self._boundary=string.char(0)
    self._suffix  =string.char(0)
    self._prefix  ={}
    self._priorValues={}
    self._data    ={}
    if options then
        for k,v in pairs(options) do
            self._options[k]=v
        end
    end
    for _=1,self._options.order do
        table.insert(self._prefix, self._boundary)
    end
    self._priorValues[self._boundary]=self._options.prior

    self._rng=rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Remove all learned data
function ROT.StringGenerator:clear()
    self._data={}
    self._priorValues={}
end

--- Generate a string
-- @treturn string The generated string
function ROT.StringGenerator:generate()
    local result={self:_sample(self._prefix)}
    while result[#result] ~= self._boundary do
        table.insert(result, self:_sample(result))
    end
    table.remove(result)
    return table.concat(result)
end

--- Observe
-- Learn from a string
-- @tparam string s The string to observe
function ROT.StringGenerator:observe(s)
    local tokens = self:_split(s)
    for i=1,#tokens do
        self._priorValues[tokens[i]] = self._options.prior
    end
    local i=1
    for _,v in pairs(self._prefix) do
        table.insert(tokens, i, v)
        i=i+1
    end
    table.insert(tokens, self._suffix)
    for i=self._options.order,#tokens-1 do
        local context=table.slice(tokens, i-self._options.order+1, i)
        local evt    = tokens[i+1]
        for j=1,#context do
            local subcon=table.slice(context, j)
            self:_observeEvent(subcon, evt)
        end
    end
end

--- get Stats
-- Get info about learned strings
-- @treturn string Number of observed strings, number of contexts, number of possible characters/words
function ROT.StringGenerator:getStats()
    local parts={}
    local prC=0
    for _ in pairs(self._priorValues) do
        prC = prC + 1
    end
    prC=prC-1
    table.insert(parts, 'distinct samples: '..prC)
    local dataC=0
    local evtCount=0
    for k,_ in pairs(self._data) do
        dataC=dataC+1
        for _,_ in pairs(self._data[k]) do
            evtCount=evtCount+1
        end
    end
    table.insert(parts, 'dict size(cons): '..dataC)
    table.insert(parts, 'dict size(evts): '..evtCount)
    return table.concat(parts, ', ')
end

function ROT.StringGenerator:_split(str)
    return str:split(self._options.words and " " or "")
end

function ROT.StringGenerator:_join(arr)
    return table.concat(arr, self._options.words and " " or "")
end

function ROT.StringGenerator:_observeEvent(context, event)
    local key=self:_join(context)
    if not self._data[key] then
        self._data[key] = {}
    end
    if not self._data[key][event] then
        self._data[key][event] = 0
    end
    self._data[key][event]=self._data[key][event]+1
end
function ROT.StringGenerator:_sample(context)
    context   =self:_backoff(context)
    local key =self:_join(context)
    local data=self._data[key]
    local avail={}
    if self._options.prior then
        for k,_ in pairs(self._priorValues) do
            avail[k] = self._priorValues[k]
        end
        for k,_ in pairs(data) do
            avail[k] = avail[k]+data[k]
        end
    else
        avail=data
    end
    return self:_pickRandom(avail)
end

function ROT.StringGenerator:_backoff(context)
    local ctx = {}
    for i=1,#context do ctx[i]=context[i] end
    if #ctx > self._options.order then
        while #ctx > self._options.order do table.remove(ctx, 1) end
    elseif #ctx < self._options.order then
        while #ctx < self._options.order do table.insert(ctx,1,self._boundary) end
    end
    while not self._data[self:_join(ctx)] and #ctx>0 do
        ctx=table.slice(ctx, 2)
    end

    return ctx
end

function ROT.StringGenerator:_pickRandom(data)
    local total =0
    for k,_ in pairs(data) do
        total=total+data[k]
    end
    local rand=self._rng:random()*total
    local i=0
    for k,_ in pairs(data) do
        i=i+data[k]
        if (rand<i) then
            return k
        end
    end
end

--- Stores and retrieves events based on time.
-- @module ROT.EventQueue
ROT.EventQueue = class {
    __name     ='EventQueue',
    _time      =0,
    _events    ={},
    _eventTimes={}
}

--- Get Time.
-- Get time counted since start
-- @treturn int elapsed time
function ROT.EventQueue:getTime()
    return self._time
end

--- Clear.
-- Remove all events from queue
-- @treturn ROT.EventQueue self
function ROT.EventQueue:clear()
    self._events    ={}
    self._eventTimes={}
    return self
end

--- Add.
-- Add an event
-- @tparam any event Any object
-- @tparam int time The number of time units that will elapse before this event is returned
function ROT.EventQueue:add(event, time)
    local index= 1
    if self._eventTimes then
        for i=1,#self._eventTimes do
            if self._eventTimes[i]>time then
                index=i
                break
            end
            index=i+1
        end
    end
    table.insert(self._events, index, event)
    table.insert(self._eventTimes, index, time)
end

--- Get.
-- Get the next event from the queue and advance the appropriate amount time
-- @treturn event|nil The event previously added by .add() or nil if none are queued
function ROT.EventQueue:get()
    if #self._events<1 then return nil end
    local time = table.remove(self._eventTimes, 1)
    if time>0 then
        self._time=self._time+time
        for i=1,#self._eventTimes do
            self._eventTimes[i]=self._eventTimes[i]-time
        end
    end
    return table.remove(self._events, 1)
end

--- Remove.
-- Find and remove an event from the queue
-- @tparam any event The previously added event to be removed
-- @treturn boolean true if an event was removed from the queue
function ROT.EventQueue:remove(event)
    local index=table.indexOf(self._events, event)
    if index==0 then return false end
    self:_remove(index)
    return true
end

function ROT.EventQueue:_remove(index)
    table.remove(self._events, index)
    table.remove(self._eventTimes, index)
end

--- The Scheduler Prototype
-- @module ROT.Scheduler
ROT.Scheduler = class { }
function ROT.Scheduler:__init()
    self.__name  ='Scheduler'
    self._queue=ROT.EventQueue:new()
    self._repeat ={}
    self._current=nil
end

--- Get Time.
-- Get time counted since start
-- @treturn int elapsed time
function ROT.Scheduler:getTime()
    return self._queue:getTime()
end

--- Add.
-- Add an item to the schedule
-- @tparam any item
-- @tparam boolean repeating If true, this item will be rescheduled once it is returned by .next()
-- @treturn ROT.Scheduler self
function ROT.Scheduler:add(item, repeating)
    if repeating then table.insert(self._repeat, item) end
    return self
end

--- Clear.
-- Remove all items from scheduler
-- @treturn ROT.Scheduler self
function ROT.Scheduler:clear()
    self._queue:clear()
    self._repeat={}
    self._current=nil
    return self
end

--- Remove.
-- Find and remove an item from the scheduler
-- @tparam any item The previously added item to be removed
-- @treturn boolean true if an item was removed from the scheduler
function ROT.Scheduler:remove(item)
    local result=self._queue:remove(item)
    local index=table.indexOf(self._events, item)
    if index~=0 then table.remove(self._repeat, index) end
    if self._current==item then self._current=nil end
    return result
end

--- Next.
-- Get the next event from the scheduler and advance the appropriate amount time
-- @treturn event|nil The event previously added by .add() or nil if none are queued
function ROT.Scheduler:next()
    self._current=self._queue:get()
    return self._current
end

--- The simple scheduler
-- @module ROT.Scheduler.Simple
ROT.Scheduler.Simple= ROT.Scheduler:extends { __name='Simple' }

--- Add.
-- Add an item to the schedule
-- @tparam any item
-- @tparam boolean repeating If true, this item will be rescheduled once it is returned by .next()
-- @treturn ROT.Scheduler.Simple self
function ROT.Scheduler.Simple:add(item, repeating)
    self._queue:add(item, 0)
    return ROT.Scheduler.Simple.super.add(self, item, repeating)
end

--- Next.
-- Get the next item from the scheduler and advance the appropriate amount time
-- @treturn item|nil The item previously added by .add() or nil if none are queued
function ROT.Scheduler.Simple:next()
    if self._current and table.indexOf(self._repeat, self._current)~=0 then
        self._queue:add(self._current, 0)
    end
    return ROT.Scheduler.Simple.super.next(self)
end

--- Get Time.
-- Get time counted since start
-- @treturn int elapsed time
-- @function ROT.Scheduler.Simple:getTime()

--- Clear.
-- Remove all items from scheduler
-- @treturn ROT.Scheduler.Simple self
-- @function ROT.Scheduler.Simple:clear()

--- Remove.
-- Find and remove an item from the scheduler
-- @tparam any item The previously added item to be removed
-- @treturn boolean true if an item was removed from the scheduler
-- @function ROT.Scheduler.Simple:remove(item)

--- The Speed based scheduler
-- @module ROT.Scheduler.Speed
ROT.Scheduler.Speed= ROT.Scheduler:extends { __name='Speed' }

--- Add.
-- Add an item to the schedule
-- @tparam userdata item Any class/module/userdata with a :getSpeed() function. The value returned by getSpeed() should be a number.
-- @tparam boolean repeating If true, this item will be rescheduled once it is returned by .next()
-- @treturn ROT.Scheduler.Speed self
function ROT.Scheduler.Speed:add(item, repeating)
    self._queue:add(item, 1/item:getSpeed())
    return ROT.Scheduler.Speed.super.add(self, item, repeating)
end

--- Next.
-- Get the next item from the scheduler and advance the appropriate amount time
-- @treturn item|nil The item previously added by .add() or nil if none are queued
function ROT.Scheduler.Speed:next()
    if self._current and table.indexOf(self._repeat, self._current)~=0 then
        self._queue:add(self._current, 1/self._current:getSpeed())
    end
    return ROT.Scheduler.Speed.super.next(self)
end

--- Get Time.
-- Get time counted since start
-- @treturn int elapsed time
-- @function Speed:getTime()

--- Clear.
-- Remove all items from scheduler
-- @treturn ROT.Scheduler.Speed self
-- @function Speed:clear()

--- Remove.
-- Find and remove an item from the scheduler
-- @tparam any item The previously added item to be removed
-- @treturn boolean true if an item was removed from the scheduler
-- @function Speed:remove(item)

--- Action based turn scheduler.
-- @module ROT.Scheduler.Action
ROT.Scheduler.Action= ROT.Scheduler:extends { }

function ROT.Scheduler.Action:__init()
    ROT.Scheduler.Action.super.__init(self)
    self.__name='Action'
    self._defaultDuration=1
    self._duration=self._defaultDuration
end

--- Add.
-- Add an item to the scheduler.
-- @tparam any item The item that is returned when this turn comes up
-- @tparam boolean repeating If true, when this turn comes up, it will be added to the queue again
-- @tparam[opt=1] int time an initial delay time
-- @treturn ROT.Scheduler.Action self
function ROT.Scheduler.Action:add(item, repeating, time)
    self._queue:add(item, time and time or self._defaultDuration)
    return ROT.Scheduler.Action.super.add(self, item, repeating)
end

--- Clear.
-- empties this scheduler's event queue, no items will be returned by .next() until more are added with .add()
-- @treturn ROT.Scheduler.Action self
function ROT.Scheduler.Action:clear()
    self._duration = self._defaultDuration
    return ROT.Scheduler.Action.super.clear(self)
end

--- Remove.
-- Looks for the next instance of item in the event queue
-- @treturn ROT.Scheduler.Action self
function ROT.Scheduler.Action:remove(item)
    if item==self._current then self._duration=self._defaultDuration end
    return ROT.Scheduler.Action.super.remove(self, item)
end

--- Next.
-- returns the next item based on that item's last action's duration
-- @return item
function ROT.Scheduler.Action:next()
    if self._current and table.indexOf(self._repeat, self._current)~=0 then
        self._queue:add(self._current, self._duration and self._duration or self._defaultDuration)
        self._duration=self._defaultDuration
    end
    return ROT.Scheduler.Action.super.next(self)
end

--- set duration for the active item
-- after calling next() this function defines the duration of that item's action
-- @tparam int time The amount of time that the current item's action should last.
-- @treturn ROT.Scheduler.Action self
function ROT.Scheduler.Action:setDuration(time)
    if self._current then self._duration=time end
    return self
end

ROT.Engine = class { }
function ROT.Engine:__init(scheduler)
    self.__name='Engine'
    self._scheduler=scheduler
    self._lock     =1
end

function ROT.Engine:start()
    return self:unlock()
end

function ROT.Engine:lock()
    self._lock=self._lock+1
end

function ROT.Engine:unlock()
    assert(self._lock>0, 'Cannot unlock unlocked Engine')
    self._lock=self._lock-1
    while self._lock<1 do
        local actor=self._scheduler:next()
        if not actor then return self:lock() end
        actor:act()
    end
    return self
end

ROT.Map=class { }
function ROT.Map:__init(width, height)
    self.__name= 'Map'
    self._width = width and width or ROT.DEFAULT_WIDTH
    self._height= height and height or ROT.DEFAULT_HEIGHT
end

function ROT.Map:create() print("Unimplemented") end

function ROT.Map:_fillMap(value)
    local map={}
    for  i=1,self._width do
        table.insert(map, {})
        for _=1,self._height do table.insert(map[i], value) end
    end
    return map
end

--- The Arena map generator.
-- Generates an arena style map. All cells except for the extreme borders are floors. The borders are walls.
-- @module ROT.Map.Arena
ROT.Map.Arena = ROT.Map:extends { }

--- Constructor.
-- Called with ROT.Map.Arena:new(width, height)
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
function ROT.Map.Arena:__init(width, height)
    ROT.Map.Arena.super.__init(self, width, height)
    self.__name = 'Arena'
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.Arena self
function ROT.Map.Arena:create(callback)
    local w=self._width
    local h=self._height
    for i=1,w do
        for j=1,h do
            local empty= i>1 and j>1 and i<w and j<h
            callback(i, j, empty and 0 or 1)
        end
    end
    return self
end

--- The Divided Maze Map Generator.
-- Recursively divided maze, http://en.wikipedia.org/wiki/Maze_generation_algorithm#Recursive_division_method
-- @module ROT.Map.DividedMaze
ROT.Map.DividedMaze = ROT.Map:extends { }

--- Constructor.
-- Called with ROT.Map.DividedMaze:new(width, height)
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
function ROT.Map.DividedMaze:__init(width, height)
    ROT.Map.DividedMaze.super.__init(self, width, height)
    self.__name = 'DividedMaze'
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.DividedMaze self
function ROT.Map.DividedMaze:create(callback)
    local w=self._width
    local h=self._height
    self._map = {}

    for i=1,w do
        table.insert(self._map, {})
        for j=1,h do
            local border= i==1 or j==1 or i==w or j==h
            table.insert(self._map[i], border and 1 or 0)
        end
    end
    self._stack = { {2,2,w-1,h-1} }
    self:_process()
    for i=1,w do
        for j=1,h do
            callback(i,j,self._map[i][j])
        end
    end
    self._map=nil
    return self
end

function ROT.Map.DividedMaze:_process()
    while #self._stack>0 do
        local room=table.remove(self._stack, 1)
        self:_partitionRoom(room)
    end
end

function ROT.Map.DividedMaze:_partitionRoom(room)
    local availX={}
    local availY={}

    for i=room[1]+1,room[3]-1 do
        local top   =self._map[i][room[2]-1]
        local bottom=self._map[i][room[4]+1]
        if top>0 and bottom>0 and i%2==0 then table.insert(availX, i) end
    end

    for j=room[2]+1,room[4]-1 do
        local left =self._map[room[1]-1][j]
        local right=self._map[room[3]+1][j]
        if left>0 and right>0 and j%2==0 then table.insert(availY, j) end
    end

    if #availX==0 or #availY==0 then return end

    local x=table.random(availX)
    local y=table.random(availY)

    self._map[x][y]=1

    local walls={}
    table.insert(walls, {})
    for i=room[1],x-1,1 do
        self._map[i][y]=1
        table.insert(walls[#walls], {i,y})
    end

    table.insert(walls, {})
    for i=x+1,room[3],1 do
        self._map[i][y]=1
        table.insert(walls[#walls],{i,y})
    end

    table.insert(walls, {})
    for j=room[2],y-1,1 do
        self._map[x][j]=1
        table.insert(walls[#walls],{x,j})
    end

    table.insert(walls, {})
    for j=y+1,room[4] do
        self._map[x][j]=1
        table.insert(walls[#walls],{x,j})
    end

    local solid= table.random(walls)
    for i=1,#walls do
        local w=walls[i]
        if w~=solid then
            local hole=table.random(w)
            self._map[hole[1]][hole[2]]=0
        end
    end
    table.insert(self._stack, {room[1], room[2], x-1, y-1})
    table.insert(self._stack, {x+1, room[2], room[3], y-1})
    table.insert(self._stack, {room[1], y+1, x-1, room[4]})
    table.insert(self._stack, {x+1, y+1, room[3], room[4]})
end

--- The Icey Maze Map Generator.
-- See http://www.roguebasin.roguelikedevelopment.org/index.php?title=Simple_maze for explanation
-- @module ROT.Map.IceyMaze
ROT.Map.IceyMaze = ROT.Map:extends { }

--- Constructor.
-- Called with ROT.Map.IceyMaze:new(width, height, regularity)
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam int[opt=0] regularity A value used to determine the 'randomness' of the map, 0= more random
function ROT.Map.IceyMaze:__init(width, height, rng, regularity)
    assert(ROT and ROT.RNG.Twister, 'require rot or require RandomLua, IceyMaze requires twister() be available')
    ROT.Map.IceyMaze.super.__init(self, width, height)
    self.__name     ='IceyMaze'
    self._regularity= regularity and regularity or 0
    self._rng       =rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.IceyMaze self
function ROT.Map.IceyMaze:create(callback)
    local w=self._width
    local h=self._height
    local map=self:_fillMap(1)
    w= w%2==1 and w-1 or w-2
    h= h%2==1 and h-1 or h-2

    local cx, cy, nx, ny = 1, 1, 1, 1
    local done   =0
    local blocked=false
    local dirs={
                {0,0},
                {0,0},
                {0,0},
                {0,0}
               }
    repeat
        cx=2+2*math.floor(self._rng:random()*(w-1)/2)
        cy=2+2*math.floor(self._rng:random()*(h-1)/2)
        if done==0 then map[cx][cy]=0 end
        if map[cx][cy]==0 then
            self:_randomize(dirs)
            repeat
                if math.floor(self._rng:random()*(self._regularity+1))==0 then self:_randomize(dirs) end
                blocked=true
                for i=1,4 do
                    nx=cx+dirs[i][1]*2
                    ny=cy+dirs[i][2]*2
                    if self:_isFree(map, nx, ny, w, h) then
                        map[nx][ny]=0
                        map[cx+dirs[i][1]][cy+dirs[i][2]]=0

                        cx=nx
                        cy=ny
                        blocked=false
                        done=done+1
                        break
                    end
                end
            until blocked
        end
    until done+1>=w*h/4

    for i=1,self._width do
        for j=1,self._height do
            callback(i, j, map[i][j])
        end
    end
    self._map=nil
    return self
end

function ROT.Map.IceyMaze:_randomize(dirs)
    for i=1,4 do
        dirs[i][1]=0
        dirs[i][2]=0
    end
    local rand=math.floor(self._rng:random()*4)
    if rand==0 then
        dirs[1][1]=-1
        dirs[3][2]=-1
        dirs[2][1]= 1
        dirs[4][2]= 1
    elseif rand==1 then
        dirs[4][1]=-1
        dirs[2][2]=-1
        dirs[3][1]= 1
        dirs[1][2]= 1
    elseif rand==2 then
        dirs[3][1]=-1
        dirs[1][2]=-1
        dirs[4][1]= 1
        dirs[2][2]= 1
    elseif rand==3 then
        dirs[2][1]=-1
        dirs[4][2]=-1
        dirs[1][1]= 1
        dirs[3][2]= 1
    end
end

function ROT.Map.IceyMaze:_isFree(map, x, y, w, h)
    if x<2 or y<2 or x>w or y>h then return false end
    return map[x][y]~=0
end

--- The Eller Maze Map Generator.
-- See http://homepages.cwi.nl/~tromp/maze.html for explanation
-- @module ROT.Map.EllerMaze
ROT.Map.EllerMaze = ROT.Map:extends { }


--- Constructor.
-- Called with ROT.Map.EllerMaze:new(width, height)
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
function ROT.Map.EllerMaze:__init(width, height, rng)
    ROT.Map.EllerMaze.super.__init(self, width, height)
    self.__name='EllerMaze'
    self._rng  =rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.EllerMaze self
function ROT.Map.EllerMaze:create(callback)
    local map =self:_fillMap(1)
    local w   =math.ceil((self._width-2)/2)
    local rand=9/24
    local L   ={}
    local R   ={}

    for i=1,w do
        table.insert(L,i)
        table.insert(R,i)
    end
    table.insert(L,w)
    local j=2
    while j<self._height-2 do
        for i=1,w do
            local x=2*i
            local y=j
            map[x][y]=0

            if i~=L[i+1] and self._rng:random()>rand then
                self:_addToList(i, L, R)
                map[x+1][y]=0
            end

            if i~=L[i] and self._rng:random()>rand then
                self:_removeFromList(i, L, R)
            else
                map[x][y+1]=0
            end
        end
        j=j+2
    end
    --j=self._height%2==1 and self._height-2 or self._height-3
    for i=1,w do
        local x=2*i
        local y=j
        map[x][y]=0

        if i~=L[i+1] and (i==L[i] or self._rng:random()>rand) then
            self:_addToList(i, L, R)
            map[x+1][y]=0
        end

        self:_removeFromList(i, L, R)
    end
    for i=1,self._width do
        for j=1,self._height do
            callback(i, j, map[i][j])
        end
    end
    return self
end

function ROT.Map.EllerMaze:_removeFromList(i, L, R)
    R[L[i]]=R[i]
    L[R[i]]=L[i]
    R[i]   =i
    L[i]   =i
end

function ROT.Map.EllerMaze:_addToList(i, L, R)
    R[L[i+1]]=R[i]
    L[R[i]]  =L[i+1]
    R[i]     =i+1
    L[i+1]   =i
end

--- Cellular Automaton Map Generator
-- @module ROT.Map.Cellular
ROT.Map.Cellular = ROT.Map:extends { }

--- Constructor.
-- Called with ROT.Map.Cellular:new()
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam[opt] table options Options
  -- @tparam table options.born List of neighbor counts for a new cell to be born in empty space
  -- @tparam table options.survive List of neighbor counts for an existing  cell to survive
  -- @tparam int options.topology Topology. Accepted values: 4, 8
  -- @tparam boolean options.connected Set to true to connect open areas on create
  -- @tparam int options.minimumZoneArea Unconnected zones with fewer tiles than this will be turned to wall instead of being connected
-- @tparam userdata rng Userdata with a .random(self, min, max) function
function ROT.Map.Cellular:__init(width, height, options, rng)
    assert(ROT, 'must require rot')
    ROT.Map.Cellular.super.__init(self, width, height)
    self.__name='Cellular'
    self._options={
                    born    ={5,6,7,8},
                    survive ={4,5,6,7,8},
                    topology=8,
                    connected=false,
                    minimumZoneArea=8
                  }
    if options then
        for k,v in pairs(options) do
            self._options[k]=v
        end
    end
    local t=self._options.topology
    assert(t==8 or t==4, 'topology must be 8 or 4')
    self._dirs = t==8 and ROT.DIRS.EIGHT or t==4 and ROT.DIRS.FOUR

    self._rng = rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Randomize cells.
-- Random fill map with 0 or 1. Call this first when creating a map.
-- @tparam number prob Probability that a cell will be a floor (0). Accepts values between 0 and 1
-- @treturn ROT.Map.Cellular self
function ROT.Map.Cellular:randomize(prob)
    if not self._map then self._map = self:_fillMap(0) end
    for i=1,self._width do
        for j=1,self._height do
            self._map[i][j]= self._rng:random() < prob and 1 or 0
        end
    end
    return self
end

--- Set.
-- Assign a value (0 or 1) to a cell on the map
-- @tparam int x x-position of the cell
-- @tparam int y y-position of the cell
-- @tparam int value Value to be assigned 0-Floor 1-Wall
function ROT.Map.Cellular:set(x, y, value)
    self._map[x][y]=value
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.Cellular self
function ROT.Map.Cellular:create(callback)
    local newMap =self:_fillMap(0)
    local born   =self._options.born
    local survive=self._options.survive
    local changed=false

    for j=1,self._height do
        for i=1,self._width do
            local cur   =self._map[i][j]
            local ncount=self:_getNeighbors(i, j)
            if cur>0 and table.indexOf(survive, ncount)>0 then
                newMap[i][j]=1
            elseif cur<=0 and table.indexOf(born, ncount)>0 then
                newMap[i][j]=1
            end
            if not changed and newMap[i][j]~=self._map[i][j] then changed=true end
        end
    end
    self._map=newMap

    if self._options.connected then
        self:_completeMaze()
    end

    if callback then
        for i=1,self._width do
            for j=1,self._height do
                if callback then callback(i, j, newMap[i][j]) end
            end
        end
    end
    return changed
end

function ROT.Map.Cellular:_getNeighbors(cx, cy)
    local rst=0
    for i=1,#self._dirs do
        local dir=self._dirs[i]
        local x  =cx+dir[1]
        local y  =cy+dir[2]
        if x>0 and x<=self._width and y>0 and y<=self._height then
            rst= self._map[x][y]==1 and rst+1 or rst
        end
    end
    return rst
end

function ROT.Map.Cellular:_completeMaze()
    -- Collect all zones
    local zones={}
    for i=1,self._width do
        for j=1,self._height do
            if self._map[i][j]==0 then
                self:_addZoneFrom(i,j,zones)
            end
        end
    end
    -- overwrite zones below a certain size
    -- and connect zones
    for i=1,#zones do
        if #zones[i]<self._options.minimumZoneArea then
            for _,v in pairs(zones[i]) do
                self._map[v[1]][v[2]]=1
            end
        else
            local rx=self._rng:random(1,self._width)
            local ry=self._rng:random(1,self._height)
            while self._map[rx][ry]~=1 and self._map[rx][ry]~=i do
                rx=self._rng:random(1,self._width)
                ry=self._rng:random(1,self._height)
            end
            local t=zones[i][self._rng:random(1,#zones[i])]
            self:_tunnel(t[1],t[2],rx,ry)
            -- re-establish floors as 0 for this zone
            for _,v in pairs(zones[i]) do
                self._map[v[1]][v[2]]=0
            end
        end
    end
end

function ROT.Map.Cellular:_addZoneFrom(x,y,zones)
    local dirs=self._dirs
    local todo={{x,y}}
    table.insert(zones,{})
    local zId =#zones+1
    self._map[x][y]=zId
    table.insert(zones[#zones], {x,y})
    while #todo>0 do
        local t=table.remove(todo)
        local tx=t[1]
        local ty=t[2]
        for _,v in pairs(dirs) do
            local nx=tx+v[1]
            local ny=ty+v[2]
            if self._map[nx] and self._map[nx][ny] and self._map[nx][ny]==0 then
                self._map[nx][ny]=zId
                table.insert(zones[#zones], {nx,ny})
                table.insert(todo, {nx,ny})
            end
        end
    end
end

function ROT.Map.Cellular:_tunnel(sx,sy,ex,ey)
    local xOffset=ex-sx
    local yOffset=ey-sy
    local xpos   =sx
    local ypos   =sy
    local moves={}
    local xAbs=math.abs(xOffset)
    local yAbs=math.abs(yOffset)
    local firstHalf =self._rng:random()
    local secondHalf=1-firstHalf
    local xDir=xOffset>0 and 3 or 7
    local yDir=yOffset>0 and 5 or 1
    if xAbs<yAbs then
        local tempDist=math.ceil(yAbs*firstHalf)
        table.insert(moves, {yDir, tempDist})
        table.insert(moves, {xDir, xAbs})
        tempDist=math.floor(yAbs*secondHalf)
        table.insert(moves, {yDir, tempDist})
    else
        local tempDist=math.ceil(xAbs*firstHalf)
        table.insert(moves, {xDir, tempDist})
        table.insert(moves, {yDir, yAbs})
        tempDist=math.floor(xAbs*secondHalf)
        table.insert(moves, {xDir, tempDist})
    end

    local dirs=ROT.DIRS.EIGHT
    self._map[xpos][ypos]=0
    while #moves>0 do
        local move=table.remove(moves)
        if move and move[1] and move[1]<9 and move[1]>0 then
            while move[2]>0 do
                xpos=xpos+dirs[move[1]][1]
                ypos=ypos+dirs[move[1]][2]
                self._map[xpos][ypos]=0
                move[2]=move[2]-1
            end
        end
    end
end

--- The Dungeon-style map Prototype.
-- This class is extended by ROT.Map.Digger and ROT.Map.Uniform
-- @module ROT.Map.Dungeon
ROT.Map.Dungeon = ROT.Map:extends { }

--- Constructor.
-- Called with ROT.Map.Dungeon:new()
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
function ROT.Map.Dungeon:__init(width, height)
    ROT.Map.Dungeon.super.__init(self, width, height)
    self._rooms    ={}
    self._corridors={}
end

--- Get rooms
-- Get a table of rooms on the map
-- @treturn table A table containing objects of the type ROT.Map.Room
function ROT.Map.Dungeon:getRooms() return self._rooms end

--- Get doors
-- Get a table of doors on the map
-- @treturn table A table {{x=int, y=int},...} for doors.
function ROT.Map.Dungeon:getDoors()
    local result={}
    for _,v in pairs(self._rooms) do
        for l in pairs(v._doors) do
            local s=l:split(',')
            table.insert(result, {x=tonumber(s[1]), y=tonumber(s[2])})
        end
    end
    return result
end

--- Get corridors
-- Get a table of corridors on the map
-- @treturn table A table containing objects of the type ROT.Map.Corridor
function ROT.Map.Dungeon:getCorridors() return self._corridors end

ROT.Map.Feature = class { __name='Feature' }
function ROT.Map.Feature:isValid() end
function ROT.Map.Feature:create() end
function ROT.Map.Feature:debug() end
function ROT.Map.Feature:createRandomAt() end

--- Room object.
-- Used by ROT.Map.Uniform and ROT.Map.Digger to create maps
-- @module ROT.Map.Room
ROT.Map.Room = ROT.Map.Feature:extends { }

--- Constructor.
-- creates a new room object with the assigned values
-- @tparam int x1 Left wall
-- @tparam int y1 Upper wall
-- @tparam int x2 Right wall
-- @tparam int y2 Bottom wall
-- @tparam[opt] int doorX x-position of door
-- @tparam[opt] int doorY y-position of door
function ROT.Map.Room:__init(x1, y1, x2, y2, doorX, doorY, rng)
    self._x1   =x1
    self._x2   =x2
    self._y1   =y1
    self._y2   =y2
    self._doors= {}
    if doorX then
        self._doors[doorX..','..doorY] = 1
    end
    self.__name='Room'
    self._rng  =rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Create Random with position.
-- @tparam int x x-position of room
-- @tparam int y y-position of room
-- @tparam int dx x-direction in which to build room 1==right -1==left
-- @tparam int dy y-direction in which to build room 1==down  -1==up
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for room {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for room {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function ROT.Map.Room:createRandomAt(x, y, dx, dy, options, rng)
    rng=rng and rng or math.random
    local min  =options.roomWidth[1]
    local max  =options.roomWidth[2]
    local width=min+math.floor(rng:random(min, max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    local height=min+math.floor(rng:random(min,max))

    if dx==1 then
        local y2=y-math.floor(rng:random()*height)
        return ROT.Map.Room:new(x+1, y2, x+width, y2+height-1, x, y)
    end
    if dx==-1 then
        local y2=y-math.floor(rng:random()*height)
        return ROT.Map.Room:new(x-width, y2, x-1, y2+height-1, x, y)
    end
    if dy==1 then
        local x2=x-math.floor(rng:random()*width)
        return ROT.Map.Room:new(x2, y+1, x2+width-1, y+height, x, y)
    end
    if dy==-1 then
        local x2=x-math.floor(rng:random()*width)
        return ROT.Map.Room:new(x2, y-height, x2+width-1, y-1, x, y)
    end
end

--- Create Random with center position.
-- @tparam int cx x-position of room's center
-- @tparam int cy y-position of room's center
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for room {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for room {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function ROT.Map.Room:createRandomCenter(cx, cy, options, rng)
    local min  =options.roomWidth[1]
    local max  =options.roomWidth[2]
    local width=min+math.floor(rng:random()*(max-min+1))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    local height=min+math.floor(rng:random()*(max-min+1))

    local x1=cx-math.floor(rng:random()*width)
    local y1=cy-math.floor(rng:random()*height)
    local x2=x1+width-1
    local y2=y1+height-1

    return ROT.Map.Room:new(x1, y1, x2, y2)
end

--- Create random with no position.
-- @tparam int availWidth Typically the width of the map.
-- @tparam int availHeight Typically the height of the map
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for room {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for room {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function ROT.Map.Room:createRandom(availWidth, availHeight, options, rng)
    local min  =options.roomWidth[1]
    local max  =options.roomWidth[2]
    local width=math.floor(rng:random(min, max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    local height=math.floor(rng:random(min, max))

    local left=availWidth-width
    local top =availHeight-height

    local x1=math.floor(rng:random()*left)
    local y1=math.floor(rng:random()*top)
    local x2=x1+width
    local y2=y1+height
    return ROT.Map.Room:new(x1, y1, x2, y2)
end

--- Place a door.
-- adds an element to this rooms _doors table
-- @tparam int x the x-position of the door
-- @tparam int y the y-position of the door
function ROT.Map.Room:addDoor(x, y)
    self._doors[x..','..y]=1
end

--- Get all doors.
-- Runs the provided callback on all doors for this room
-- @tparam function callback A function with two parameters (x, y) representing the position of the door.
function ROT.Map.Room:getDoors(callback)
    for k,_ in pairs(self._doors) do
        local parts=k:split(',')
        callback(tonumber(parts[1]), tonumber(parts[2]))
    end
end

--- Reset the room's _doors table.
-- @treturn ROT.Map.Room self
function ROT.Map.Room:clearDoors()
    self._doors={}
    return self
end

--- Add all doors based on available walls.
-- @tparam userdata gen The map generator calling this function. Lack of bind() function requires this. This is mainly so the map generator can hava a self reference in the two callbacks.
-- @tparam function isWallCallback
-- @treturn ROT.Map.Room self
function ROT.Map.Room:addDoors(gen, isWallCallback)
    local left  =self._x1-1
    local right =self._x2+1
    local top   =self._y1-1
    local bottom=self._y2+1
    for x=left,right do
        for y=top,bottom do
            if x~=left and x~=right and y~=top and y~=bottom then
            elseif isWallCallback(gen,x,y) then
            else self:addDoor(x,y) end
        end
    end
    return self
end

--- Write various information about this room to the console.
function ROT.Map.Room:debug()
    local command    = write and write or io.write
    local door='doors'
    for k,_ in pairs(self._doors) do door=door..'; '..k end
    local debugString= 'room    : '..(self._x1 and self._x1 or 'not available')
                              ..','..(self._y1 and self._y1 or 'not available')
                              ..','..(self._x2 and self._x2 or 'not available')
                              ..','..(self._y2 and self._y2 or 'not available')
                              ..','..door
    command(debugString)
end

--- Use two callbacks to confirm room validity.
-- @tparam userdata gen The map generator calling this function. Lack of bind() function requires this. This is mainly so the map generator can hava a self reference in the two callbacks.
-- @tparam function isWallCallback A function with three parameters (gen, x, y) that will return true if x, y represents a wall space in a map.
-- @tparam function canBeDugCallback A function with three parameters (gen, x, y) that will return true if x, y represents a map cell that can be made into floorspace.
-- @treturn boolean true if room is valid.
function ROT.Map.Room:isValid(gen, isWallCallback, canBeDugCallback)
    local left  =self._x1-1
    local right =self._x2+1
    local top   =self._y1-1
    local bottom=self._y2+1
    for x=left,right do
        for y=top,bottom do
            if x==left or x==right or y==top or y==bottom then
                if not isWallCallback(gen, x, y) then return false end
            else
                if not canBeDugCallback(gen, x, y) then return false end
            end
        end
    end
    return true
end

--- Create.
-- Function runs a callback to dig the room into a map
-- @tparam userdata gen The map generator calling this function. Passed as self to the digCallback
-- @tparam function digCallback The function responsible for digging the room into a map.
function ROT.Map.Room:create(gen, digCallback)
    local left  =self._x1-1
    local top   =self._y1-1
    local right =self._x2+1
    local bottom=self._y2+1
    local value=0
    for x=left,right do
        for y=top,bottom do
            if self._doors[x..','..y] then
                value=2
            elseif x==left or x==right or y==top or y==bottom then
                value=1
            else
                value=0
            end
            digCallback(gen, x, y, value)
        end
    end
end

--- Get center cell of room
-- @treturn table {x-position, y-position}
function ROT.Map.Room:getCenter()
    return {math.round((self._x1+self._x2)/2),
            math.round((self._y1+self._y2)/2)}
end

--- Get Left most floor space.
-- @treturn int left-most floor
function ROT.Map.Room:getLeft()   return self._x1 end
--- Get right-most floor space.
-- @treturn int right-most floor
function ROT.Map.Room:getRight()  return self._x2 end
--- Get top most floor space.
-- @treturn int top-most floor
function ROT.Map.Room:getTop()    return self._y1 end
--- Get bottom-most floor space.
-- @treturn int bottom-most floor
function ROT.Map.Room:getBottom() return self._y2 end

--- BrogueRoom object.
-- Used by ROT.Map.Brogue to create maps with 'cross rooms'
-- @module ROT.Map.BrogueRoom
ROT.Map.BrogueRoom = ROT.Map.Feature:extends { }
ROT.Map.BrogueRoom.__name='BrogueRoom'
--- Constructor.
-- creates a new BrogueRoom object with the assigned values
-- @tparam table dims Represents dimensions and positions of the rooms two rectangles
-- @tparam[opt] int doorX x-position of door
-- @tparam[opt] int doorY y-position of door
-- @tparam userdata rng Userdata with a .random(self, min, max) function
function ROT.Map.BrogueRoom:__init(dims, doorX, doorY, rng)
    self._dims =dims
    self._doors={}
    self._walls={}
    if doorX then
        self._doors[1] = {doorX, doorY}
    end
    self._rng=rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Create room at bottom center with dims 9x10 and 20x4
-- @tparam int availWidth Typically the width of the map.
-- @tparam int availHeight Typically the height of the map
function ROT.Map.BrogueRoom:createEntranceRoom(availWidth, availHeight)
    local dims={}
    dims.w1=9
    dims.h1=10
    dims.w2=20
    dims.h2=4

    dims.x1=math.floor(availWidth/2-dims.w1/2)
    dims.y1=math.floor(availHeight-dims.h1-1)
    dims.x2=math.floor(availWidth/2-dims.w2/2)
    dims.y2=math.floor(availHeight-dims.h2-1)

    return ROT.Map.BrogueRoom:new(dims)
end

--- Create Random with position.
-- @tparam int x x-position of room
-- @tparam int y y-position of room
-- @tparam int dx x-direction in which to build room 1==right -1==left
-- @tparam int dy y-direction in which to build room 1==down  -1==up
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for room {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for room {min,max}
  -- @tparam table options.crossWidth minimum/maximum width for rectangleTwo {min,max}
  -- @tparam table options.crossHeight minimum/maximum height for rectangleTwo {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(self, min, max) method
function ROT.Map.BrogueRoom:createRandomAt(x, y, dx, dy, options, rng)
    rng=rng and rng or math.random
    local dims={}

    local min=options.roomWidth[1]
    local max=options.roomWidth[2]
    dims.w1=math.floor(rng:random(min,max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    dims.h1=math.floor(rng:random(min,max))

    min=options.crossWidth[1]
    max=options.crossWidth[2]
    dims.w2=math.floor(rng:random(min,max))

    min=options.crossHeight[1]
    max=options.crossHeight[2]
    dims.h2=math.floor(rng:random(min,max))

    if dx==1 then
        -- wider rect gets x+1
        -- wider gets y-math.floor(rng:random()*widersHeight)
        if dims.w1>dims.w2 then
            dims.x1=x+1
            dims.y1=y-math.floor(rng:random()*dims.h1)
            dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
            dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
        else
            dims.x2=x+1
            dims.y2=y-math.floor(rng:random()*dims.h2)
            dims.x1=math.floor(rng:random(dims.x2, (dims.x2+dims.w2)-dims.w1))
            dims.y1=math.floor(rng:random(dims.y2, (dims.y2+dims.h2)-dims.h1))
        end
    elseif dx==-1 then
        -- wider rect gets x-widersWidth
        -- wider gets y-math.floor(rng:random()*widersHeight)
        if dims.w1>dims.w2 then
            dims.x1=x-dims.w1-1
            dims.y1=y-math.floor(rng:random()*dims.h1)
            dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
            dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
        else
            dims.x2=x-dims.w2-1
            dims.y2=y-math.floor(rng:random()*dims.h2)
            dims.x1=math.floor(rng:random(dims.x2, (dims.x2+dims.w2)-dims.w1))
            dims.y1=math.floor(rng:random(dims.y2, (dims.y2+dims.h2)-dims.h1))
        end
    elseif dy==1 then
        -- taller gets y+1
        -- taller gets x-math.floor(rng:random()*width)
        if dims.h1>dims.h2 then
            dims.y1=y+1
            dims.x1=x-math.floor(rng:random()*dims.w1)
            dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
            dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
        else
            dims.y2=y+1
            dims.x2=x-math.floor(rng:random()*dims.w2)
            dims.x1=math.floor(rng:random(dims.x2, (dims.x2+dims.w2)-dims.w1))
            dims.y1=math.floor(rng:random(dims.y2, (dims.y2+dims.h2)-dims.h1))
        end
    elseif dy==-1 then
        -- taller gets y-tallersHeight
        -- taller gets x-math.floor(rng:random()*width)
        if dims.h1>dims.h2 then
            dims.y1=y-dims.h1-1
            dims.x1=x-math.floor(rng:random()*dims.w1)
            dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
            dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
        else
            dims.y2=y-dims.h2-1
            dims.x2=x-math.floor(rng:random()*dims.w2)
            dims.x1=math.floor(rng:random(dims.x2, (dims.x2+dims.w2)-dims.w1))
            dims.y1=math.floor(rng:random(dims.y2, (dims.y2+dims.h2)-dims.h1))
        end
    else
        assert(false, 'dx or dy must be 1 or -1')
    end
    --if dims.x2~=dims.x2 then dims.x2=dims.x1 end
    --if dims.y2~=dims.y2 then dims.y2=dims.y1 end
    --if dims.x1~=dims.x1 then dims.x1=dims.x2 end
    --if dims.y1~=dims.y1 then dims.y1=dims.y2 end
    return ROT.Map.BrogueRoom:new(dims, x, y)
end

--- Create Random with center position.
-- @tparam int cx x-position of room's center
-- @tparam int cy y-position of room's center
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for room {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for room {min,max}
  -- @tparam table options.crossWidth minimum/maximum width for rectangleTwo {min,max}
  -- @tparam table options.crossHeight minimum/maximum height for rectangleTwo {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function ROT.Map.BrogueRoom:createRandomCenter(cx, cy, options, rng)
    rng=rng and rng or math.random
    local dims={}
    --- Generate Rectangle One dimensions
    local min=options.roomWidth[1]
    local max=options.roomWidth[2]
    dims.w1=math.floor(rng:random(min,max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    dims.h1=math.floor(rng:random(min,max))

    dims.x1=cx-math.floor(rng:random()*dims.w1)
    dims.y1=cy-math.floor(rng:random()*dims.h1)

    --- Generate Rectangle Two dimensions
    min=options.roomWidth[1]
    max=options.roomWidth[2]
    dims.w2=math.floor(rng:random(min,max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    dims.h2=math.floor(rng:random(min,max))

    dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
    dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
    if dims.x2~=dims.x2 then dims.x2=dims.x1 end
    if dims.y2~=dims.y2 then dims.y2=dims.y1 end

    return ROT.Map.BrogueRoom:new(dims)
end

--- Create random with no position.
-- @tparam int availWidth Typically the width of the map.
-- @tparam int availHeight Typically the height of the map
-- @tparam table options Options
  -- @tparam table options.roomWidth minimum/maximum width for rectangleOne {min,max}
  -- @tparam table options.roomHeight minimum/maximum height for rectangleOne {min,max}
  -- @tparam table options.crossWidth minimum/maximum width for rectangleTwo {min,max}
  -- @tparam table options.crossHeight minimum/maximum height for rectangleTwo {min,max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function ROT.Map.BrogueRoom:createRandom(availWidth, availHeight, options, rng)
    rng=rng and rng or math.random
    local dims={}
    --- Generate Rectangle One dimensions
    local min=options.roomWidth[1]
    local max=options.roomWidth[2]
    dims.w1=math.floor(rng:random(min,max))

    min=options.roomHeight[1]
    max=options.roomHeight[2]
    dims.h1=math.floor(rng:random(min,max))

    -- Consider moving these to aw-(w1+w2) and ah-(h1+h2)
    local left=availWidth-dims.w1
    local top=availHeight-dims.h1

    dims.x1=math.floor(rng:random()*left)
    dims.y1=math.floor(rng:random()*top)

    --- Generate Rectangle Two dimensions
    min=options.crossWidth[1]
    max=options.crossWidth[2]
    dims.w2=math.floor(rng:random(min,max))

    min=options.crossHeight[1]
    max=options.crossHeight[2]
    dims.h2=math.floor(rng:random(min,max))

    dims.x2=math.floor(rng:random(dims.x1, (dims.x1+dims.w1)-dims.w2))
    dims.y2=math.floor(rng:random(dims.y1, (dims.y1+dims.h1)-dims.h2))
    if dims.x2~=dims.x2 then dims.x2=dims.x1 end
    if dims.y2~=dims.y2 then dims.y2=dims.y1 end
    return ROT.Map.BrogueRoom:new(dims)
end

--- Use two callbacks to confirm room validity.
-- @tparam userdata gen The map generator calling this function. Lack of bind() function requires this. This is mainly so the map generator can hava a self reference in the two callbacks.
-- @tparam function isWallCallback A function with three parameters (gen, x, y) that will return true if x, y represents a wall space in a map.
-- @tparam function canBeDugCallback A function with three parameters (gen, x, y) that will return true if x, y represents a map cell that can be made into floorspace.
-- @treturn boolean true if room is valid.
function ROT.Map.BrogueRoom:isValid(gen, isWallCallback, canBeDugCallback)
    local dims=self._dims
    if dims.x2~=dims.x2 or dims.y2~=dims.y2 or dims.x1~=dims.x1 or dims.y1~=dims.y1  then
        return false
    end

    local left  =self:getLeft()-1
    local right =self:getRight()+1
    local top   =self:getTop()-1
    local bottom=self:getBottom()+1
    for x=left,right do
        for y=top,bottom do
            if self:_coordIsFloor(x, y) then
                if not isWallCallback(gen, x, y) or not canBeDugCallback(gen, x, y) then
                    return false
                end
            elseif self:_coordIsWall(x, y) then table.insert(self._walls, {x,y}) end
        end
    end

    return true
end

--- Create.
-- Function runs a callback to dig the room into a map
-- @tparam userdata gen The map generator calling this function. Passed as self to the digCallback
-- @tparam function digCallback The function responsible for digging the room into a map.
function ROT.Map.BrogueRoom:create(gen, digCallback)
    local value=0
    local left  =self:getLeft()-1
    local right =self:getRight()+1
    local top   =self:getTop()-1
    local bottom=self:getBottom()+1
    for x=left,right do
        for y=top,bottom do
            if self._doors[x..','..y] then
                value=2
            elseif self:_coordIsFloor(x, y) then
                value=0
            else
                value=1
            end
            digCallback(gen, x, y, value)
        end
    end
end

function ROT.Map.BrogueRoom:_coordIsFloor(x, y)
    local d=self._dims
    if x>=d.x1 and x<=d.x1+d.w1 and y>=d.y1 and y<=d.y1+d.h1 then
        return true
    elseif x>=d.x2 and x<=d.x2+d.w2 and y>=d.y2 and y<=d.y2+d.h2 then
        return true
    end
    return false
end

function ROT.Map.BrogueRoom:_coordIsWall(x, y)
    local dirs=ROT.DIRS.EIGHT
    for i=1,#dirs do
        local dir=dirs[i]
        if self:_coordIsFloor(x+dir[1], y+dir[2]) then return true end
    end
    return false
end

function ROT.Map.BrogueRoom:clearDoors()
    self._doors={}
end

function ROT.Map.BrogueRoom:getCenter()
    local d=self._dims
    local l=math.min(d.x1, d.x2)
    local r=math.max(d.x1+d.w1, d.x2+d.w2)

    local t=math.min(d.y1, d.y2)
    local b=math.max(d.y1+d.h1, d.y2+d.h2)

    return {math.round((l+r)/2), math.round((t+b)/2)}
end
function ROT.Map.BrogueRoom:getLeft()
    return math.min(self._dims.x1, self._dims.x2)
end
function ROT.Map.BrogueRoom:getRight()
    return math.max(self._dims.x1+self._dims.w1, self._dims.x2+self._dims.w2)
end
function ROT.Map.BrogueRoom:getTop()
    return math.min(self._dims.y1, self._dims.y2)
end
function ROT.Map.BrogueRoom:getBottom()
    return math.max(self._dims.y1+self._dims.h1, self._dims.y2+self._dims.h2)
end
function ROT.Map.BrogueRoom:debug()
    local cmd=write and write or io.write
    local str=''
    for k,v in pairs(self._dims) do
        str=str..k..'='..v..','
    end
    cmd(str)
end
function ROT.Map.BrogueRoom:addDoor(x, y)
    self._doors[x..','..y]=1
end
--- Add all doors based on available walls.
-- @tparam userdata gen The map generator calling this function. Lack of bind() function requires this. This is mainly so the map generator can hava a self reference in the two callbacks.
-- @tparam function isWallCallback
-- @treturn ROT.Map.Room self
function ROT.Map.BrogueRoom:addDoors(gen, isWallCallback)
    local left  =self:getLeft()
    local right =self:getRight()
    local top   =self:getTop()
    local bottom=self:getBottom()
    for x=left,right do
        for y=top,bottom do
            if x~=left and x~=right and y~=top and y~=bottom then
            elseif isWallCallback(gen, x,y) then
            else self:addDoor(x,y) end
        end
    end
    return self
end

--- Corridor object.
-- Used by ROT.Map.Uniform and ROT.Map.Digger to create maps
-- @module ROT.Map.Corridor
ROT.Map.Corridor = ROT.Map.Feature:extends { }

--- Constructor.
-- Called with ROT.Map.Corridor:new()
-- @tparam int startX x-position of first floospace in corridor
-- @tparam int startY y-position of first floospace in corridor
-- @tparam int endX x-position of last floospace in corridor
-- @tparam int endY y-position of last floospace in corridor
function ROT.Map.Corridor:__init(startX, startY, endX, endY, rng)
    assert(ROT, 'require rot')
    self._startX       =startX
    self._startY       =startY
    self._endX         =endX
    self._endY         =endY
    self._endsWithAWall=true
    self.__name        ='Corridor'
    self._rng  =rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Create random with position.
-- @tparam int x x-position of first floospace in corridor
-- @tparam int y y-position of first floospace in corridor
-- @tparam int dx x-direction of corridor (-1, 0, 1) for (left, none, right)
-- @tparam int dy y-direction of corridor (-1, 0, 1) for (up, none, down)
-- @tparam table options Options
  -- @tparam table options.corridorLength a table for the min and max corridor lengths {min, max}
-- @tparam[opt] userData rng A user defined object with a .random(min, max) method
function ROT.Map.Corridor:createRandomAt(x, y, dx, dy, options, rng)
    rng=rng and rng or math.random
    local min   =options.corridorLength[1]
    local max   =options.corridorLength[2]
    local length=math.floor(rng:random(min, max))
    return self:new(x, y, x+dx*length, y+dy*length)
end

--- Write various information about this corridor to the console.
function ROT.Map.Corridor:debug()
    local command    = write and write or io.write
    local debugString= 'ROT.Map.corridor: '..self._startX..','..self._startY..','..self._endX..','..self._endY
    command(debugString)
end

--- Use two callbacks to confirm corridor validity.
-- @tparam userdata gen The map generator calling this function. Lack of bind() function requires this. This is mainly so the map generator can hava a self reference in the two callbacks.
-- @tparam function isWallCallback A function with three parameters (gen, x, y) that will return true if x, y represents a wall space in a map.
-- @tparam function canBeDugCallback A function with three parameters (gen, x, y) that will return true if x, y represents a map cell that can be made into floorspace.
-- @treturn boolean true if corridor is valid.
function ROT.Map.Corridor:isValid(gen, isWallCallback, canBeDugCallback)
    local sx    =self._startX
    local sy    =self._startY
    local dx    =self._endX-sx
    local dy    =self._endY-sy
    local length=1+math.max(math.abs(dx), math.abs(dy))

    if dx>0 then dx=dx/math.abs(dx) end
    if dy>0 then dy=dy/math.abs(dy) end
    local nx=dy
    local ny=-dx

    local ok=true

    for i=0,length-1 do
        local x=sx+i*dx
        local y=sy+i*dy

        if not canBeDugCallback(gen,    x,    y) then ok=false end
        if not isWallCallback  (gen, x+nx, y+ny) then ok=false end
        if not isWallCallback  (gen, x-nx, y-ny) then ok=false end

        if not ok then
            length=i
            self._endX=x-dx
            self._endY=y-dy
            break
        end
    end

    if length==0 then return false end
    if length==1 and isWallCallback(gen, self._endX+dx, self._endY+dy) then return false end


    local firstCornerBad=not isWallCallback(gen, self._endX+dx+nx, self._endY+dy+ny)
    local secondCornrBad=not isWallCallback(gen, self._endX+dx-nx, self._endY+dy-ny)
    self._endsWithAWall =    isWallCallback(gen, self._endX+dx   , self._endY+dy   )
    if (firstCornerBad or secondCornrBad) and self._endsWithAWall then return false end

    return true
end

--- Create.
-- Function runs a callback to dig the corridor into a map
-- @tparam userdata gen The map generator calling this function. Passed as self to the digCallback
-- @tparam function digCallback The function responsible for digging the corridor into a map.
function ROT.Map.Corridor:create(gen, digCallback)
    local sx    =self._startX
    local sy    =self._startY
    local dx    =self._endX-sx
    local dy    =self._endY-sy

    local length=1+math.max(math.abs(dx), math.abs(dy))
    if dx~=0 then dx=dx/math.abs(dx) end
    if dy~=0 then dy=dy/math.abs(dy) end

    for i=0,length-1 do
        local x=sx+i*dx
        local y=sy+i*dy
        digCallback(gen, x, y, 0)
    end
    return true
end

--- Mark walls as priority for a future feature.
-- Use this for storing the three points at the end of the corridor that you probably want to make sure gets a room attached.
-- @tparam userdata gen The map generator calling this function. Passed as self to the digCallback
-- @tparam function priorityWallCallback The function responsible for receiving and processing the priority walls
function ROT.Map.Corridor:createPriorityWalls(gen, priorityWallCallback)
    if not self._endsWithAWall then return end

    local sx    =self._startX
    local sy    =self._startY
    local dx    =self._endX-sx
    local dy    =self._endY-sy

    if dx>0 then dx=dx/math.abs(dx) end
    if dy>0 then dy=dy/math.abs(dy) end
    local nx=dy
    local ny=-dx

    priorityWallCallback(gen, self._endX+dx, self._endY+dy)
    priorityWallCallback(gen, self._endX+nx, self._endY+ny)
    priorityWallCallback(gen, self._endX-nx, self._endY-ny)
end

--- The Digger Map Generator.
-- See http://www.roguebasin.roguelikedevelopment.org/index.php?title=Dungeon-Building_Algorithm.
-- @module ROT.Map.Digger
ROT.Map.Digger=ROT.Map.Dungeon:extends { }

--- Constructor.
-- Called with ROT.Map.Digger:new()
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam[opt] table options Options
  -- @tparam[opt={3,8}] table options.roomWidth room minimum and maximum width
  -- @tparam[opt={3,5}] table options.roomHeight room minimum and maximum height
  -- @tparam[opt={3,7}] table options.corridorLength corridor minimum and maximum length
  -- @tparam[opt=0.2] number options.dugPercentage we stop after this percentage of level area has been dug out
  -- @tparam[opt=1000] int options.timeLimit stop after this much time has passed (msec)
  -- @tparam[opt=false] boolean options.nocorridorsmode If true, do not use corridors to generate this map
function ROT.Map.Digger:__init(width, height, options, rng)
    ROT.Map.Digger.super.__init(self, width, height)

    self._options={
                    roomWidth={3,8},
                    roomHeight={3,5},
                    corridorLength={3,7},
                    dugPercentage=0.2,
                    timeLimit=1000,
                    nocorridorsmode=false
                  }
    if options then
        for k,_ in pairs(options) do
            self._options[k]=options[k]
        end
    end

    self._features={Room=4, Corridor=4}
    if self._options.nocorridorsmode then
        self._features.Corridor=nil
    end
    self._featureAttempts=20
    self._walls={}

    self._rng  =rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.Digger self
function ROT.Map.Digger:create(callback)
    self._rooms    ={}
    self._corridors={}
    self._map      =self:_fillMap(1)
    self._walls    ={}
    self._dug      =0
    local area     =(self._width-2)*(self._height-2)

    self:_firstRoom()

    local t1=os.clock()*1000
    local priorityWalls=0
    repeat
        local t2=os.clock()*1000
        if t2-t1>self._options.timeLimit then break end

        local wall=self:_findWall()
        if not wall then break end

        local parts=wall:split(',')
        local x    =tonumber(parts[1])
        local y    =tonumber(parts[2])
        local dir  =self:_getDiggingDirection(x, y)
        if dir then
            local featureAttempts=0
            repeat
                featureAttempts=featureAttempts+1
                if self:_tryFeature(x, y, dir[1], dir[2]) then
                    self:_removeSurroundingWalls(x, y)
                    self:_removeSurroundingWalls(x-dir[1], y-dir[2])
                    break
                end
            until featureAttempts>=self._featureAttempts
            priorityWalls=0
            for k,_ in pairs(self._walls) do
                if self._walls[k] > 1 then
                    priorityWalls=priorityWalls+1
                end
            end
        end
    until self._dug/area > self._options.dugPercentage and priorityWalls<1

    self:_addDoors()

    if callback then
        for i=1,self._width do
            for j=1,self._height do
                callback(i, j, self._map[i][j])
            end
        end
    end
    self._walls={}
    self._map=nil
    return self
end

function ROT.Map.Digger:_digCallback(x, y, value)
    if value==0 or value==2 then
        self._map[x][y]=0
        self._dug=self._dug+1
    else
        self._walls[x..','..y]=1
    end
end

function ROT.Map.Digger:_isWallCallback(x, y)
    if x<1 or y<1 or x>self._width or y>self._height then return false end
    return self._map[x][y]==1
end

function ROT.Map.Digger:_canBeDugCallback(x, y)
    if x<2 or y<2 or x>=self._width or y>=self._height then return false end
    return self._map[x][y]==1
end

function ROT.Map.Digger:_priorityWallCallback(x, y)
    self._walls[x..','..y]=2
end

function ROT.Map.Digger:_firstRoom()
    local cx  =math.floor(self._width/2)
    local cy  =math.floor(self._height/2)
    local room=ROT.Map.Room:new():createRandomCenter(cx, cy, self._options, self._rng)
    table.insert(self._rooms, room)
    room:create(self, self._digCallback)
end

function ROT.Map.Digger:_findWall()
    local prio1={}
    local prio2={}
    for k,_ in pairs(self._walls) do
        if self._walls[k]>1 then table.insert(prio2, k)
        else table.insert(prio1, k) end
    end
    local arr=#prio2>0 and prio2 or prio1
    if #arr<1 then return nil end
    local id=table.random(arr)
    self._walls[id]=nil
    return id
end

function ROT.Map.Digger:_tryFeature(x, y, dx, dy)
    local type=self._rng:getWeightedValue(self._features)
    local feature=ROT.Map[type]:createRandomAt(x,y,dx,dy,self._options,self._rng)
    if not feature:isValid(self, self._isWallCallback, self._canBeDugCallback) then
        return false
    end

    feature:create(self, self._digCallback)

    if type=='Room' then
        table.insert(self._rooms, feature)
    elseif type=='Corridor' then
        feature:createPriorityWalls(self, self._priorityWallCallback)
        table.insert(self._corridors, feature)
    end

    return true
end

function ROT.Map.Digger:_removeSurroundingWalls(cx, cy)
    local deltas=ROT.DIRS.FOUR
    for i=1,#deltas do
        local delta=deltas[i]
        local x    =cx+delta[1]
        local y    =cy+delta[2]
        self._walls[x..','..y]=nil
        x=2*delta[1]
        y=2*delta[2]
        self._walls[x..','..y]=nil
    end
end

function ROT.Map.Digger:_getDiggingDirection(cx, cy)
    local deltas=ROT.DIRS.FOUR
    local result=nil

    for i=1,#deltas do
        local delta=deltas[i]
        local x    =cx+delta[1]
        local y    =cy+delta[2]
        if x<1 or y<1 or x>self._width or y>self._height then return nil end
        if self._map[x][y]==0 then
            if result and #result>0 then return nil end
            result=delta
        end
    end
    if not result or #result<1 then return nil end

    return {-result[1], -result[2]}
end

function ROT.Map.Digger:_addDoors()
    for i=1,#self._rooms do
        local room=self._rooms[i]
        room:clearDoors()
        room:addDoors(self, self._isWallCallback)
    end
end

--- The Uniform Map Generator.
-- See http://www.roguebasin.rogue
ROT.Map.Uniform=ROT.Map.Dungeon:extends { }

--- Constructor.
-- Called with ROT.Map.Uniform:new()
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam[opt] table options Options
  -- @tparam[opt={4,9}] table options.roomWidth room minimum and maximum width
  -- @tparam[opt={4,6}] table options.roomHeight room minimum and maximum height
  -- @tparam[opt=0.2] number options.dugPercentage we stop after this percentage of level area has been dug out
  -- @tparam[opt=1000] int options.timeLimit stop after this much time has passed (msec)
function ROT.Map.Uniform:__init(width, height, options, rng)
    ROT.Map.Uniform.super.__init(self, width, height)
    assert(ROT, 'require rot')
    self.__name='Uniform'
    self._options={
                    roomWidth={4,9},
                    roomHeight={4,6},
                    roomDugPercentage=0.2,
                    timeLimit=1000
                  }
    if options then
        for k,_ in pairs(options) do
            self._options[k]=options[k]
        end
    end
    self._roomAttempts=20
    self._corridorAttempts=20
    self._connected={}
    self._unconnected={}
    self._rng=rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.Uniform self
function ROT.Map.Uniform:create(callback)
    local t1=os.clock()*1000
    while true do
        local t2=os.clock()*1000
        if t2-t1>self._options.timeLimit then return nil end
        self._map=self:_fillMap(1)
        self._dug=0
        self._rooms={}
        self._unconnected={}
        self:_generateRooms()
        if self:_generateCorridors() then break end
    end

    if callback then
        for i=1,self._width do
            for j=1,self._height do
                callback(i, j, self._map[i][j])
            end
        end
    end
    return self
end

function ROT.Map.Uniform:_generateRooms()
    local w=self._width-4
    local h=self._height-4
    local room=nil
    repeat
        room=self:_generateRoom()
        if self._dug/(w*h)>self._options.roomDugPercentage then break end
    until not room
end

function ROT.Map.Uniform:_generateRoom()
    local count=0
    while count<self._roomAttempts do
        count=count+1
        local room=ROT.Map.Room:createRandom(self._width, self._height, self._options, self._rng)
        if room:isValid(self, self._isWallCallback, self._canBeDugCallback) then
            room:create(self, self._digCallback)
            table.insert(self._rooms, room)
            return room
        end
    end
    return nil
end

function ROT.Map.Uniform:_generateCorridors()
    local cnt=0
    while cnt<self._corridorAttempts do
        cnt=cnt+1
        self._corridors={}
        self._map=self:_fillMap(1)
        for i=1,#self._rooms do
            local room=self._rooms[i]
            room:clearDoors()
            room:create(self, self._digCallback)
        end

        self._unconnected=table.randomize(table.slice(self._rooms))
        self._connected  ={}
        table.insert(self._connected, table.remove(self._unconnected))
        while true do
            local connected=table.random(self._connected)
            local room1    =self:_closestRoom(self._unconnected, connected)
            local room2    =self:_closestRoom(self._connected, room1)
            if not self:_connectRooms(room1, room2) then break end
            if #self._unconnected<1 then return true end
        end
    end
    return false
end

function ROT.Map.Uniform:_closestRoom(rooms, room)
    local dist  =math.huge
    local center=room:getCenter()
    local result=nil

    for i=1,#rooms do
        local r =rooms[i]
        local c =r:getCenter()
        local dx=c[1]-center[1]
        local dy=c[2]-center[2]
        local d =dx*dx+dy*dy
        if d<dist then
            dist  =d
            result=r
        end
    end
    return result
end

function ROT.Map.Uniform:_connectRooms(room1, room2)
    local center1=room1:getCenter()
    local center2=room2:getCenter()

    local diffX=center2[1]-center1[1]
    local diffY=center2[2]-center1[2]

    local dirIndex1=0
    local dirIndex2=0
    local min      =0
    local max      =0
    local index    =0

    if math.abs(diffX)<math.abs(diffY) then
        dirIndex1=diffY>0 and 3 or 1
        dirIndex2=(dirIndex1+1)%4+1
        min      =room2:getLeft()
        max      =room2:getRight()
        index    =1
    else
        dirIndex1=diffX>0 and 2 or 4
        dirIndex2=(dirIndex1+1)%4+1
        min      =room2:getTop()
        max      =room2:getBottom()
        index    =2
    end

    local index2=(index%2)+1

    local start=self:_placeInWall(room1, dirIndex1)
    if not start or #start<1 then return false end
    local endTbl={}

    if start[index] >= min and start[index] <= max then
        endTbl=table.slice(start)
        local value=nil
        if     dirIndex2==1 then value=room2:getTop()   -1
        elseif dirIndex2==2 then value=room2:getRight() +1
        elseif dirIndex2==3 then value=room2:getBottom()+1
        elseif dirIndex2==4 then value=room2:getLeft()  -1
        end
        endTbl[index2]=value
        self:_digLine({start, endTbl})
    elseif start[index] < min-1 or start[index] > max+1 then
        local diff=start[index]-center2[index]
        local rotation=0
        if dirIndex2==1 or dirIndex2==2 then rotation=diff<0 and 2 or 4
        elseif dirIndex2==3 or dirIndex2==4 then rotation=diff<0 and 4 or 2 end
        if rotation==0 then assert(false, 'failed to rotate') end
        dirIndex2=(dirIndex2+rotation)%4+1

        endTbl=self:_placeInWall(room2, dirIndex2)
        if not endTbl then return false end

        local mid={0,0}
        mid[index]=start[index]
        mid[index2]=endTbl[index2]
        self:_digLine({start, mid, endTbl})
    else
        endTbl=self:_placeInWall(room2, dirIndex2)
        if #endTbl<1 then return false end
        local mid   =math.round((endTbl[index2]+start[index2])/2)

        local mid1={0,0}
        local mid2={0,0}
        mid1[index] = start[index];
        mid1[index2] = mid;
        mid2[index] = endTbl[index];
        mid2[index2] = mid;
        self:_digLine({start, mid1, mid2, endTbl});
    end

    room1:addDoor(start[1],start[2])
    room2:addDoor(endTbl[1], endTbl[2])

    index=table.indexOf(self._unconnected, room1)
    if index>0 then
        table.insert(self._connected, table.remove(self._unconnected, index))
    end

    return true
end

function ROT.Map.Uniform:_placeInWall(room, dirIndex)
    local start ={0,0}
    local dir   ={0,0}
    local length=0
    local retTable={}

    if dirIndex==1 then
        dir   ={1,0}
        start ={room:getLeft()-1, room:getTop()-1}
        length= room:getRight()-room:getLeft()
    elseif dirIndex==2 then
        dir   ={0,1}
        start ={room:getRight()+1, room:getTop()}
        length=room:getBottom()-room:getTop()
    elseif dirIndex==3 then
        dir   ={1,0}
        start ={room:getLeft()-1, room:getBottom()+1}
        length=room:getRight()-room:getLeft()
    elseif dirIndex==4 then
        dir   ={0,1}
        start ={room:getLeft()-1, room:getTop()-1}
        length=room:getBottom()-room:getTop()
    end
    local avail={}
    local lastBadIndex=-1
    local null=string.char(0)
    for i=1,length do
        local x=start[1]+i*dir[1]
        local y=start[2]+i*dir[2]
        table.insert(avail, null)
        if self._map[x][y]==1 then --is a wall
            if lastBadIndex ~=i-1 then
                avail[i]={x, y}
            end
        else
            lastBadIndex=i
            if i>1 then avail[i-1]=null end
        end
    end

    for i=1,#avail do
        if avail[i]~=string.char(0) then
            table.insert(retTable, avail[i])
            i=i-1
        end
    end
    return #retTable>0 and table.random(retTable) or nil
end

function ROT.Map.Uniform:_digLine(points)
    for i=2,#points do
        local start=points[i-1]
        local endPt=points[i]
        local corridor=ROT.Map.Corridor:new(start[1], start[2], endPt[1], endPt[2])
        corridor:create(self, self._digCallback)
        table.insert(self._corridors, corridor)
    end
end

function ROT.Map.Uniform:_digCallback(x, y, value)
    self._map[x][y]=value
    if value==0 then self._dug=self._dug+1 end
end

function ROT.Map.Uniform:_isWallCallback(x, y)
    if x<1 or y<1 or x>self._width or y>self._height then return false end
    return self._map[x][y]==1
end

function ROT.Map.Uniform:_canBeDugCallback(x, y)
    if x<2 or y<2 or x>=self._width or y>=self._height then return false end
    return self._map[x][y]==1
end

--- Rogue Map Generator.
-- A map generator based on the original Rogue map gen algorithm
-- See http://kuoi.com/~kamikaze/GameDesign/art07_rogue_dungeon.php
-- @module ROT.Map.Rogue
ROT.Map.Rogue=ROT.Map.Dungeon:extends { }

--- Constructor.
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam[opt] table options Options
  -- @tparam int options.cellWidth Number of cells to create on the horizontal (number of rooms horizontally)
  -- @tparam int options.cellHeight Number of cells to create on the vertical (number of rooms vertically)
  -- @tparam int options.roomWidth Room min and max width
  -- @tparam int options.roomHeight Room min and max height
function ROT.Map.Rogue:__init(width, height, options, rng)
    ROT.Map.Rogue.super.__init(self, width, height)
    self.__name='Rogue'
    self._doors={}
    self._options={cellWidth=math.floor(width*0.0375), cellHeight=math.floor(height*0.125)}
    if options then for k,_ in pairs(options) do self._options[k]=options[k] end end
    self._rng=rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
    function calculateRoomSize(size, cell)
        local max=math.floor((size/cell)*0.8)
        local min=math.floor((size/cell)*0.25)
        min=min<2 and 2 or min
        max=max<2 and 2 or max
        return {min, max}
    end

    if not self._options.roomWidth then
        self._options.roomWidth=calculateRoomSize(width, self._options.cellWidth)
    end

    if not self._options.roomHeight then
        self._options.roomHeight=calculateRoomSize(height, self._options.cellHeight)
    end
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @treturn ROT.Map.Cellular|nil self or nil if time limit is reached
function ROT.Map.Rogue:create(callback)
    self.map=self:_fillMap(1)
    self._rooms={}
    self.connectedCells={}

    self:_initRooms()
    self:_connectRooms()
    self:_connectUnconnectedRooms()
    self:_createRandomRoomConnections()
    self:_createRooms()
    self:_createCorridors()
    if callback then
        for i=1,self._width do
            for j=1,self._height do
                callback(i, j, self.map[i][j])
            end
        end
    end
    return self
end

function ROT.Map.Rogue:getDoors() return self._doors end

function ROT.Map.Rogue:_getRandomInt(min, max)
    min=min and min or 0
    max=max and max or 1
    return math.floor(self._rng:random(min,max))
end

function ROT.Map.Rogue:_initRooms()
    for i=1,self._options.cellWidth do
        self._rooms[i]={}
        for j=1,self._options.cellHeight do
            self._rooms[i][j]={x=0, y=0, width=0, height=0, connections={}, cellx=i, celly=j}
        end
    end
end

function ROT.Map.Rogue:_connectRooms()
    local cgx=self:_getRandomInt(1, self._options.cellWidth)
    local cgy=self:_getRandomInt(1, self._options.cellHeight)
    local idx, ncgx, ncgy
    local found=false
    local room, otherRoom
    local dirToCheck=0
    repeat
        dirToCheck={1, 3, 5, 7}
        dirToCheck=table.randomize(dirToCheck)
        repeat
            found=false
            idx=table.remove(dirToCheck)
            ncgx=cgx+ROT.DIRS.EIGHT[idx][1]
            ncgy=cgy+ROT.DIRS.EIGHT[idx][2]

            if (ncgx>0 and ncgx<=self._options.cellWidth) and
               (ncgy>0 and ncgy<=self._options.cellHeight) then
                room=self._rooms[cgx][cgy]

                if #room.connections>0 then
                    if room.connections[1][1] == ncgx and
                       room.connections[1][2] == ncgy then
                        break
                    end
                end

                otherRoom=self._rooms[ncgx][ncgy]

                if #otherRoom.connections==0 then
                    table.insert(otherRoom.connections, {cgx,cgy})
                    table.insert(self.connectedCells, {ncgx, ncgy})
                    cgx=ncgx
                    cgy=ncgy
                    found=true
                end
            end
        until #dirToCheck<1 or found
    until #dirToCheck<1
end

function ROT.Map.Rogue:_connectUnconnectedRooms()
    local cw=self._options.cellWidth
    local ch=self._options.cellHeight

    self.connectedCells=table.randomize(self.connectedCells)
    local room, otherRoom, validRoom

    for i=1,cw do
        for j=1,ch do
            room=self._rooms[i][j]

            if #room.connections==0 then
                local dirs={1,3,5,7}
                dirs=table.randomize(dirs)
                validRoom=false
                repeat
                    local dirIdx=table.remove(dirs)
                    local newI=i+ROT.DIRS.EIGHT[dirIdx][1]
                    local newJ=j+ROT.DIRS.EIGHT[dirIdx][2]

                    if newI>0 and newI<=cw and
                       newJ>0 and newJ<=ch then

                        otherRoom=self._rooms[newI][newJ]
                        validRoom=true

                        if #otherRoom.connections==0 then
                            break
                        end

                        for k=1,#otherRoom.connections do
                            if otherRoom.connections[k][1]==i and
                               otherRoom.connections[k][2]==j then
                                validRoom=false
                                break
                            end
                        end

                        if validRoom then break end

                    end
                until #dirs<1
                if validRoom then table.insert(room.connections, {otherRoom.cellx, otherRoom.celly})
                else write('-- Unable to connect room.') end
            end
        end
    end
end

function ROT.Map.Rogue:_createRandomRoomConnections()
    return
end

function ROT.Map.Rogue:_createRooms()
    local w  =self._width
    local h  =self._height
    local cw =self._options.cellWidth
    local ch =self._options.cellHeight
    local cwp=math.floor(self._width/cw)
    local chp=math.floor(self._height/ch)

    local roomw, roomh
    local roomWidth =self._options.roomWidth
    local roomHeight=self._options.roomHeight
    local sx, sy
    local otherRoom


    for i=1,cw do
        for j=1,ch do
            sx=cwp*(i-1)
            sy=chp*(j-1)
            sx=sx<2 and 2 or  sx
            sy=sy<2 and 2 or  sy
            roomw=self:_getRandomInt(roomWidth[1], roomWidth[2])
            roomh=self:_getRandomInt(roomHeight[1], roomHeight[2])

            if j>1 then
                otherRoom=self._rooms[i][j-1]
                while sy-(otherRoom.y+otherRoom.height)<3 do
                    sy=sy+1
                end
            end

            if i>1 then
                otherRoom=self._rooms[i-1][j]
                while sx-(otherRoom.x+otherRoom.width)<3 do
                    sx=sx+1
                end
            end
            local sxOffset=math.round(self:_getRandomInt(0, cwp-roomw)/2)
            local syOffset=math.round(self:_getRandomInt(0, chp-roomh)/2)
            while sx+sxOffset+roomw>w do
                if sxOffset>0 then
                    sxOffset=sxOffset-1
                else
                    roomw=roomw-1
                end
            end

            while sy+syOffset+roomh>h do
                if syOffset>0 then
                    syOffset=syOffset-1
                else
                    roomh=roomh-1
                end
            end


            sx=sx+sxOffset
            sy=sy+syOffset

            self._rooms[i][j].x     =sx
            self._rooms[i][j].y     =sy
            self._rooms[i][j].width =roomw
            self._rooms[i][j].height=roomh

            for ii=sx,sx+roomw-1 do
                for jj=sy,sy+roomh-1 do
                    self.map[ii][jj]=0
                end
            end
        end
    end
end

function ROT.Map.Rogue:_getWallPosition(aRoom, aDirection)
    local rx, ry, door
    if aDirection==1 or aDirection==3 then
        local maxRx=aRoom.x+aRoom.width-1
        rx=self:_getRandomInt(aRoom.x, maxRx>aRoom.x and maxRx or aRoom.x)
        if aDirection==1 then
            ry  =aRoom.y-2
            door=ry+1
        else
            ry  =aRoom.y+aRoom.height+1
            door=ry-1
        end
        self.map[rx][door]=0
        table.insert(self._doors,{x=rx, y=door})
    elseif aDirection==2 or aDirection==4 then
        local maxRy=aRoom.y+aRoom.height-1
        ry=self:_getRandomInt(aRoom.y, maxRy>aRoom.y and maxRy or aRoom.y)
        if aDirection==2 then
            rx  =aRoom.x+aRoom.width+1
            door=rx-1
        else
            rx  =aRoom.x-2
            door=rx+1
        end
        self.map[door][ry]=0
        table.insert(self._doors,{x=door, y=ry})
    end
    return {rx, ry}
end

function ROT.Map.Rogue:_drawCorridor(startPosition, endPosition)
    local xOffset=endPosition[1]-startPosition[1]
    local yOffset=endPosition[2]-startPosition[2]
    local xpos   =startPosition[1]
    local ypos   =startPosition[2]
    local moves={}
    local xAbs=math.abs(xOffset)
    local yAbs=math.abs(yOffset)
    local firstHalf =self._rng:random()
    local secondHalf=1-firstHalf
    local xDir=xOffset>0 and 3 or 7
    local yDir=yOffset>0 and 5 or 1
    if xAbs<yAbs then
        local tempDist=math.ceil(yAbs*firstHalf)
        table.insert(moves, {yDir, tempDist})
        table.insert(moves, {xDir, xAbs})
        tempDist=math.floor(yAbs*secondHalf)
        table.insert(moves, {yDir, tempDist})
    else
        local tempDist=math.ceil(xAbs*firstHalf)
        table.insert(moves, {xDir, tempDist})
        table.insert(moves, {yDir, yAbs})
        tempDist=math.floor(xAbs*secondHalf)
        table.insert(moves, {xDir, tempDist})
    end

    local dirs=ROT.DIRS.EIGHT
    self.map[xpos][ypos]=0
    while #moves>0 do
        local move=table.remove(moves)
        if move and move[1] and move[1]<9 and move[1]>0 then
            while move[2]>0 do
                xpos=xpos+dirs[move[1]][1]
                ypos=ypos+dirs[move[1]][2]
                self.map[xpos][ypos]=0
                move[2]=move[2]-1
            end
        end
    end
end

function ROT.Map.Rogue:_createCorridors()
    local cw=self._options.cellWidth
    local ch=self._options.cellHeight
    local room, connection, otherRoom, wall, otherWall

    for i=1,cw do
        for j=1,ch do
            room=self._rooms[i][j]
            for k=1,#room.connections do
                connection=room.connections[k]
                otherRoom =self._rooms[connection[1]][connection[2]]

                if otherRoom.cellx>room.cellx then
                    wall     =2
                    otherWall=4
                elseif otherRoom.cellx<room.cellx then
                    wall     =4
                    otherWall=2
                elseif otherRoom.celly>room.celly then
                    wall     =3
                    otherWall=1
                elseif otherRoom.celly<room.celly then
                    wall     =1
                    otherWall=3
                end
                self:_drawCorridor(self:_getWallPosition(room, wall), self:_getWallPosition(otherRoom, otherWall))
            end
        end
    end
end

--- The Brogue Map Generator.
-- Based on the description of Brogues level generation at http://brogue.wikia.com/wiki/Level_Generation
-- @module ROT.Map.Brogue
ROT.Map.Brogue=ROT.Map.Dungeon:extends { }
ROT.Map.Brogue.__name='Brogue'

--- Constructor.
-- Called with ROT.Map.Brogue:new(). A note: Brogue's map is 79x29. Consider using those dimensions for Display if you're looking to build a brogue-like.
-- @tparam int width Width in cells of the map
-- @tparam int height Height in cells of the map
-- @tparam[opt] table options Options
  -- @tparam[opt={4,20}] table options.roomWidth Room width for rectangle one of cross rooms
  -- @tparam[opt={3,7}] table options.roomHeight Room height for rectangle one of cross rooms
  -- @tparam[opt={3,12}] table options.crossWidth Room width for rectangle two of cross rooms
  -- @tparam[opt={2,5}] table options.crossHeight Room height for rectangle two of cross rooms
  -- @tparam[opt={3,12}] table options.corridorWidth Length of east-west corridors
  -- @tparam[opt={2,5}] table options.corridorHeight Length of north-south corridors
-- @tparam userdata rng Userdata with a .random(self, min, max) function
function ROT.Map.Brogue:__init(width, height, options, rng)
    ROT.Map.Brogue.super.__init(self, width, height)
    self._options={
                    roomWidth={4,20},
                    roomHeight={3,7},
                    crossWidth={3,12},
                    crossHeight={2,5},
                    corridorWidth={2,12},
                    corridorHeight={2,5},
                    caveChance=.33,
                    corridorChance=.8
                  }

    if options then
        for k,v in pairs(options) do self._options[k]=v end
    end

    self._walls={}
    self._rooms={}
    self._doors={}
    self._loops=30
    self._loopAttempts=300
    self._maxrooms=99
    self._roomAttempts=600
    self._dirs=ROT.DIRS.FOUR
    self._rng=rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Create.
-- Creates a map.
-- @tparam function callback This function will be called for every cell. It must accept the following parameters:
  -- @tparam int callback.x The x-position of a cell in the map
  -- @tparam int callback.y The y-position of a cell in the map
  -- @tparam int callback.value A value representing the cell-type. 0==floor, 1==wall
-- @tparam boolean firstFloorBehavior If true will put an upside T (9x10v and 20x4h) at the bottom center of the map.
-- @treturn ROT.Map.Brogue self
function ROT.Map.Brogue:create(callback, firstFloorBehavior)
    self._map=self:_fillMap(1)
    self._rooms={}
    self._doors={}
    self._walls={}

    self:_buildFirstRoom(firstFloorBehavior)
    self:_generateRooms()
    self:_generateLoops()
    self:_closeDiagonalOpenings()
    if callback then
        for x=1,self._width do
            for y=1,self._height do
                callback(x,y,self._map[x][y])
            end
        end
    end
    local d=self._doors
    for i=1,#d do
        callback(d[i][1], d[i][2], 2)
    end
    return self
end

function ROT.Map.Brogue:_buildFirstRoom(firstFloorBehavior)
    while true do
        if firstFloorBehavior then
            local room=ROT.Map.BrogueRoom:createEntranceRoom(self._width, self._height)
            if room:isValid(self, self._isWallCallback, self._canBeDugCallback) then
                table.insert(self._rooms, room)
                room:create(self, self._digCallback)
                self:_insertWalls(room._walls)
                return room
            end
        elseif self._rng:random()<self._options.caveChance then
            return self:_buildCave()
        else
            local room=ROT.Map.BrogueRoom:createRandom(self._width, self._height, self._options, self._rng)
            if room:isValid(self, self._isWallCallback, self._canBeDugCallback) then
                table.insert(self._rooms, room)
                room:create(self, self._digCallback)
                self:_insertWalls(room._walls)
                return room
            end
        end
    end
end

function ROT.Map.Brogue:_buildCave()
    local cl=ROT.Map.Cellular:new(self._width, self._height, nil, self._rng)
    cl:randomize(.55)
    for _=1,5 do cl:create() end
    local map=cl._map
    local id=2
    local largest=2
    local bestBlob={0,{}}

    for x=1,self._width do
        for y=1,self._height do
            if map[x][y]==1 then
                local blobData=self:_fillBlob(x,y,map, id)
                if blobData[1]>bestBlob[1] then
                    largest=id
                    bestBlob=blobData
                end
                id=id+1
            end
        end
    end

    for i=1,#bestBlob[2] do table.insert(self._walls, bestBlob[2][i]) end

    for x=2,self._width-1 do
        for y=2,self._height-1 do
            if map[x][y]==largest then
                self._map[x][y]=0
            else
                self._map[x][y]=1
            end
        end
    end
end

function ROT.Map.Brogue:_fillBlob(x,y,map, id)
    map[x][y]=id
    local todo={{x,y}}
    local dirs=ROT.DIRS.EIGHT
    local size=1
    local walls={}
    repeat
        local pos=table.remove(todo, 1)
        for i=1,#dirs do
            local rx=pos[1]+dirs[i][1]
            local ry=pos[2]+dirs[i][2]
            if rx<1 or rx>self._width or ry<1 or ry>self._height then

            elseif map[rx][ry]==1 then
                map[rx][ry]=id
                table.insert(todo,{ rx, ry })
                size=size+1
            elseif map[rx][ry]==0 then
                table.insert(walls, {rx,ry})
            end
        end
    until #todo==0
    return {size, walls}
end

function ROT.Map.Brogue:_generateRooms()
    local rooms=0
    for i=1,1000 do
        if rooms>self._maxrooms then break end
        if self:_buildRoom(i>375) then
            rooms=rooms+1
        end
    end
end

function ROT.Map.Brogue:_buildRoom(forceNoCorridor)
    --local p=table.remove(self._walls,self._rng:random(1,#self._walls))
    local p=self._walls[self._rng:random(1,#self._walls)]
    if not p then return false end
    local d=self:_getDiggingDirection(p[1], p[2])
    if d then
        if self._rng:random()<self._options.corridorChance and not forceNoCorridor then
            local cd
            if d[1]~=0 then cd=self._options.corridorWidth
            else cd=self._options.corridorHeight
            end
            local corridor=ROT.Map.Corridor:createRandomAt(p[1]+d[1],p[2]+d[2],d[1],d[2],{corridorLength=cd}, self._rng)
            if corridor:isValid(self, self._isWallCallback, self._canBeDugCallback) then
                local dx=corridor._endX
                local dy=corridor._endY

                local room=ROT.Map.BrogueRoom:createRandomAt(dx, dy ,d[1],d[2], self._options, self._rng)

                if room:isValid(self, self._isWallCallback, self._canBeDugCallback) then
                    corridor:create(self, self._digCallback)
                    room:create(self, self._digCallback)
                    self:_insertWalls(room._walls)
                    self._map[p[1]][p[2]]=0
                    self._map[dx][dy]=0
                    return true
                end
            end
        else
            local room=ROT.Map.BrogueRoom:createRandomAt(p[1],p[2],d[1],d[2], self._options, self._rng)
            if room:isValid(self, self._isWallCallback, self._canBeDugCallback) then
                room:create(self, self._digCallback)
                self._map[p[1]][p[2]]=0
                self:_insertWalls(room._walls)
                table.insert(self._doors, room._doors[1])
                return true
            end
        end
    end
    return false
end

function ROT.Map.Brogue:_getDiggingDirection(cx, cy)
    local deltas=ROT.DIRS.FOUR
    local result=nil

    for i=1,#deltas do
        local delta=deltas[i]
        local x    =cx+delta[1]
        local y    =cy+delta[2]
        if x<1 or y<1 or x>self._width or y>self._height then return nil end
        if self._map[x][y]==0 then
            if result and #result>0 then return nil end
            result=delta
        end
    end
    if not result or #result<1 then return nil end

    return {-result[1], -result[2]}
end

function ROT.Map.Brogue:_insertWalls(wt)
    for _,v in pairs(wt) do
        table.insert(self._walls, v)
    end
end

function ROT.Map.Brogue:_generateLoops()
    local dirs=ROT.DIRS.FOUR
    local count=0
    local wd=self._width
    local hi=self._height
    local m=self._map
    local function cb()
        count=count+1
    end
    local function pass(x,y)
        return m[x][y]==0
    end
    for _=1,300 do
        if #self._walls<1 then return end
        local w=table.remove(self._walls, 1)--self._rng:random(1,#self._walls))
        for j=1,2 do
            local x=w[1] +dirs[j][1]
            local y=w[2] +dirs[j][2]
            local x2=w[1]+dirs[j+2][1]
            local y2=w[2]+dirs[j+2][2]
            if x>1 and x2>1 and y>1 and y2>1 and
                x<wd and x2<wd and y<hi and y2<hi and
                m[x][y]==0 and m[x2][y2]==0
            then
                local path=ROT.Path.AStar(x,y,pass)
                path:compute(x2, y2, cb)
                if count>30 then
                    m[w[1]][w[2]]=0
                end
                count=0
            end
        end
    end
end

function ROT.Map.Brogue:_closeDiagonalOpenings()
end

function ROT.Map.Brogue:_getDoors() return self._doors end

function ROT.Map.Brogue:_digCallback(x, y, value)
    self._map[x][y]=value
end

function ROT.Map.Brogue:_isWallCallback(x, y)
    if x<1 or y<1 or x>self._width or y>self._height then return false end
    return self._map[x][y]==1
end

function ROT.Map.Brogue:_canBeDugCallback(x, y)
    if x<2 or y<2 or x>=self._width or y>=self._height then
        return false
    end
    local drs=ROT.DIRS.FOUR
    for i=1,#drs do
        if self._map[x+drs[i][1]][y+drs[i][2]]==0 then return false end
    end
    return true
end

ROT.Noise=class{ }

function ROT.Noise:__init()
    self.__name='Noise'
end

function ROT.Noise:get() end

--- Simplex Noise Generator.
-- Based on a simple 2d implementation of simplex noise by Ondrej Zara
-- Which is based on a speed-improved simplex noise algorithm for 2D, 3D and 4D in Java.
-- Which is based on example code by Stefan Gustavson (stegu@itn.liu.se).
-- With Optimisations by Peter Eastman (peastman@drizzle.stanford.edu).
-- Better rank ordering method by Stefan Gustavson in 2012.
-- @module ROT.Noise.Simplex
ROT.Noise.Simplex=ROT.Noise:extends{ }

--- Constructor.
-- 2D simplex noise generator.
-- @tparam int gradients The random values for the noise.
function ROT.Noise.Simplex:__init(gradients)
    self.__name='Simplex'
    ROT.Noise.Simplex.super.__init(self)

    self._F2=.5*(math.sqrt(3)-1)
    self._G2=(3-math.sqrt(3))/6

    self._gradients={
                     { 0,-1},
                     { 1,-1},
                     { 1, 0},
                     { 1, 1},
                     { 0, 1},
                     {-1, 1},
                     {-1, 0},
                     {-1,-1}
                    }
    local permutations={}
    local count       =gradients and gradients or 256
    for i=1,count do
        table.insert(permutations, i)
    end

    permutations=table.randomize(permutations)

    self._perms  ={}
    self._indexes={}

    for i=1,2*count do
        table.insert(self._perms, permutations[i%count+1])
        table.insert(self._indexes, self._perms[i] % #self._gradients +1)
    end
end

--- Get noise for a cell
-- Iterate over this function to retrieve noise values
-- @tparam int xin x-position of noise value
-- @tparam int yin y-position of noise value
function ROT.Noise.Simplex:get(xin, yin)
    local perms  =self._perms
    local indexes=self._indexes
    local count  =#perms/2
    local G2     =self._G2

    local n0, n1, n2, gi=0, 0, 0

    local s =(xin+yin)*self._F2
    local i =math.floor(xin+s)
    local j =math.floor(yin+s)
    local t =(i+j)*G2
    local X0=i-t
    local Y0=j-t
    local x0=xin-X0
    local y0=yin-Y0

    local i1, j1
    if x0>y0 then
        i1=1
        j1=0
    else
        i1=0
        j1=1
    end

    local x1=x0-i1+G2
    local y1=y0-j1+G2
    local x2=x0-1+2*G2
    local y2=y0-1+2*G2

    local ii=i%count+1
    local jj=j%count+1

    local t0=.5- x0*x0 - y0*y0
    if t0>=0 then
        t0=t0*t0
        gi=indexes[ii+perms[jj]]
        local grad=self._gradients[gi]
        n0=t0*t0*(grad[1]*x0+grad[2]*y0)
    end

    local t1=.5- x1*x1 - y1*y1
    if t1>=0 then
        t1=t1*t1
        gi=indexes[ii+i1+perms[jj+j1]]
        local grad=self._gradients[gi]
        n1=t1*t1*(grad[1]*x1+grad[2]*y1)
    end

    local t2=.5- x2*x2 - y2*y2
    if t2>=0 then
        t2=t2*t2
        gi=indexes[ii+1+perms[jj+1]]
        local grad=self._gradients[gi]
        n2=t2*t2*(grad[1]*x2+grad[2]*y2)
    end
    return 70*(n0+n1+n2)
end

ROT.FOV=class{ }

function ROT.FOV:__init(lightPassesCallback, options)
    self.__name='FOV'
    self._lightPasses=lightPassesCallback
    self._options={topology=8}
    if options then for k,_ in pairs(options) do self._options[k]=options[k] end end
end

function ROT.FOV:compute() end

function ROT.FOV:_getCircle(cx, cy, r)
    local result={}
    local dirs, countFactor, startOffset
    local topo=self._options.topology
    if topo==4 then
        countFactor=1
        startOffset={0,1}
        dirs={
              ROT.DIRS.EIGHT[8],
              ROT.DIRS.EIGHT[2],
              ROT.DIRS.EIGHT[4],
              ROT.DIRS.EIGHT[6]
             }
    elseif topo==8 then
        dirs=ROT.DIRS.FOUR
        countFactor=2
        startOffset={-1,1}
    end

    local x=cx+startOffset[1]*r
    local y=cy+startOffset[2]*r

    for i=1,#dirs do
        for _=1,r*countFactor do
            table.insert(result, {x, y})
            x=x+dirs[i][1]
            y=y+dirs[i][2]
        end
    end
    return result
end

function ROT.FOV:_getRealCircle(cx, cy, r)
    local i=0
    local result={}
    while i<2*math.pi do
        i=i+0.05
        local x = cx + r * math.cos(i)
        local y = cy + r * math.sin(i)
        table.insert(result, {x,y})
    end
    return result
end

--- Precise Shadowcasting Field of View calculator.
-- The Precise shadow casting algorithm developed by Ondřej Žára for rot.js.
-- See http://roguebasin.roguelikedevelopment.org/index.php?title=Precise_Shadowcasting_in_JavaScript
-- @module ROT.FOV.Precise
ROT.FOV.Precise=ROT.FOV:extends{ }

--- Constructor.
-- Called with ROT.FOV.Precise:new()
-- @tparam function lightPassesCallback A function with two parameters (x, y) that returns true if a map cell will allow light to pass through
-- @tparam table options Options
  -- @tparam int options.topology Direction for light movement Accepted values: (4 or 8)
function ROT.FOV.Precise:__init(lightPassesCallback, options)
    ROT.FOV.Precise.super.__init(self, lightPassesCallback, options)
end

--- Compute.
-- Get visibility from a given point
-- @tparam int x x-position of center of FOV
-- @tparam int y y-position of center of FOV
-- @tparam int R radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam number callback.visibility The cell's visibility rating (from 0-1). How well can you see this cell?
function ROT.FOV.Precise:compute(x, y, R, callback)
    callback(x, y, 0, 1)
    local SHADOWS={}

    local blocks, A1, A2, visibility

    for r=1,R do
        local neighbors=self:_getCircle(x, y, r)
        local neighborCount=#neighbors

        for i=0,neighborCount-1 do
            local cx=neighbors[i+1][1]
            local cy=neighbors[i+1][2]
            A1={i>0 and 2*i-1 or 2*neighborCount-1, 2*neighborCount}
            A2={2*i+1, 2*neighborCount}

            blocks    =not self:_lightPasses(cx, cy)
            visibility=self:_checkVisibility(A1, A2, blocks, SHADOWS)
            if visibility>0 then callback(cx, cy, r, visibility) end
            if #SHADOWS==2 and SHADOWS[1][1]==0 and SHADOWS[2][1]==SHADOWS[2][2] then
                break
            end
        end
    end
end

function ROT.FOV.Precise:_checkVisibility(A1, A2, blocks, SHADOWS)
    if A1[1]>A2[1] then
        local v1=self:_checkVisibility(A1, {A1[2], A1[2]}, blocks, SHADOWS)
        local v2=self:_checkVisibility({0, 1}, A2, blocks, SHADOWS)
        return (v1+v2)/2
    end
    local index1=1
    local edge1 =false
    while index1<=#SHADOWS do
        local old =SHADOWS[index1]
        local diff=old[1]*A1[2] - A1[1]*old[2]
        if diff>=0 then
            if diff==0 and (index1)%2==1 then edge1=true end
            break
        end
        index1=index1+1
    end

    local index2=#SHADOWS
    local edge2=false
    while index2>0 do
        local old =SHADOWS[index2]
        local diff=A2[1]*old[2] - old[1]*A2[2]
        if diff >= 0 then
            if diff==0 and (index2)%2==0 then edge2=true end
            break
        end
        index2=index2-1
    end
    local visible=true
    if index1==index2 and (edge1 or edge2) then
        visible=false
    elseif edge1 and edge2 and index1+1==index2 and (index2)%2==0 then
        visible=false
    elseif index1>index2 and (index1)%2==0 then
        visible=false
    end
    if not visible then return 0 end
    local visibleLength=0
    local remove=index2-index1+1
    if remove%2==1 then
        if (index1)%2==0 then
            if #SHADOWS>0 then
                local P=SHADOWS[index1]
                visibleLength=(A2[1]*P[2] - P[1]*A2[2]) / (P[2]*A2[2])
            end
            if blocks then splice(SHADOWS, index1, remove, {A2}) end
        else
            if #SHADOWS>0 then
                local P=SHADOWS[index2]
                visibleLength=(P[1]*A1[2] - A1[1]*P[2]) / (A1[2]*P[2])
            end
            if blocks then splice(SHADOWS, index1, remove, {A1}) end
        end
    else
        if (index1)%2==0 then
            if #SHADOWS>0 then
                local P1=SHADOWS[index1]
                local P2=SHADOWS[index2]
                visibleLength=(P2[1]*P1[2] - P1[1]*P2[2]) / (P1[2]*P2[2])
            end
            if blocks then splice(SHADOWS, index1, remove) end
        else
            if blocks then splice(SHADOWS, index1, remove, {A1, A2}) end
            return 1
        end
    end

    local arcLength=(A2[1]*A1[2] - A1[1]*A2[2]) / (A1[2]*A2[2])
    return visibleLength/arcLength
end

function splice(t, i, rn, it) -- table, index, numberToRemove, insertTable
    if rn>0 then
        for _=1,rn do
            table.remove(t, i)
        end
    end
    if it and #it>0 then
        for idx=i,i+#it-1 do
            local el=table.remove(it, 1)
            if el then table.insert(t, idx, el) end
        end
    end
end

--- Recursive Shadowcasting Field of View calculator.
-- The Recursive shadow casting algorithm developed by Ondřej Žára for rot.js.
-- See http://roguebasin.roguelikedevelopment.org/index.php?title=Recursive_Shadowcasting_in_JavaScript
-- @module ROT.FOV.Recursive
ROT.FOV.Recursive=ROT.FOV:extends{ }
ROT.FOV.Recursive.__name='Recursive'
--- Constructor.
-- Called with ROT.FOV.Recursive:new()
-- @tparam function lightPassesCallback A function with two parameters (x, y) that returns true if a map cell will allow light to pass through
-- @tparam table options Options
  -- @tparam int options.topology Direction for light movement Accepted values: (4 or 8)
function ROT.FOV.Recursive:__init(lightPassesCallback, options)
    ROT.FOV.Recursive.super.__init(self, lightPassesCallback, options)
end

 ROT.FOV.Recursive._octants = {
    {-1,  0,  0,  1},
    { 0, -1,  1,  0},
    { 0, -1, -1,  0},
    {-1,  0,  0, -1},
    { 1,  0,  0, -1},
    { 0,  1, -1,  0},
    { 0,  1,  1,  0},
    { 1,  0,  0,  1}
}

--- Compute.
-- Get visibility from a given point
-- @tparam int x x-position of center of FOV
-- @tparam int y y-position of center of FOV
-- @tparam int R radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam boolean callback.visibility Indicates if the cell is seen
function ROT.FOV.Recursive:compute(x, y, R, callback)
    callback(x, y, 0, true)
    for i=1,#self._octants do
        self:_renderOctant(x,y,self._octants[i], R, callback)
    end
end

--- Compute 180.
-- Get visibility from a given point for a 180 degree arc
-- @tparam int x x-position of center of FOV
-- @tparam int y y-position of center of FOV
-- @tparam int R radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam int dir viewing direction (use ROT.DIR index for values)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam boolean callback.visibility Indicates if the cell is seen
function ROT.FOV.Recursive:compute180(x, y, R, dir, callback)
    callback(x, y, 0, true)
    local cur = dir - 1
    local prev=(cur-1+8)%8 + 1
    local nPre=(cur-2+8)%8 + 1
    local next=(cur+ 9 )%8 + 1

    self:_renderOctant(x, y, self._octants[nPre], R, callback)
    self:_renderOctant(x, y, self._octants[prev], R, callback)
    self:_renderOctant(x, y, self._octants[dir ], R, callback)
    self:_renderOctant(x, y, self._octants[next], R, callback)
end
--- Compute 90.
-- Get visibility from a given point for a 90 degree arc
-- @tparam int x x-position of center of FOV
-- @tparam int y y-position of center of FOV
-- @tparam int R radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam int dir viewing direction (use ROT.DIR index for values)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam boolean callback.visibility Indicates if the cell is seen
function ROT.FOV.Recursive:compute90(x, y, R, dir, callback)
    callback(x, y, 0, true)
    local cur = dir - 1
    local prev=(cur-1+8)%8 + 1

    self:_renderOctant(x, y, self._octants[dir ], R, callback)
    self:_renderOctant(x, y, self._octants[prev], R, callback)
end

function ROT.FOV.Recursive:_renderOctant(x, y, octant, R, callback)
    self:_castVisibility(x, y, 1, 1.0, 0.0, R + 1, octant[1], octant[2], octant[3], octant[4], callback)
end

function ROT.FOV.Recursive:_castVisibility(startX, startY, row, visSlopeStart, visSlopeEnd, radius, xx, xy, yx, yy, callback)
    if visSlopeStart<visSlopeEnd then return end
    for i=row,radius do
        local dx=-i-1
        local dy=-i
        local blocked=false
        local newStart=0

        while dx<=0 do
            dx=dx+1
            local slopeStart=(dx-0.5)/(dy+0.5)
            local slopeEnd=(dx+0.5)/(dy-0.5)

            if slopeEnd<=visSlopeStart then
                if slopeStart<visSlopeEnd then break end
                local mapX=startX+dx*xx+dy*xy
                local mapY=startY+dx*yx+dy*yy

                if dx*dx+dy*dy<radius*radius then
                    callback(mapX, mapY, i, true)
                end
                if not blocked then
                    if not self:_lightPasses(mapX, mapY) and i<radius then
                        blocked=true
                        self:_castVisibility(startX, startY, i+1, visSlopeStart, slopeStart, radius, xx, xy, yx, yy, callback)
                        newStart=slopeEnd
                    end
                elseif not self:_lightPasses(mapX, mapY) then
                    newStart=slopeEnd
                else
                    blocked=false
                    visSlopeStart=newStart
                end
            end
        end
        if blocked then break end
    end
end

ROT.Line=class{ }
function ROT.Line:__init(x1, y1, x2, y2)
    self.x1=x1
    self.y1=y1
    self.x2=x2
    self.y2=y2
    self.points={}
end
function ROT.Line:getPoints()
    local dx =math.abs(self.x2-self.x1)
    local dy =math.abs(self.y2-self.y1)
    local sx =self.x1<self.x2 and 1 or -1
    local sy =self.y1<self.y2 and 1 or -1
    local err=dx-dy

    while true do
        table.insert(self.points, ROT.Point:new(self.x1, self.y1))
        if self.x1==self.x2 and self.y1==self.y2 then break end
        local e2=err*2
        if e2>-dx then
            err=err-dy
            self.x1 =self.x1+sx
        end
        if e2<dx then
            err=err+dx
            self.y1 =self.y1+sy
        end
    end
    return self
end

ROT.Point=class { }
function ROT.Point:__init(x, y)
    self.x=x
    self.y=y
end

function ROT.Point:hashCode()
    local prime =31
    local result=1
    result=prime*result+self.x
    result=prime*result+self.y
    return result
end

function ROT.Point:equals(other)
    if self==other                  then return true  end
    if other==nil                   or
    not other.is_a(ROT.Point)       or
    (other.x and other.x ~= self.x) or
    (other.y and other.y ~= self.y) then return false end
    return true
end

function ROT.Point:adjacentPoints()
    local points={}
    local i     =1
    for ox=-1,1 do for oy=-1,1 do
        points[i]=ROT.Point(self.x+ox,self.y+oy)
        i=i+1
    end end
    return points
end

--- Bresenham Based Ray-Casting FOV calculator.
-- See http://en.wikipedia.org/wiki/Bresenham's_line_algorithm.
-- Included for sake of having options. Provides three functions for computing FOV
-- @module ROT.FOV.Bresenham
ROT.FOV.Bresenham=ROT.FOV:extends { }

--- Constructor.
-- Called with ROT.FOV.Bresenham:new()
-- @tparam function lightPassesCallback A function with two parameters (x, y) that returns true if a map cell will allow light to pass through
-- @tparam table options Options
  -- @tparam int options.topology Direction for light movement Accepted values: (4 or 8)
  -- @tparam boolean options.useDiamond If true, the FOV will be a diamond shape as opposed to a circle shape.
function ROT.FOV.Bresenham:__init(lightPassesCallback, options)
    ROT.FOV.Bresenham.super.__init(self, lightPassesCallback, options)
    self.__name='Bresenham'
end

--- Compute.
-- Get visibility from a given point.
-- This method cast's rays from center to points on a circle with a radius 3-units longer than the provided radius.
-- A list of cell's within the radius is kept. This list is checked at the end to verify that each cell has been passed to the callback.
-- @tparam int cx x-position of center of FOV
-- @tparam int cy y-position of center of FOV
-- @tparam int r radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam number callback.visibility The cell's visibility rating (from 0-1). How well can you see this cell?
function ROT.FOV.Bresenham:compute(cx, cy, r, callback)
    local notvisited={}
    for x=-r,r do
        for y=-r,r do
            notvisited[ROT.Point(cx+x, cy+y):hashCode()]={cx+x, cy+y}
        end
    end

    callback(cx,cy,1,1)
    notvisited[ROT.Point(cx, cy):hashCode()]=nil

    local thePoints=self:_getCircle(cx, cy, r+3)
    for _,p in pairs(thePoints) do
        local x,y=p[1],p[2]
        local line=ROT.Line(cx,cy,x, y):getPoints()
        for i=2,#line.points do
            local point=line.points[i]
            if self:_oob(cx-point.x, cy-point.y, r) then break end
            if notvisited[point:hashCode()] then
                callback(point.x, point.y, i, 1-(i/r))
                notvisited[point:hashCode()]=nil
            end
            if not self:_lightPasses(point.x, point.y) then
                break
            end
        end
    end

    for _,v in pairs(notvisited) do
        local x,y=v[1],v[2]
        local line=ROT.Line(cx,cy,x, y):getPoints()
        for i=2,#line.points do
            local point=line.points[i]
            if self:_oob(cx-point.x, cy-point.y, r) then break end
            if notvisited[point:hashCode()] then
                callback(point.x, point.y, i, 1-(i/r))
                notvisited[point:hashCode()]=nil
            end
            if not self:_lightPasses(point.x, point.y) then
                break
            end
        end
    end
end

--- Compute Thorough.
-- Get visibility from a given point.
-- This method cast's rays from center to every cell within the given radius.
-- This method is much slower, but is more likely to not generate any anomalies within the field.
-- @tparam int cx x-position of center of FOV
-- @tparam int cy y-position of center of FOV
-- @tparam int r radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam number callback.visibility The cell's visibility rating (from 0-1). How well can you see this cell?
function ROT.FOV.Bresenham:computeThorough(cx, cy, r, callback)
    local visited={}
    callback(cx,cy,r)
    visited[ROT.Point(cx, cy):hashCode()]=0
    for x=-r,r do for y=-r,r do
        local line=ROT.Line(cx,cy,x+cx, y+cy):getPoints()
        for i=2,#line.points do
            local point=line.points[i]
            if self:_oob(cx-point.x, cy-point.y, r) then break end
            if not visited[point:hashCode()] then
                callback(point.x, point.y, r)
                visited[point:hashCode()]=0
            end
            if not self:_lightPasses(point.x, point.y) then
                break
            end
        end
    end end
end

--- Compute Thorough.
-- Get visibility from a given point. The quickest method provided.
-- This method cast's rays from center to points on a circle with a radius 3-units longer than the provided radius.
-- Unlike compute() this method stops at that point. It will likely miss cell's for fields with a large radius.
-- @tparam int cx x-position of center of FOV
-- @tparam int cy y-position of center of FOV
-- @tparam int r radius of FOV (i.e.: At most, I can see for R cells)
-- @tparam function callback A function that is called for every cell in view. Must accept four parameters.
  -- @tparam int callback.x x-position of cell that is in view
  -- @tparam int callback.y y-position of cell that is in view
  -- @tparam int callback.r The cell's distance from center of FOV
  -- @tparam number callback.visibility The cell's visibility rating (from 0-1). How well can you see this cell?
function ROT.FOV.Bresenham:computeQuick(cx, cy, r, callback)
    local visited={}
    callback(cx,cy,1, 1)
    visited[ROT.Point(cx, cy):hashCode()]=0

    local thePoints=self:_getCircle(cx, cy, r+3)
    for _,p in pairs(thePoints) do
        local x,y=p[1],p[2]
        local line=ROT.Line(cx,cy,x, y):getPoints()
        for i=2,#line.points do
            local point=line.points[i]
            if self:_oob(cx-point.x, cy-point.y, r) then break end
            if not visited[point:hashCode()] then
                callback(point.x, point.y, i, 1-(i*i)/(r*r))
                visited[point:hashCode()]=0
            end
            if not self:_lightPasses(point.x, point.y) then
                break
            end
        end
    end
end

function ROT.FOV.Bresenham:_oob(x, y, r)
    if not self._options.useDiamond then
        local ab=((x*x)+(y*y))
        local c =(r*r)
        return ab > c
    else
        return math.abs(x)+math.abs(y)>r
    end
end

--- The Color Toolkit.
-- Color is a color handler that treats any
-- objects intended to represent a color as a
-- table of the following schema:
-- @module ROT.Color
ROT.Color=class { }

function ROT.Color:__init(rng)
    self._rng = rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
    self._cached={
            black= {r=0,g=0,b=0,a=255},
            navy= {r=0,g=0,b=128,a=255},
            darkblue= {r=0,g=0,b=139,a=255},
            mediumblue= {r=0,g=0,b=205,a=255},
            blue= {r=0,g=0,b=255,a=255},
            darkgreen= {r=0,g=100,b=0,a=255},
            green= {r=0,g=128,b=0,a=255},
            teal= {r=0,g=128,b=128,a=255},
            darkcyan= {r=0,g=139,b=139,a=255},
            deepskyblue= {r=0,g=191,b=255,a=255},
            darkturquoise= {r=0,g=206,b=209,a=255},
            mediumspringgreen= {r=0,g=250,b=154,a=255},
            lime= {r=0,g=255,b=0,a=255},
            springgreen= {r=0,g=255,b=127,a=255},
            aqua= {r=0,g=255,b=255,a=255},
            cyan= {r=0,g=255,b=255,a=255},
            midnightblue= {r=25,g=25,b=112,a=255},
            dodgerblue= {r=30,g=144,b=255,a=255},
            forestgreen= {r=34,g=139,b=34,a=255},
            seagreen= {r=46,g=139,b=87,a=255},
            darkslategray= {r=47,g=79,b=79,a=255},
            darkslategrey= {r=47,g=79,b=79,a=255},
            limegreen= {r=50,g=205,b=50,a=255},
            mediumseagreen= {r=60,g=179,b=113,a=255},
            turquoise= {r=64,g=224,b=208,a=255},
            royalblue= {r=65,g=105,b=225,a=255},
            steelblue= {r=70,g=130,b=180,a=255},
            darkslateblue= {r=72,g=61,b=139,a=255},
            mediumturquoise= {r=72,g=209,b=204,a=255},
            indigo= {r=75,g=0,b=130,a=255},
            darkolivegreen= {r=85,g=107,b=47,a=255},
            cadetblue= {r=95,g=158,b=160,a=255},
            cornflowerblue= {r=100,g=149,b=237,a=255},
            mediumaquamarine= {r=102,g=205,b=170,a=255},
            dimgray= {r=105,g=105,b=105,a=255},
            dimgrey= {r=105,g=105,b=105,a=255},
            slateblue= {r=106,g=90,b=205,a=255},
            olivedrab= {r=107,g=142,b=35,a=255},
            slategray= {r=112,g=128,b=144,a=255},
            slategrey= {r=112,g=128,b=144,a=255},
            lightslategray= {r=119,g=136,b=153,a=255},
            lightslategrey= {r=119,g=136,b=153,a=255},
            mediumslateblue= {r=123,g=104,b=238,a=255},
            lawngreen= {r=124,g=252,b=0,a=255},
            chartreuse= {r=127,g=255,b=0,a=255},
            aquamarine= {r=127,g=255,b=212,a=255},
            maroon= {r=128,g=0,b=0,a=255},
            purple= {r=128,g=0,b=128,a=255},
            olive= {r=128,g=128,b=0,a=255},
            gray= {r=128,g=128,b=128,a=255},
            grey= {r=128,g=128,b=128,a=255},
            skyblue= {r=135,g=206,b=235,a=255},
            lightskyblue= {r=135,g=206,b=250,a=255},
            blueviolet= {r=138,g=43,b=226,a=255},
            darkred= {r=139,g=0,b=0,a=255},
            darkmagenta= {r=139,g=0,b=139,a=255},
            saddlebrown= {r=139,g=69,b=19,a=255},
            darkseagreen= {r=143,g=188,b=143,a=255},
            lightgreen= {r=144,g=238,b=144,a=255},
            mediumpurple= {r=147,g=112,b=216,a=255},
            darkviolet= {r=148,g=0,b=211,a=255},
            palegreen= {r=152,g=251,b=152,a=255},
            darkorchid= {r=153,g=50,b=204,a=255},
            yellowgreen= {r=154,g=205,b=50,a=255},
            sienna= {r=160,g=82,b=45,a=255},
            brown= {r=165,g=42,b=42,a=255},
            darkgray= {r=169,g=169,b=169,a=255},
            darkgrey= {r=169,g=169,b=169,a=255},
            lightblue= {r=173,g=216,b=230,a=255},
            greenyellow= {r=173,g=255,b=47,a=255},
            paleturquoise= {r=175,g=238,b=238,a=255},
            lightsteelblue= {r=176,g=196,b=222,a=255},
            powderblue= {r=176,g=224,b=230,a=255},
            firebrick= {r=178,g=34,b=34,a=255},
            darkgoldenrod= {r=184,g=134,b=11,a=255},
            mediumorchid= {r=186,g=85,b=211,a=255},
            rosybrown= {r=188,g=143,b=143,a=255},
            darkkhaki= {r=189,g=183,b=107,a=255},
            silver= {r=192,g=192,b=192,a=255},
            mediumvioletred= {r=199,g=21,b=133,a=255},
            indianred= {r=205,g=92,b=92,a=255},
            peru= {r=205,g=133,b=63,a=255},
            chocolate= {r=210,g=105,b=30,a=255},
            tan= {r=210,g=180,b=140,a=255},
            lightgray= {r=211,g=211,b=211,a=255},
            lightgrey= {r=211,g=211,b=211,a=255},
            palevioletred= {r=216,g=112,b=147,a=255},
            thistle= {r=216,g=191,b=216,a=255},
            orchid= {r=218,g=112,b=214,a=255},
            goldenrod= {r=218,g=165,b=32,a=255},
            crimson= {r=220,g=20,b=60,a=255},
            gainsboro= {r=220,g=220,b=220,a=255},
            plum= {r=221,g=160,b=221,a=255},
            burlywood= {r=222,g=184,b=135,a=255},
            lightcyan= {r=224,g=255,b=255,a=255},
            lavender= {r=230,g=230,b=250,a=255},
            darksalmon= {r=233,g=150,b=122,a=255},
            violet= {r=238,g=130,b=238,a=255},
            palegoldenrod= {r=238,g=232,b=170,a=255},
            lightcoral= {r=240,g=128,b=128,a=255},
            khaki= {r=240,g=230,b=140,a=255},
            aliceblue= {r=240,g=248,b=255,a=255},
            honeydew= {r=240,g=255,b=240,a=255},
            azure= {r=240,g=255,b=255,a=255},
            sandybrown= {r=244,g=164,b=96,a=255},
            wheat= {r=245,g=222,b=179,a=255},
            beige= {r=245,g=245,b=220,a=255},
            whitesmoke= {r=245,g=245,b=245,a=255},
            mintcream= {r=245,g=255,b=250,a=255},
            ghostwhite= {r=248,g=248,b=255,a=255},
            salmon= {r=250,g=128,b=114,a=255},
            antiquewhite= {r=250,g=235,b=215,a=255},
            linen= {r=250,g=240,b=230,a=255},
            lightgoldenrodyellow= {r=250,g=250,b=210,a=255},
            oldlace= {r=253,g=245,b=230,a=255},
            red= {r=255,g=0,b=0,a=255},
            fuchsia= {r=255,g=0,b=255,a=255},
            magenta= {r=255,g=0,b=255,a=255},
            deeppink= {r=255,g=20,b=147,a=255},
            orangered= {r=255,g=69,b=0,a=255},
            tomato= {r=255,g=99,b=71,a=255},
            hotpink= {r=255,g=105,b=180,a=255},
            coral= {r=255,g=127,b=80,a=255},
            darkorange= {r=255,g=140,b=0,a=255},
            lightsalmon= {r=255,g=160,b=122,a=255},
            orange= {r=255,g=165,b=0,a=255},
            lightpink= {r=255,g=182,b=193,a=255},
            pink= {r=255,g=192,b=203,a=255},
            gold= {r=255,g=215,b=0,a=255},
            peachpuff= {r=255,g=218,b=185,a=255},
            navajowhite= {r=255,g=222,b=173,a=255},
            moccasin= {r=255,g=228,b=181,a=255},
            bisque= {r=255,g=228,b=196,a=255},
            mistyrose= {r=255,g=228,b=225,a=255},
            blanchedalmond= {r=255,g=235,b=205,a=255},
            papayawhip= {r=255,g=239,b=213,a=255},
            lavenderblush= {r=255,g=240,b=245,a=255},
            seashell= {r=255,g=245,b=238,a=255},
            cornsilk= {r=255,g=248,b=220,a=255},
            lemonchiffon= {r=255,g=250,b=205,a=255},
            floralwhite= {r=255,g=250,b=240,a=255},
            snow= {r=255,g=250,b=250,a=255},
            yellow= {r=255,g=255,b=0,a=255},
            lightyellow= {r=255,g=255,b=224,a=255},
            ivory= {r=255,g=255,b=240,a=255},
            white= {r=255,g=255,b=255,a=255}
    }
end

--- Get color from string.
-- Convert one of several formats of string to what
-- Color interperets as a color object
-- @tparam string str Accepted formats 'rgb(0..255, 0..255, 0..255)', '#5fe', '#5FE', '#254eff', 'goldenrod'
function ROT.Color:fromString(str)
    local cached={r=0,g=0,b=0,a=255}
    if self._cached[str] then cached = self._cached[str]
    else
        local values={}
        if str:sub(1,1) == '#' then
            local i=1
            for s in str:gmatch('[%da-fA-F]') do
                values[i]=tonumber(s, 16)
                i=i+1
            end
            if #values==3 then
                for i=1,3 do values[i]=values[i]*17 end
            else
                for i=1,3 do
                    values[i+1]=values[i+1]+(16*values[i])
                    table.remove(values, i)
                end
            end
        elseif str:gmatch('rgb') then
            local i=1
            for s in str:gmatch('(%d+)') do
                values[i]=tonumber(s)
                i=i+1
            end
        end
        cached.r=values[1]
        cached.g=values[2]
        cached.b=values[3]
    end
    self._cached[str]=cached
    return {r=cached.r, g=cached.g, b=cached.b, a=cached.a}
end

--- Add two or more colors.
-- accepts either (color, color) or (color, tableOfColors)
-- @tparam table color1 A color table
-- @tparam table color2 A color table or a table of color tables.
-- @treturn table resulting color
function ROT.Color:add(color1, color2)
    local result={}
    for k,_ in pairs(color1) do result[k]=color1[k] end
    if color2.r then
        for k,_ in pairs(color2) do
            result[k]=result[k]+color2[k]
        end
    elseif color2[1].r then
        for k,_ in pairs(color2) do
            for l,_ in pairs(color2[k]) do
                assert(result[l])
                result[l]=result[l]+color2[k][l]
            end
        end
    end
    return result
end

--- Add two or more colors.
-- accepts either (color, color) or (color, tableOfColors)
-- Modifies first arg
-- @tparam table color1 A color table
-- @tparam table color2 A color table or a table of color tables.
-- @treturn table resulting color
function ROT.Color:add_(color1, color2)
    if color2.r then
        for k,_ in pairs(color2) do
            color1[k]=color1[k]+color2[k]
        end
    elseif color2[1].r then
        for k,_ in pairs(color2) do
            for l,_ in pairs(color2[k]) do
                color1[l]=color1[l]+color2[k][l]
            end
        end
    end
    return color1
end

-- multiply (mix) two or more colors.
-- accepts either (color, color) or (color, tableOfColors)
-- @tparam table color1 A color table
-- @tparam table color2 A color table or a table of color tables.
-- @treturn table resulting color
function ROT.Color:multiply(color1, color2)
    local result={}
    for k,_ in pairs(color1) do result[k]=color1[k] end
    if color2.r then
        for k,_ in pairs(color2) do
            result[k]=math.round(result[k]*color2[k]/255)
        end
    elseif color2[1].r then
        for k,_ in pairs(color2) do
            for l,_ in pairs(color2[k]) do
                result[l]=math.round(result[l]*color2[k][l]/255)
            end
        end
    end
    return result
end

-- multiply (mix) two or more colors.
-- accepts either (color, color) or (color, tableOfColors)
-- Modifies first arg
-- @tparam table color1 A color table
-- @tparam table color2 A color table or a table of color tables.
-- @treturn table resulting color
function ROT.Color:multiply_(color1, color2)
    if color2.r then
        for k,_ in pairs(color2) do
            color1[k]=math.round(color1[k]*color2[k]/255)
        end
    elseif color2[1].r then
        for k,_ in pairs(color2) do
            for l,_ in pairs(color2[k]) do
                color1[l]=math.round(color1[l]*color2[k][l]/255)
            end
        end
    end
    return color1
end

--- Interpolate (blend) two colors with a given factor.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam float factor A number from 0 to 1. <0.5 favors color1, >0.5 favors color2.
-- @treturn table resulting color
function ROT.Color:interpolate(color1, color2, factor)
    factor=factor and factor or .5
    local result={}
    for k,_ in pairs(color1) do result[k]=color1[k] end
    for k,_ in pairs(color2) do
        result[k]=math.round(result[k] + factor*(color2[k]-color1[k]))
    end
    return result
end

--- Interpolate (blend) two colors with a given factor in HSL mode.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam float factor A number from 0 to 1. <0.5 favors color1, >0.5 favors color2.
-- @treturn table resulting color
function ROT.Color:interpolateHSL(color1, color2, factor)
    factor=factor and factor or .5
    local hsl1 = self:rgb2hsl(color1)
    local hsl2 = self:rgb2hsl(color2)
    for k,_ in pairs(hsl2) do
        hsl1[k]= hsl1[k] + factor*(hsl2[k]-hsl1[k])
    end
    return self:hsl2rgb(hsl1)
end

--- Create a new random color based on this one
-- @tparam table color A color table
-- @tparam int|table diff One or more numbers to use for a standard deviation
function ROT.Color:randomize(color, diff)
    local result={}
    for k,_ in pairs(color) do result[k]=color[k] end
    if type(diff) ~= 'table' then
        diff=self._rng:random(0,diff)
        for k,_ in pairs(result) do result[k]=result[k]+diff end
    else
        assert(#diff>2, 'ROT.Color:randomize() can use a table of standard deviations, but it requires at least 3 elements in said table.')
        result.r=result.r+self._rng:random(0,diff[1])
        result.g=result.g+self._rng:random(0,diff[2])
        result.b=result.b+self._rng:random(0,diff[3])
    end
    return result
end

-- Convert rgb color to hsl
function ROT.Color:rgb2hsl(color)
    local r=color.r/255
    local g=color.g/255
    local b=color.b/255
    local max=math.max(r, g, b)
    local min=math.min(r, g, b)
    local h,s,l=0,0,(max+min)/2

    if max~=min then
        local d=max-min
        s=l>.5 and d/(2-max-min) or d/(max+min)
        if max==r then
            h=(g-b)/d + (g<b and 6 or 0)
        elseif max==g then
            h=(b-r)/d + 2
        elseif max==b then
            h=(r-g)/ d + 4
        end
            h=h/6
    end
    local result={}
    result.h=h
    result.s=s
    result.l=l
    return result
end

-- Convert hsl color to rgb
function ROT.Color:hsl2rgb(color)
    local result={r=0, g=0, b=0, a=255}
    if color.s==0 then
        for k,_ in pairs(result) do
            result[k]=color.l*255
        end
        result.a=255
        return result
    else
        local function hue2rgb(p, q, t)
            if t<0 then t=t+1 end
            if t>1 then t=t-1 end
            if t<1/6 then return (p+(q-p)*6*t) end
            if t<1/2 then return q end
            if t<2/3 then return (p+(q-p)*(2/3-t)*6) end
            return p
        end
        local s=color.s
        local l=color.l
        local q=l<.5 and l*(1+s) or l+s-l*s
        local p=2*l-q
        result.r=math.round(hue2rgb(p,q,color.h+1/3)*255)
        result.g=math.round(hue2rgb(p,q,color.h)*255)
        result.b=math.round(hue2rgb(p,q,color.h-1/3)*255)
        result.a=255
        return result
    end
end

--- Convert color to RGB string.
-- Get a string that can be fed to ROT.Color:fromString()
-- @tparam table color A color table
function ROT.Color:toRGB(color)
    return 'rgb('..self:_clamp(color.r)..','..self:_clamp(color.g)..','..self:_clamp(color.b)..')'
end

--- Convert color to Hex string
-- Get a string that can be fed to ROT.Color:fromString()
-- @tparam table color A color table
function ROT.Color:toHex(color)
    local function dec2hex(IN) -- thanks Lostgallifreyan(http://lua-users.org/lists/lua-l/2004-09/msg00054.html)
        local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
        while IN>0 do
            I=I+1
            IN,D=math.floor(IN/B),math.mod(IN,B)+1
            OUT=string.sub(K,D,D)..OUT
        end
        return OUT
    end

    local parts={}
    parts[1]=tostring(dec2hex(self:_clamp(color.r))):lpad('0',2)
    parts[2]=tostring(dec2hex(self:_clamp(color.g))):lpad('0',2)
    parts[3]=tostring(dec2hex(self:_clamp(color.b))):lpad('0',2)
    return '#'..table.concat(parts)
end

-- limit a number to 0..255
function ROT.Color:_clamp(n)
    return n<0 and 0 or n>255 and 255 or n
end

--- Lighting Calculator.
-- based on a traditional FOV for multiple light sources and multiple passes.
-- @module ROT.Lighting
ROT.Lighting=class {  }

--- Constructor.
-- Called with ROT.Color:new()
-- @tparam function reflectivityCallback Callback to retrieve cell reflectivity must return float(0..1)
  -- @tparam int reflectivityCallback.x x-position of cell
  -- @tparam int reflectivityCallback.y y-position of cell
-- @tparam table options Options
  -- @tparam[opt=1] int options.passes Number of passes. 1 equals to simple FOV of all light sources, >1 means a *highly simplified* radiosity-like algorithm.
  -- @tparam[opt=100] int options.emissionThreshold Cells with emissivity > threshold will be treated as light source in the next pass.
  -- @tparam[opt=10] int options.range Max light range
function ROT.Lighting:__init(reflectivityCallback, options)
    self._reflectivityCallback=reflectivityCallback
    self._options={passes=1, emissionThreshold=100, range=10}
    self._fov=nil
    self._lights={}
    self._reflectivityCache={}
    self._fovCache={}

    self._colorHandler=ROT.Color:new()

    if options then for k,_ in pairs(options) do self._options[k]=options[k] end end
end

--- Set FOV
-- Set the Field of View algorithm used to calculate light emission
-- @tparam userdata fov Class/Module used to calculate fov Must have compute(x, y, range, cb) method. Typically you would supply ROT.FOV.Precise:new() here.
-- @treturn ROT.Lighting self
-- @see ROT.FOV.Precise
-- @see ROT.FOV.Bresenham
function ROT.Lighting:setFOV(fov)
    self._fov=fov
    self._fovCache={}
    return self
end

--- Add or remove a light source
-- @tparam int x x-position of light source
-- @tparam int y y-position of light source
-- @tparam nil|string|table color An string accepted by Color:fromString(str) or a color table. A nil value here will remove the light source at x, y
-- @treturn ROT.Lighting self
-- @see ROT.Color
function ROT.Lighting:setLight(x, y, color)
    local key=x..','..y
    if color then
        self._lights[key]=type(color)=='string' and self._colorHandler:fromString(color) or color
    else
        self._lights[key]=nil
    end
    return self
end

--- Compute.
-- Compute the light sources and lit cells
-- @tparam function lightingCallback Will be called with (x, y, color) for every lit cell
-- @treturn ROT.Lighting self
function ROT.Lighting:compute(lightingCallback)
    local doneCells={}
    local emittingCells={}
    local litCells={}

    for k,_ in pairs(self._lights) do
        local light=self._lights[k]
        if not emittingCells[k] then emittingCells[k]={r=0,g=0,b=0,a=255} end
        self._colorHandler:add_(emittingCells[k], light)
    end

    for i=1,self._options.passes do
        self:_emitLight(emittingCells, litCells, doneCells)
        if i<self._options.passes then
            emittingCells=self:_computeEmitters(litCells, doneCells)
        end
    end

    for k,_ in pairs(litCells) do
        local parts=k:split(',')
        local x=tonumber(parts[1])
        local y=tonumber(parts[2])
        lightingCallback(x, y, litCells[k])
    end

    return self
end

function ROT.Lighting:_emitLight(emittingCells, litCells, doneCells)
    for k,_ in pairs(emittingCells) do
        local parts=k:split(',')
        local x=tonumber(parts[1])
        local y=tonumber(parts[2])
        self:_emitLightFromCell(x, y, emittingCells[k], litCells)
        doneCells[k]=1
    end
    return self
end

function ROT.Lighting:_computeEmitters(litCells, doneCells)
    local result={}
    if not litCells then return nil end
    for k,_ in pairs(litCells) do
        if not doneCells[k] then
            local color=litCells[k]

            local reflectivity
            if self._reflectivityCache and self._reflectivityCache[k] then
                reflectivity=self._reflectivityCache[k]
            else
                local parts=k:split(',')
                local x=tonumber(parts[1])
                local y=tonumber(parts[2])
                reflectivity=self:_reflectivityCallback(x, y)
                self._reflectivityCache[k]=reflectivity
            end

            if reflectivity>0 then
                local emission ={}
                local intensity=0
                for l,_ in pairs(color) do
                    if l~='a' then
                        local part=math.round(color[l]*reflectivity)
                        emission[l]=part
                        intensity=intensity+part
                    end
                end
                if intensity>self._options.emissionThreshold then
                    result[k]=emission
                end
            end
        end
    end

    return result
end

function ROT.Lighting:_emitLightFromCell(x, y, color, litCells)
    local key=x..','..y
    local fov
    if self._fovCache[key] then fov=self._fovCache[key]
    else fov=self:_updateFOV(x, y)
    end
    local formFactor
    for k,_ in pairs(fov) do
        formFactor=fov[k]
        if not litCells[k] then
            litCells[k]={r=0,g=0,b=0,a=255}
        end
        for l,_ in pairs(color) do
            if l~='a' then
                litCells[k][l]=litCells[k][l]+math.round(color[l]*formFactor)
            end
        end
    end
    return self
end

function ROT.Lighting:_updateFOV(x, y)
    local key1=x..','..y
    local cache={}
    self._fovCache[key1]=cache
    local range=self._options.range
    local function cb(x, y, r, vis)
        local key2=x..','..y
        local formFactor=vis*(1-r/range)
        if formFactor==0 then return end
        cache[key2]=formFactor
    end
    self._fov:compute(x, y, range, cb)

    return cache
end

ROT.Path=class { }

function ROT.Path:__init(toX, toY, passableCallback, options)
    self._toX  =toX
    self._toY  =toY
    self._fromX=nil
    self._fromY=nil
    self._passableCallback=passableCallback
    self._options= { topology=8 }

    if options then for k,_ in pairs(options) do self._options[k]=options[k] end end

    self._dirs= self._options.topology==8 and ROT.DIRS.EIGHT or ROT.DIRS.FOUR
    if self._options.topology==8 then
    self._dirs ={self._dirs[1],
                 self._dirs[3],
                 self._dirs[5],
                 self._dirs[7],
                 self._dirs[2],
                 self._dirs[4],
                 self._dirs[6],
                 self._dirs[8] }
    end
end

function ROT.Path:compute() end

function ROT.Path:_getNeighbors(cx, cy)
    local result={}
    for i=1,#self._dirs do
        local dir=self._dirs[i]
        local x=cx+dir[1]
        local y=cy+dir[2]
        if self._passableCallback(x, y) then
            table.insert(result, {x, y})
        end
    end
    return result
end

--- Dijkstra Pathfinding.
-- Simplified Dijkstra's algorithm: all edges have a value of 1
-- @module ROT.Path.Dijkstra
ROT.Path.Dijkstra=ROT.Path:extends { }
ROT.Path.Dijkstra.__name='Dijkstra'
--- Constructor.
-- @tparam int toX x-position of destination cell
-- @tparam int toY y-position of destination cell
-- @tparam function passableCallback Function with two parameters (x, y) that returns true if the cell at x,y is able to be crossed
-- @tparam table options Options
  -- @tparam[opt=8] int options.topology Directions for movement Accepted values (4 or 8)
function ROT.Path.Dijkstra:__init(toX, toY, passableCallback, options)
    ROT.Path.Dijkstra.super.__init(self, toX, toY, passableCallback, options)

    self._computed={}
    self._todo    ={}

    local obj = {x=toX, y=toY, prev=nil}
    self._computed[toX]={}
    self._computed[toX][toY] = obj
    table.insert(self._todo, obj)
end

--- Compute the path from a starting point
-- @tparam int fromX x-position of starting point
-- @tparam int fromY y-position of starting point
-- @tparam function callback Will be called for every path item with arguments "x" and "y"
function ROT.Path.Dijkstra:compute(fromX, fromY, callback)
    self._fromX=tonumber(fromX)
    self._fromY=tonumber(fromY)

    if not self._computed[self._fromX] then self._computed[self._fromX]={} end
    if not self._computed[self._fromX][self._fromY] then self:_compute(self._fromX, self._fromY) end
    if not self._computed[self._fromX][self._fromY] then return end

    local item=self._computed[self._fromX][self._fromY]
    while item do
        callback(tonumber(item.x), tonumber(item.y))
        item=item.prev
    end
end

function ROT.Path.Dijkstra:_compute(fromX, fromY)
    while #self._todo>0 do
        local item=table.remove(self._todo, 1)
        if item.x == fromX and item.y == fromY then return end

        local neighbors=self:_getNeighbors(item.x, item.y)

        for i=1,#neighbors do
            local x=neighbors[i][1]
            local y=neighbors[i][2]
            if not self._computed[x] then self._computed[x]={} end
            if not self._computed[x][y] then
                self:_add(x, y, item)
            end
        end
    end
end

function ROT.Path.Dijkstra:_add(x, y, prev)
    local obj={}
    obj.x   =x
    obj.y   =y
    obj.prev=prev

    self._computed[x][y]=obj
    table.insert(self._todo, obj)
end

--- DijkstraMap Pathfinding.
-- Based on the DijkstraMap Article on RogueBasin, http://roguebasin.roguelikedevelopment.org/index.php?title=The_Incredible_Power_of_Dijkstra_Maps
-- @module ROT.DijkstraMap
ROT.DijkstraMap=class {  }

--- Constructor.
-- @tparam int goalX x-position of cell that map will 'roll down' to
-- @tparam int goalY y-position of cell that map will 'roll down' to
-- @tparam int mapWidth width of the map
-- @tparam int mapHeight height of the map
-- @tparam function passableCallback a function with two parameters (x, y) that returns true if a map cell is passable
function ROT.DijkstraMap:__init(goalX, goalY, mapWidth, mapHeight, passableCallback)
    self._map={}
    self._goals={}
    table.insert(self._goals, {x=goalX, y=goalY})

    self._dimensions={}
    self._dimensions.w=mapWidth
    self._dimensions.h=mapHeight

    self._dirs={}
    local d=ROT.DIRS.EIGHT
    self._dirs ={d[1],
                 d[3],
                 d[5],
                 d[7],
                 d[2],
                 d[4],
                 d[6],
                 d[8] }


    self._passableCallback=passableCallback
end

--- Establish values for all cells in map.
-- call after ROT.DijkstraMap:new(goalX, goalY, mapWidth, mapHeight, passableCallback)
function ROT.DijkstraMap:compute()
    if #self._goals<1 then return
    elseif #self._goals==1 then return self:_singleGoalCompute()
    else return self:_manyGoalCompute() end
end

function ROT.DijkstraMap:_manyGoalCompute()
    local stillUpdating={}
    for i=1,self._dimensions.w do
        self._map[i]={}
        stillUpdating[i]={}
        for j=1,self._dimensions.h do
            stillUpdating[i][j]=true
            self._map[i][j]=math.huge
        end
    end

    for _,v in pairs(self._goals) do
        self._map[v.x][v.y]=0
    end

    local passes=0
    while true do
        local nochange=true
        for i,_ in pairs(stillUpdating) do
            for j,_ in pairs(stillUpdating[i]) do
                if self._passableCallback(i, j) then
                    local cellChanged=false
                    local low=math.huge
                    for _,v in pairs(self._dirs) do
                        local tx=(i+v[1])
                        local ty=(j+v[2])
                        if tx>0 and tx<=self._dimensions.w and ty>0 and ty<=self._dimensions.h then
                            local val=self._map[tx][ty]
                            if val and val<low then
                                low=val
                            end
                        end
                    end

                    if self._map[i][j]>low+2 then
                        self._map[i][j]=low+1
                        cellChanged=true
                        nochange=false
                    end
                    if not cellChanged and self._map[i][j]<1000 then stillUpdating[i][j]=nil end
                else stillUpdating[i][j]=nil end
            end
        end
        passes=passes+1
        if nochange then break end
    end
end

function ROT.DijkstraMap:_singleGoalCompute()
    local g=self._goals[1]
    for i=1,self._dimensions.w do
        self._map[i]={}
        for j=1,self._dimensions.h do
            self._map[i][j]=math.huge
        end
    end

    self._map[g.x][g.y]=0

    local val=1
    local wq={}
    local pq={}
    local ds=self._dirs

    table.insert(wq, {g.x, g.y})

    while true do
        while #wq>0 do
            local t=table.remove(wq,1)
            for _,d in pairs(ds) do
                local x=t[1]+d[1]
                local y=t[2]+d[2]
                if self._passableCallback(x,y) and self._map[x][y]>val then
                    self._map[x][y]=val
                    table.insert(pq,{x,y})
                end
            end
        end
        if #pq<1 then break end
        val=val+1
        while #pq>0 do table.insert(wq, table.remove(pq)) end
    end
end

function ROT.DijkstraMap:addGoal(gx, gy)
    table.insert(self._goals, {x=gx, y=gy})
end

function ROT.DijkstraMap:writeMapToConsole(returnString)
    local ls
    if returnString then ls='' end
    for y=1,self._dimensions.h do
        local s=''
        for x=1,self._dimensions.w do
            s=s..self._map[x][y]..','
        end
        write(s)
        if returnString then ls=ls..s..'\n' end
    end
    if returnString then return ls end
end

--- Get Width of map.
-- @treturn int w width of map
function ROT.DijkstraMap:getWidth() return self._dimensions.w end

--- Get Height of map.
-- @treturn int h height of map
function ROT.DijkstraMap:getHeight() return self._dimensions.h end

--- Get Dimensions as table.
-- @treturn table dimensions A table of width and height values
  -- @treturn int dimensions.w width of map
  -- @treturn int dimensions.h height of map
function ROT.DijkstraMap:getDimensions() return self._dimensions end

--- Get the map table.
-- @treturn table map A 2d array of map values, access like map[x][y]
function ROT.DijkstraMap:getMap() return self._map end

--- Get the goal cell as a table.
-- @treturn table goal table containing goal position
  -- @treturn int goal.x x-value of goal cell
function ROT.DijkstraMap:getGoals() return self._goals end

--- Get the direction of the goal from a given position
-- @tparam int x x-value of current position
-- @tparam int y y-value of current position
-- @treturn int xDir X-Direction towards goal. Either -1, 0, or 1
-- @treturn int yDir Y-Direction towards goal. Either -1, 0, or 1
function ROT.DijkstraMap:dirTowardsGoal(x, y)
    local low=self._map[x][y]
    if low==0 then return nil end
    local dir=nil
    for _,v in pairs(self._dirs) do
        local tx=(x+v[1])
        local ty=(y+v[2])
        if tx>0 and tx<=self._dimensions.w and ty>0 and ty<=self._dimensions.h then
            local val=self._map[tx][ty]
            if val<low then
                low=val
                dir=v
            end
        end
    end
    if dir then return dir[1],dir[2] end
    return nil
end

--- A* Pathfinding.
-- Simplified A* algorithm: all edges have a value of 1
-- @module ROT.Path.AStar
ROT.Path.AStar=ROT.Path:extends { }
ROT.Path.AStar.__name='AStar'
--- Constructor.
-- @tparam int toX x-position of destination cell
-- @tparam int toY y-position of destination cell
-- @tparam function passableCallback Function with two parameters (x, y) that returns true if the cell at x,y is able to be crossed
-- @tparam table options Options
  -- @tparam[opt=8] int options.topology Directions for movement Accepted values (4 or 8)
function ROT.Path.AStar:__init(toX, toY, passableCallback, options)
    ROT.Path.AStar.super.__init(self, toX, toY, passableCallback, options)
    self._todo={}
    self._done={}
    self._fromX=nil
    self._fromY=nil
end

--- Compute the path from a starting point
-- @tparam int fromX x-position of starting point
-- @tparam int fromY y-position of starting point
-- @tparam function callback Will be called for every path item with arguments "x" and "y"
function ROT.Path.AStar:compute(fromX, fromY, callback)
    self._todo={}
    self._done={}
    self._fromX=tonumber(fromX)
    self._fromY=tonumber(fromY)
    self._done[self._toX]={}
    self:_add(self._toX, self._toY, nil)

    while #self._todo>0 do
        local item=table.remove(self._todo, 1)
        if item.x == fromX and item.y == fromY then break end
        local neighbors=self:_getNeighbors(item.x, item.y)

        for i=1,#neighbors do
            local x = neighbors[i][1]
            local y = neighbors[i][2]
            if not self._done[x] then self._done[x]={} end
            if not self._done[x][y] then
                self:_add(x, y, item)
            end
        end
    end

    local item=self._done[self._fromX] and self._done[self._fromX][self._fromY] or nil
    if not item then return end

    while item do
        callback(tonumber(item.x), tonumber(item.y))
        item=item.prev
    end
end

function ROT.Path.AStar:_add(x, y, prev)
    local obj={}
    obj.x   =x
    obj.y   =y
    obj.prev=prev
    obj.g   =prev and prev.g+1 or 0
    obj.h   =self:_distance(x, y)
    self._done[x][y]=obj

    local f=obj.g+obj.h

    for i=1,#self._todo do
        local item=self._todo[i]
        if f<item.g+item.h then
            table.insert(self._todo, i, obj)
            return
        end
    end

    table.insert(self._todo, obj)
end

function ROT.Path.AStar:_distance(x, y)
    if self._options.topology==4 then
        return math.abs(x-self._fromX)+math.abs(y-self._fromY)
    elseif self._options.topology==8 then
        return math.max(math.abs(x-self._fromX), math.abs(y-self._fromY))
    end
end

--- A module used to roll and manipulate roguelike based dice
-- Based off the RL-Dice library at https://github.com/timothymtorres/RL-Dice
-- @module ROT.Dice
ROT.Dice=class{__name='Dice', minimum = 1} -- class default lowest possible roll is 1  (can set to nil to allow negative rolls)

--- Constructor that creates a new dice instance
-- Called with ROT.Dice:new()
-- @tparam ?int|string dice_notation Can be either a dice string, or int
-- @tparam[opt] int minimum Sets dice instance roll's minimum result boundaries
-- @tparam userdata rng Userdata with a .random(self, min, max) function
-- @treturn dice
function ROT.Dice:__init(dice_notation, minimum, rng)
    -- If dice_notation is a number, we must convert it into the proper dice string format
    if type(dice_notation) ==  'number' then dice_notation = '1d'..dice_notation end

    local dice_pattern = '[(]?%d+[d]%d+[+-]?[+-]?%d*[%^]?[+-]?[+-]?%d*[)]?[x]?%d*'
    assert(dice_notation == string.match(dice_notation, dice_pattern), "Dice string incorrectly formatted.")

    self.num = tonumber(string.match(dice_notation, '%d+'))
    self.faces = tonumber(string.match(dice_notation, '[d](%d+)'))

    local double_bonus = string.match(dice_notation, '[d]%d+([+-]?[+-])%d+')
    local bonus = string.match(dice_notation, '[d]%d+[+-]?([+-]%d+)')
    self.is_bonus_plural = double_bonus == '++' or double_bonus == '--'
    self.bonus = tonumber(bonus) or 0

    local double_reroll = string.match(dice_notation, '[%^]([+-]?[+-])%d+')
    local reroll = string.match(dice_notation, '[%^][+-]?([+-]%d+)')
    self.is_reroll_plural = double_reroll == '++' or double_reroll == '--'
    self.rerolls = tonumber(reroll) or 0

    self.sets = tonumber(string.match(dice_notation, '[x](%d+)')) or 1

    self.minimum = minimum

    self._rng=rng and rng or ROT.RNG.Twister:new()
    if not rng then self._rng:randomseed() end
end

--- Sets dice minimum result boundaries (if nil, no minimum result)
function ROT.Dice:setMin(value) self.minimum = value end

--- Get number of total dice
function ROT.Dice:getNum() return self.num end

--- Get number of total faces on a dice
function ROT.Dice:getFaces() return self.faces end

--- Get bonus to be added to the dice total
function ROT.Dice:getBonus() return self.bonus end

--- Get rerolls to be added to the dice
function ROT.Dice:getRerolls() return self.rerolls end

--- Get number of total dice sets
function ROT.Dice:getSets() return self.sets end

--- Get bonus to be added to all dice (if double bonus enabled) otherwise regular bonus
function ROT.Dice:getTotalBonus() return (self.is_bonus_plural and self.bonus*self.num) or self.bonus end

--- Get rerolls to be added to all dice (if double reroll enabled) otherwise regular reroll
function ROT.Dice:getTotalRerolls() return (self.is_reroll_plural and self.rerolls*self.num) or self.rerolls end

--- Returns boolean that checks if all dice are to be rerolled together or individually
function ROT.Dice:isDoubleReroll() return self.is_reroll_plural end

--- Returns boolean that checks if all dice are to apply a bonus together or individually
function ROT.Dice:isDoubleBonus() return self.is_bonus_plural end

--- Modifies bonus
function ROT.Dice:__add(value) self.bonus = self.bonus + value return self end

--- Modifies bonus
function ROT.Dice:__sub(value) self.bonus = self.bonus - value return self end

--- Modifies number of dice
function ROT.Dice:__mul(value) self.num = self.num + value return self end

--- Modifies amount of dice faces
function ROT.Dice:__div(value) self.faces = self.faces + value return self end

--- Modifies rerolls
function ROT.Dice:__pow(value) self.rerolls = self.rerolls + value return self end

--- Modifies dice sets
function ROT.Dice:__mod(value) self.sets = self.sets + value return self end

--- Returns a formatted dice string in roguelike notation
function ROT.Dice:__tostring()
    local num_dice, dice_faces, bonus, is_bonus_plural, rerolls, is_reroll_plural, sets = self.num, self.faces, self.bonus, self.is_bonus_plural, self.rerolls, self.is_reroll_plural, self.sets

    -- num_dice & dice_faces default to 1 if negative or 0!
    sets, num_dice, dice_faces = math.max(sets, 1), math.max(num_dice, 1), math.max(dice_faces, 1)

    local double_bonus = is_bonus_plural and (bonus >= 0 and '+' or '-') or ''
    bonus = (bonus ~= 0 and double_bonus..string.format('%+d', bonus)) or ''

    local double_reroll = is_reroll_plural and (rerolls >= 0 and '+' or '-') or ''
    rerolls = (rerolls ~= 0 and '^'..double_reroll..string.format('%+d', rerolls)) or ''

  if sets > 1 then return '('..num_dice..'d'..dice_faces..bonus..rerolls..')x'..sets
  else return num_dice..'d'..dice_faces..bonus..rerolls
  end
end

--- Modifies whether reroll or bonus applies to individual dice or all of them (pluralism_notation string must be one of the following operators `- + ^` The operator may be double signed to indicate pluralism)
function ROT.Dice:__concat(pluralism_notation)
    local str_b = string.match(pluralism_notation, '[+-][+-]?') or ''
    local bonus = ((str_b == '++' or str_b == '--') and 'double') or ((str_b == '+' or str_b == '-') and 'single') or nil

    local str_r = string.match(pluralism_notation, '[%^][%^]?') or ''
    local reroll = (str_r == '^^' and 'double') or (str_r == '^' and 'single') or nil

    if bonus == 'double' then self.is_bonus_plural = true
    elseif bonus == 'single' then self.is_bonus_plural = false end

    if reroll == 'double' then self.is_reroll_plural = true
    elseif reroll == 'single' then self.is_reroll_plural = false end
    return self
end

--- Rolls the dice
-- @tparam ?int|dice|str self
-- @tparam[opt] int minimum
-- @tparam[opt] ROT.RNG rng When called directly as ROT.Dice.roll, is used
--     in call to ROT.Dice.new. Not used when called on an instance of ROT.Dice.
--
--     i.e.: `ROT.Dice.roll('3d6', 1, rng) -- rng arg used`
--
--           `d = ROT.Dice:new('3d6', 1); d:roll(nil, rng) -- rng arg not used`
--
--
function ROT.Dice.roll(self, minimum, rng)
  if type(self) ~= 'table' then self = ROT.Dice:new(self, minimum, rng) end
  local num_dice, dice_faces = self.num, self.faces
  local bonus, rerolls = self.bonus, self.rerolls
  local is_bonus_plural, is_reroll_plural = self.is_bonus_plural, self.is_reroll_plural
  local sets, minimum = self.sets, self.minimum

  sets = math.max(sets, 1)  -- Minimum of 1 needed
  local set_rolls = {}

  local bonus_all = is_bonus_plural and bonus or 0
  rerolls = is_reroll_plural and rerolls*num_dice or rerolls

  -- num_dice & dice_faces CANNOT be negative!
  num_dice, dice_faces = math.max(num_dice, 1), math.max(dice_faces, 1)

  for i=1, sets do
    local rolls = {}
    for ii=1, num_dice + math.abs(rerolls) do
      rolls[ii] = self._rng:random(1, dice_faces) + bonus_all  -- if is_bonus_plural then bonus_all gets added to every roll, otherwise bonus_all = 0
    end

    if rerolls ~= 0 then
      -- sort and if reroll is + then remove lowest rolls, if reroll is - then remove highest rolls
      if rerolls > 0 then table.sort(rolls, function(a,b) return a>b end) else table.sort(rolls) end
      for index=num_dice + 1, #rolls do rolls[index] = nil end
    end

    -- bonus gets added to the last roll if it is not plural
    if not is_bonus_plural then rolls[#rolls] = rolls[#rolls] + bonus end

    local total = 0
    for _, number in ipairs(rolls) do total = total + number end
    set_rolls[i] = total
  end

  -- if minimum is empty then use dice class default min
  if minimum == nil then minimum = ROT.Dice.minimum end

  if minimum then
    for i=1, sets do
      set_rolls[i] = math.max(set_rolls[i], minimum)
    end
  end

  return unpack(set_rolls)
end

return ROT
