--- The Color Toolkit.
-- Color is a color handler that treats any
-- objects intended to represent a color as a
-- table of the following schema:
-- @module ROT.Color

local Color_PATH=({...})[1]:gsub("[%.\\/]color$", "") .. '/'
local class  =require (Color_PATH .. 'vendor/30log')

local Color=class { _cache, _rng }

function Color:__init()
    self._rng = ROT.RNG.Twister:new()
    self._rng:randomseed()
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
function Color:fromString(str)
    local cached={r=0,g=0,b=0,a=255}
    local r
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
                values[i]=s
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
function Color:add(color1, color2)
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
function Color:add_(color1, color2)
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
function Color:multiply(color1, color2)
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
function Color:multiply_(color1, color2)
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
function Color:interpolate(color1, color2, factor)
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
function Color:interpolateHSL(color1, color2, factor)
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
function Color:randomize(color, diff)
    local result={}
    for k,_ in pairs(color) do result[k]=color[k] end
    if type(diff) ~= 'table' then
        diff=self._rng:random(0,diff)
        for k,_ in pairs(result) do result[k]=result[k]+diff end
    else
        assert(#diff>2, 'Color:randomize() can use a table of standard deviations, but it requires at least 3 elements in said table.')
        result.r=result.r+self._rng:random(0,diff[1])
        result.g=result.g+self._rng:random(0,diff[2])
        result.b=result.b+self._rng:random(0,diff[3])
    end
    return result
end

-- Convert rgb color to hsl
function Color:rgb2hsl(color)
    r=color.r/255
    g=color.g/255
    b=color.b/255
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
    result={}
    result.h=h
    result.s=s
    result.l=l
    return result
end

-- Convert hsl color to rgb
function Color:hsl2rgb(color)
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
-- Get a string that can be fed to Color:fromString()
-- @tparam table color A color table
function Color:toRGB(color)
    return 'rgb('..self:_clamp(color.r)..','..self:_clamp(color.g)..','..self:_clamp(color.b)..')'
end

--- Convert color to Hex string
-- Get a string that can be fed to Color:fromString()
-- @tparam table color A color table
function Color:toHex(color)
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
function Color:_clamp(n)
    return n<0 and 0 or n>255 and 255 or n
end

return Color

--- Color cache
    -- A table of predefined color tables
    -- These keys can be passed to Color:fromString()
    -- @field black {r=0,g=0,b=0,a=255}
    -- @field navy {r=0,g=0,b=128,a=255}
    -- @field darkblue {r=0,g=0,b=139,a=255}
    -- @field mediumblue {r=0,g=0,b=205,a=255}
    -- @field blue {r=0,g=0,b=255,a=255}
    -- @field darkgreen {r=0,g=100,b=0,a=255}
    -- @field green {r=0,g=128,b=0,a=255}
    -- @field teal {r=0,g=128,b=128,a=255}
    -- @field darkcyan {r=0,g=139,b=139,a=255}
    -- @field deepskyblue {r=0,g=191,b=255,a=255}
    -- @field darkturquoise {r=0,g=206,b=209,a=255}
    -- @field mediumspringgreen {r=0,g=250,b=154,a=255}
    -- @field lime {r=0,g=255,b=0,a=255}
    -- @field springgreen {r=0,g=255,b=127,a=255}
    -- @field aqua {r=0,g=255,b=255,a=255}
    -- @field cyan {r=0,g=255,b=255,a=255}
    -- @field midnightblue {r=25,g=25,b=112,a=255}
    -- @field dodgerblue {r=30,g=144,b=255,a=255}
    -- @field forestgreen {r=34,g=139,b=34,a=255}
    -- @field seagreen {r=46,g=139,b=87,a=255}
    -- @field darkslategray {r=47,g=79,b=79,a=255}
    -- @field darkslategrey {r=47,g=79,b=79,a=255}
    -- @field limegreen {r=50,g=205,b=50,a=255}
    -- @field mediumseagreen {r=60,g=179,b=113,a=255}
    -- @field turquoise {r=64,g=224,b=208,a=255}
    -- @field royalblue {r=65,g=105,b=225,a=255}
    -- @field steelblue {r=70,g=130,b=180,a=255}
    -- @field darkslateblue {r=72,g=61,b=139,a=255}
    -- @field mediumturquoise {r=72,g=209,b=204,a=255}
    -- @field indigo {r=75,g=0,b=130,a=255}
    -- @field darkolivegreen {r=85,g=107,b=47,a=255}
    -- @field cadetblue {r=95,g=158,b=160,a=255}
    -- @field cornflowerblue {r=100,g=149,b=237,a=255}
    -- @field mediumaquamarine {r=102,g=205,b=170,a=255}
    -- @field dimgray {r=105,g=105,b=105,a=255}
    -- @field dimgrey {r=105,g=105,b=105,a=255}
    -- @field slateblue {r=106,g=90,b=205,a=255}
    -- @field olivedrab {r=107,g=142,b=35,a=255}
    -- @field slategray {r=112,g=128,b=144,a=255}
    -- @field slategrey {r=112,g=128,b=144,a=255}
    -- @field lightslategray {r=119,g=136,b=153,a=255}
    -- @field lightslategrey {r=119,g=136,b=153,a=255}
    -- @field mediumslateblue {r=123,g=104,b=238,a=255}
    -- @field lawngreen {r=124,g=252,b=0,a=255}
    -- @field chartreuse {r=127,g=255,b=0,a=255}
    -- @field aquamarine {r=127,g=255,b=212,a=255}
    -- @field maroon {r=128,g=0,b=0,a=255}
    -- @field purple {r=128,g=0,b=128,a=255}
    -- @field olive {r=128,g=128,b=0,a=255}
    -- @field gray {r=128,g=128,b=128,a=255}
    -- @field grey {r=128,g=128,b=128,a=255}
    -- @field skyblue {r=135,g=206,b=235,a=255}
    -- @field lightskyblue {r=135,g=206,b=250,a=255}
    -- @field blueviolet {r=138,g=43,b=226,a=255}
    -- @field darkred {r=139,g=0,b=0,a=255}
    -- @field darkmagenta {r=139,g=0,b=139,a=255}
    -- @field saddlebrown {r=139,g=69,b=19,a=255}
    -- @field darkseagreen {r=143,g=188,b=143,a=255}
    -- @field lightgreen {r=144,g=238,b=144,a=255}
    -- @field mediumpurple {r=147,g=112,b=216,a=255}
    -- @field darkviolet {r=148,g=0,b=211,a=255}
    -- @field palegreen {r=152,g=251,b=152,a=255}
    -- @field darkorchid {r=153,g=50,b=204,a=255}
    -- @field yellowgreen {r=154,g=205,b=50,a=255}
    -- @field sienna {r=160,g=82,b=45,a=255}
    -- @field brown {r=165,g=42,b=42,a=255}
    -- @field darkgray {r=169,g=169,b=169,a=255}
    -- @field darkgrey {r=169,g=169,b=169,a=255}
    -- @field lightblue {r=173,g=216,b=230,a=255}
    -- @field greenyellow {r=173,g=255,b=47,a=255}
    -- @field paleturquoise {r=175,g=238,b=238,a=255}
    -- @field lightsteelblue {r=176,g=196,b=222,a=255}
    -- @field powderblue {r=176,g=224,b=230,a=255}
    -- @field firebrick {r=178,g=34,b=34,a=255}
    -- @field darkgoldenrod {r=184,g=134,b=11,a=255}
    -- @field mediumorchid {r=186,g=85,b=211,a=255}
    -- @field rosybrown {r=188,g=143,b=143,a=255}
    -- @field darkkhaki {r=189,g=183,b=107,a=255}
    -- @field silver {r=192,g=192,b=192,a=255}
    -- @field mediumvioletred {r=199,g=21,b=133,a=255}
    -- @field indianred {r=205,g=92,b=92,a=255}
    -- @field peru {r=205,g=133,b=63,a=255}
    -- @field chocolate {r=210,g=105,b=30,a=255}
    -- @field tan {r=210,g=180,b=140,a=255}
    -- @field lightgray {r=211,g=211,b=211,a=255}
    -- @field lightgrey {r=211,g=211,b=211,a=255}
    -- @field palevioletred {r=216,g=112,b=147,a=255}
    -- @field thistle {r=216,g=191,b=216,a=255}
    -- @field orchid {r=218,g=112,b=214,a=255}
    -- @field goldenrod {r=218,g=165,b=32,a=255}
    -- @field crimson {r=220,g=20,b=60,a=255}
    -- @field gainsboro {r=220,g=220,b=220,a=255}
    -- @field plum {r=221,g=160,b=221,a=255}
    -- @field burlywood {r=222,g=184,b=135,a=255}
    -- @field lightcyan {r=224,g=255,b=255,a=255}
    -- @field lavender {r=230,g=230,b=250,a=255}
    -- @field darksalmon {r=233,g=150,b=122,a=255}
    -- @field violet {r=238,g=130,b=238,a=255}
    -- @field palegoldenrod {r=238,g=232,b=170,a=255}
    -- @field lightcoral {r=240,g=128,b=128,a=255}
    -- @field khaki {r=240,g=230,b=140,a=255}
    -- @field aliceblue {r=240,g=248,b=255,a=255}
    -- @field honeydew {r=240,g=255,b=240,a=255}
    -- @field azure {r=240,g=255,b=255,a=255}
    -- @field sandybrown {r=244,g=164,b=96,a=255}
    -- @field wheat {r=245,g=222,b=179,a=255}
    -- @field beige {r=245,g=245,b=220,a=255}
    -- @field whitesmoke {r=245,g=245,b=245,a=255}
    -- @field mintcream {r=245,g=255,b=250,a=255}
    -- @field ghostwhite {r=248,g=248,b=255,a=255}
    -- @field salmon {r=250,g=128,b=114,a=255}
    -- @field antiquewhite {r=250,g=235,b=215,a=255}
    -- @field linen {r=250,g=240,b=230,a=255}
    -- @field lightgoldenrodyellow {r=250,g=250,b=210,a=255}
    -- @field oldlace {r=253,g=245,b=230,a=255}
    -- @field red {r=255,g=0,b=0,a=255}
    -- @field fuchsia {r=255,g=0,b=255,a=255}
    -- @field magenta {r=255,g=0,b=255,a=255}
    -- @field deeppink {r=255,g=20,b=147,a=255}
    -- @field orangered {r=255,g=69,b=0,a=255}
    -- @field tomato {r=255,g=99,b=71,a=255}
    -- @field hotpink {r=255,g=105,b=180,a=255}
    -- @field coral {r=255,g=127,b=80,a=255}
    -- @field darkorange {r=255,g=140,b=0,a=255}
    -- @field lightsalmon {r=255,g=160,b=122,a=255}
    -- @field orange {r=255,g=165,b=0,a=255}
    -- @field lightpink {r=255,g=182,b=193,a=255}
    -- @field pink {r=255,g=192,b=203,a=255}
    -- @field gold {r=255,g=215,b=0,a=255}
    -- @field peachpuff {r=255,g=218,b=185,a=255}
    -- @field navajowhite {r=255,g=222,b=173,a=255}
    -- @field moccasin {r=255,g=228,b=181,a=255}
    -- @field bisque {r=255,g=228,b=196,a=255}
    -- @field mistyrose {r=255,g=228,b=225,a=255}
    -- @field blanchedalmond {r=255,g=235,b=205,a=255}
    -- @field papayawhip {r=255,g=239,b=213,a=255}
    -- @field lavenderblush {r=255,g=240,b=245,a=255}
    -- @field seashell {r=255,g=245,b=238,a=255}
    -- @field cornsilk {r=255,g=248,b=220,a=255}
    -- @field lemonchiffon {r=255,g=250,b=205,a=255}
    -- @field floralwhite {r=255,g=250,b=240,a=255}
    -- @field snow {r=255,g=250,b=250,a=255}
    -- @field yellow {r=255,g=255,b=0,a=255}
    -- @field lightyellow {r=255,g=255,b=224,a=255}
    -- @field ivory {r=255,g=255,b=240,a=255}
    -- @field white {r=255,g=255,b=255,a=255}
    -- @table Color._cache
