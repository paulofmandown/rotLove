--- The Color Toolkit.
-- Color is a color handler that treats any
-- objects intended to represent a color as a
-- table of the following schema:
-- @module ROT.Color

local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Color = ROT.Class:extend("Color")

function Color:init(r, g, b, a)
    self[1], self[2], self[3], self[4] = r or 0, g or 0, b or 0, a
end

--- Get color from string.
-- Convert one of several formats of string to what
-- Color interperets as a color object
-- @tparam string str Accepted formats 'rgb(0..255, 0..255, 0..255)', '#5fe', '#5FE', '#254eff', 'goldenrod'
function Color.fromString(str)
    local cached = Color._cached[str]
    if cached then return cached end
    local values = { 0, 0, 0 }
    if str:sub(1,1) == '#' then
        local i=1
        for s in str:gmatch('[%da-fA-F]') do
            values[i]=tonumber(s, 16) / 255
            i=i+1
        end
        if #values==3 then
            for i=1,3 do values[i]=values[i]*17 end
        else
            for i=1, 3 do
                values[i+1]=values[i+1]+(16*values[i])
                table.remove(values, i)
            end
        end
    elseif str:gmatch('rgb') then
        local i=1
        for s in str:gmatch('(%d+)') do
            values[i]=tonumber(s) / 255
            i=i+1
        end
    end
    Color._cached[str] = values
    return values
end

local function add(t, color, ...)
    if not color then return t end
    for i = 1, #color do
        t[i] = (t[i] or 0) + color[i]
    end
    return add(t, ...)
end

local function multiply(t, color, ...)
    if not color then return t end
    for i = 1, #color do
        t[i] = (t[i] or 1) * color[i]
    end
    return multiply(t, ...)
end

--- Add two or more colors.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam table ... More color tables
-- @treturn table new color
function Color.add(...) return add({}, ...) end

--- Add two or more colors. Modifies first color in-place.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam table ... More color tables
-- @treturn table modified color
function Color.add_(...) return add(...) end

-- Multiply (mix) two or more colors.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam table ... More color tables
-- @treturn table new color
function Color.multiply(...) return multiply({}, ...) end

-- Multiply (mix) two or more colors. Modifies first color in-place.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam table ... More color tables
-- @treturn table modified color
function Color.multiply_(...) return multiply(...) end

--- Interpolate (blend) two colors with a given factor.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam float factor A number from 0 to 1. <0.5 favors color1, >0.5 favors color2.
-- @treturn table resulting color
function Color.interpolate(color1, color2, factor)
    factor = factor or .5
    local result = {}
    for i = 1, math.max(#color1, #color2) do
        local a, b = color2[i] or color1[i], color1[i] or color2[i]
        result[i] = b + factor*(a-b)
    end
    return result
end

--- Interpolate (blend) two colors with a given factor in HSL mode.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam float factor A number from 0 to 1. <0.5 favors color1, >0.5 favors color2.
-- @treturn table resulting color
function Color.interpolateHSL(color1, color2, factor)
    factor = factor or .5
    local result = {}
    local hsl1, hsl2 = Color.rgb2hsl(color1), Color.rgb2hsl(color2)
    for i = 1, math.max(#hsl1, #hsl2) do
        local a, b = hsl2[i] or hsl1[i], hsl1[i] or hsl2[i]
        result[i] = b + factor*(a-b)
    end
    return Color.hsl2rgb(result)
end

--- Create a new random color based on this one
-- @tparam table color A color table
-- @tparam int|table diff One or more numbers to use for a standard deviation
function Color.randomize(color, diff, rng)
    rng = rng or color._rng or ROT.RNG
    local result = {}
    if type(diff) ~= 'table' then
        local diff = rng:random(0, diff)
        for i = 1, #color do
            result[i] = color[i] + diff
        end
    else
        for i = 1, #color do
            result[i] = color[i] + rng:random(0, diff[i])
        end
    end
    return result
end

-- Convert rgb color to hsl
function Color.rgb2hsl(color)
    local r=color[1]
    local g=color[2]
    local b=color[3]
    local a=color[4] and color[4]
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

    return { h, s, l, a }
end

local function hue2rgb(p, q, t)
    if t<0 then t=t+1 end
    if t>1 then t=t-1 end
    if t<1/6 then return (p+(q-p)*6*t) end
    if t<1/2 then return q end
    if t<2/3 then return (p+(q-p)*(2/3-t)*6) end
    return p
end

-- Convert hsl color to rgb
function Color.hsl2rgb(color)
    local h, s, l = color[1], color[2], color[3]
    local result = {}
    result[4] = color[4] and color[4]
    if s == 0 then
        local value = l
        for i = 1, 3 do
            result[i] = value
        end
    else
        local q=l<.5 and l*(1+s) or l+s-l*s
        local p=2*l-q
        result[1] = hue2rgb(p,q,h+1/3)
        result[2] = hue2rgb(p,q,h)
        result[3] = hue2rgb(p,q,h-1/3)
    end
    return result
end

--- Convert color to RGB string.
-- Get a string that can be fed to Color.fromString()
-- @tparam table color A color table
function Color.toRGB(color)
    return ('rgb(%d,%d,%d)'):format(
        Color._clamp(color[1]), Color._clamp(color[2]), Color._clamp(color[3]))
end

--- Convert color to Hex string
-- Get a string that can be fed to Color.fromString()
-- @tparam table color A color table
function Color.toHex(color)
    return ('#%02x%02x%02x'):format(
        Color._clamp(color[1]), Color._clamp(color[2]), Color._clamp(color[3]))
end

-- limit a number to 0..1
function Color._clamp(n)
    return n<0 and 0 or n>1 and 1 or n
end

function Color.__add(a, b) return add({}, a, b) end
function Color.__mul(a, b) return mul({}, a, b) end

--- Color cache
-- A table of predefined color tables
-- These keys can be passed to Color.fromString()
-- @field black { 0/255, 0/255, 0/255 }
-- @field navy { 0/255, 0/255, 128/255 }
-- @field darkblue { 0/255, 0/255, 139/255 }
-- @field mediumblue { 0/255, 0/255, 205/255 }
-- @field blue { 0/255, 0/255, 255/255 }
-- @field darkgreen { 0/255, 100/255, 0/255 }
-- @field green { 0/255, 128/255, 0/255 }
-- @field teal { 0/255, 128/255, 128/255 }
-- @field darkcyan { 0/255, 139/255, 139/255 }
-- @field deepskyblue { 0/255, 191/255, 255/255 }
-- @field darkturquoise { 0/255, 206/255, 209/255 }
-- @field mediumspringgreen { 0/255, 250/255, 154/255 }
-- @field lime { 0/255, 255/255, 0/255 }
-- @field springgreen { 0/255, 255/255, 127/255 }
-- @field aqua { 0/255, 255/255, 255/255 }
-- @field cyan { 0/255, 255/255, 255/255 }
-- @field midnightblue { 25/255, 25/255, 112/255 }
-- @field dodgerblue { 30/255, 144/255, 255/255 }
-- @field forestgreen { 34/255, 139/255, 34/255 }
-- @field seagreen { 46/255, 139/255, 87/255 }
-- @field darkslategray { 47/255, 79/255, 79/255 }
-- @field darkslategrey { 47/255, 79/255, 79/255 }
-- @field limegreen { 50/255, 205/255, 50/255 }
-- @field mediumseagreen { 60/255, 179/255, 113/255 }
-- @field turquoise { 64/255, 224/255, 208/255 }
-- @field royalblue { 65/255, 105/255, 225/255 }
-- @field steelblue { 70/255, 130/255, 180/255 }
-- @field darkslateblue { 72/255, 61/255, 139/255 }
-- @field mediumturquoise { 72/255, 209/255, 204/255 }
-- @field indigo { 75/255, 0/255, 130/255 }
-- @field darkolivegreen { 85/255, 107/255, 47/255 }
-- @field cadetblue { 95/255, 158/255, 160/255 }
-- @field cornflowerblue { 100/255, 149/255, 237/255 }
-- @field mediumaquamarine { 102/255, 205/255, 170/255 }
-- @field dimgray { 105/255, 105/255, 105/255 }
-- @field dimgrey { 105/255, 105/255, 105/255 }
-- @field slateblue { 106/255, 90/255, 205/255 }
-- @field olivedrab { 107/255, 142/255, 35/255 }
-- @field slategray { 112/255, 128/255, 144/255 }
-- @field slategrey { 112/255, 128/255, 144/255 }
-- @field lightslategray { 119/255, 136/255, 153/255 }
-- @field lightslategrey { 119/255, 136/255, 153/255 }
-- @field mediumslateblue { 123/255, 104/255, 238/255 }
-- @field lawngreen { 124/255, 252/255, 0/255 }
-- @field chartreuse { 127/255, 255/255, 0/255 }
-- @field aquamarine { 127/255, 255/255, 212/255 }
-- @field maroon { 128/255, 0/255, 0/255 }
-- @field purple { 128/255, 0/255, 128/255 }
-- @field olive { 128/255, 128/255, 0/255 }
-- @field gray { 128/255, 128/255, 128/255 }
-- @field grey { 128/255, 128/255, 128/255 }
-- @field skyblue { 135/255, 206/255, 235/255 }
-- @field lightskyblue { 135/255, 206/255, 250/255 }
-- @field blueviolet { 138/255, 43/255, 226/255 }
-- @field darkred { 139/255, 0/255, 0/255 }
-- @field darkmagenta { 139/255, 0/255, 139/255 }
-- @field saddlebrown { 139/255, 69/255, 19/255 }
-- @field darkseagreen { 143/255, 188/255, 143/255 }
-- @field lightgreen { 144/255, 238/255, 144/255 }
-- @field mediumpurple { 147/255, 112/255, 216/255 }
-- @field darkviolet { 148/255, 0/255, 211/255 }
-- @field palegreen { 152/255, 251/255, 152/255 }
-- @field darkorchid { 153/255, 50/255, 204/255 }
-- @field yellowgreen { 154/255, 205/255, 50/255 }
-- @field sienna { 160/255, 82/255, 45/255 }
-- @field brown { 165/255, 42/255, 42/255 }
-- @field darkgray { 169/255, 169/255, 169/255 }
-- @field darkgrey { 169/255, 169/255, 169/255 }
-- @field lightblue { 173/255, 216/255, 230/255 }
-- @field greenyellow { 173/255, 255/255, 47/255 }
-- @field paleturquoise { 175/255, 238/255, 238/255 }
-- @field lightsteelblue { 176/255, 196/255, 222/255 }
-- @field powderblue { 176/255, 224/255, 230/255 }
-- @field firebrick { 178/255, 34/255, 34/255 }
-- @field darkgoldenrod { 184/255, 134/255, 11/255 }
-- @field mediumorchid { 186/255, 85/255, 211/255 }
-- @field rosybrown { 188/255, 143/255, 143/255 }
-- @field darkkhaki { 189/255, 183/255, 107/255 }
-- @field silver { 192/255, 192/255, 192/255 }
-- @field mediumvioletred { 199/255, 21/255, 133/255 }
-- @field indianred { 205/255, 92/255, 92/255 }
-- @field peru { 205/255, 133/255, 63/255 }
-- @field chocolate { 210/255, 105/255, 30/255 }
-- @field tan { 210/255, 180/255, 140/255 }
-- @field lightgray { 211/255, 211/255, 211/255 }
-- @field lightgrey { 211/255, 211/255, 211/255 }
-- @field palevioletred { 216/255, 112/255, 147/255 }
-- @field thistle { 216/255, 191/255, 216/255 }
-- @field orchid { 218/255, 112/255, 214/255 }
-- @field goldenrod { 218/255, 165/255, 32/255 }
-- @field crimson { 220/255, 20/255, 60/255 }
-- @field gainsboro { 220/255, 220/255, 220/255 }
-- @field plum { 221/255, 160/255, 221/255 }
-- @field burlywood { 222/255, 184/255, 135/255 }
-- @field lightcyan { 224/255, 255/255, 255/255 }
-- @field lavender { 230/255, 230/255, 250/255 }
-- @field darksalmon { 233/255, 150/255, 122/255 }
-- @field violet { 238/255, 130/255, 238/255 }
-- @field palegoldenrod { 238/255, 232/255, 170/255 }
-- @field lightcoral { 240/255, 128/255, 128/255 }
-- @field khaki { 240/255, 230/255, 140/255 }
-- @field aliceblue { 240/255, 248/255, 255/255 }
-- @field honeydew { 240/255, 255/255, 240/255 }
-- @field azure { 240/255, 255/255, 255/255 }
-- @field sandybrown { 244/255, 164/255, 96/255 }
-- @field wheat { 245/255, 222/255, 179/255 }
-- @field beige { 245/255, 245/255, 220/255 }
-- @field whitesmoke { 245/255, 245/255, 245/255 }
-- @field mintcream { 245/255, 255/255, 250/255 }
-- @field ghostwhite { 248/255, 248/255, 255/255 }
-- @field salmon { 250/255, 128/255, 114/255 }
-- @field antiquewhite { 250/255, 235/255, 215/255 }
-- @field linen { 250/255, 240/255, 230/255 }
-- @field lightgoldenrodyellow { 250/255, 250/255, 210/255 }
-- @field oldlace { 253/255, 245/255, 230/255 }
-- @field red { 255/255, 0/255, 0/255 }
-- @field fuchsia { 255/255, 0/255, 255/255 }
-- @field magenta { 255/255, 0/255, 255/255 }
-- @field deeppink { 255/255, 20/255, 147/255 }
-- @field orangered { 255/255, 69/255, 0/255 }
-- @field tomato { 255/255, 99/255, 71/255 }
-- @field hotpink { 255/255, 105/255, 180/255 }
-- @field coral { 255/255, 127/255, 80/255 }
-- @field darkorange { 255/255, 140/255, 0/255 }
-- @field lightsalmon { 255/255, 160/255, 122/255 }
-- @field orange { 255/255, 165/255, 0/255 }
-- @field lightpink { 255/255, 182/255, 193/255 }
-- @field pink { 255/255, 192/255, 203/255 }
-- @field gold { 255/255, 215/255, 0/255 }
-- @field peachpuff { 255/255, 218/255, 185/255 }
-- @field navajowhite { 255/255, 222/255, 173/255 }
-- @field moccasin { 255/255, 228/255, 181/255 }
-- @field bisque { 255/255, 228/255, 196/255 }
-- @field mistyrose { 255/255, 228/255, 225/255 }
-- @field blanchedalmond { 255/255, 235/255, 205/255 }
-- @field papayawhip { 255/255, 239/255, 213/255 }
-- @field lavenderblush { 255/255, 240/255, 245/255 }
-- @field seashell { 255/255, 245/255, 238/255 }
-- @field cornsilk { 255/255, 248/255, 220/255 }
-- @field lemonchiffon { 255/255, 250/255, 205/255 }
-- @field floralwhite { 255/255, 250/255, 240/255 }
-- @field snow { 255/255, 250/255, 250/255 }
-- @field yellow { 255/255, 255/255, 0/255 }
-- @field lightyellow { 255/255, 255/255, 224/255 }
-- @field ivory { 255/255, 255/255, 240/255 }
-- @field white { 255/255, 255/255, 255/255 }
-- @table Color._cache

Color._cached={
    black= { 0/255, 0/255, 0/255 },
    navy= { 0/255, 0/255, 128/255 },
    darkblue= { 0/255, 0/255, 139/255 },
    mediumblue= { 0/255, 0/255, 205/255 },
    blue= { 0/255, 0/255, 255/255 },
    darkgreen= { 0/255, 100/255, 0/255 },
    green= { 0/255, 128/255, 0/255 },
    teal= { 0/255, 128/255, 128/255 },
    darkcyan= { 0/255, 139/255, 139/255 },
    deepskyblue= { 0/255, 191/255, 255/255 },
    darkturquoise= { 0/255, 206/255, 209/255 },
    mediumspringgreen= { 0/255, 250/255, 154/255 },
    lime= { 0/255, 255/255, 0/255 },
    springgreen= { 0/255, 255/255, 127/255 },
    aqua= { 0/255, 255/255, 255/255 },
    cyan= { 0/255, 255/255, 255/255 },
    midnightblue= { 25/255, 25/255, 112/255 },
    dodgerblue= { 30/255, 144/255, 255/255 },
    forestgreen= { 34/255, 139/255, 34/255 },
    seagreen= { 46/255, 139/255, 87/255 },
    darkslategray= { 47/255, 79/255, 79/255 },
    darkslategrey= { 47/255, 79/255, 79/255 },
    limegreen= { 50/255, 205/255, 50/255 },
    mediumseagreen= { 60/255, 179/255, 113/255 },
    turquoise= { 64/255, 224/255, 208/255 },
    royalblue= { 65/255, 105/255, 225/255 },
    steelblue= { 70/255, 130/255, 180/255 },
    darkslateblue= { 72/255, 61/255, 139/255 },
    mediumturquoise= { 72/255, 209/255, 204/255 },
    indigo= { 75/255, 0/255, 130/255 },
    darkolivegreen= { 85/255, 107/255, 47/255 },
    cadetblue= { 95/255, 158/255, 160/255 },
    cornflowerblue= { 100/255, 149/255, 237/255 },
    mediumaquamarine= { 102/255, 205/255, 170/255 },
    dimgray= { 105/255, 105/255, 105/255 },
    dimgrey= { 105/255, 105/255, 105/255 },
    slateblue= { 106/255, 90/255, 205/255 },
    olivedrab= { 107/255, 142/255, 35/255 },
    slategray= { 112/255, 128/255, 144/255 },
    slategrey= { 112/255, 128/255, 144/255 },
    lightslategray= { 119/255, 136/255, 153/255 },
    lightslategrey= { 119/255, 136/255, 153/255 },
    mediumslateblue= { 123/255, 104/255, 238/255 },
    lawngreen= { 124/255, 252/255, 0/255 },
    chartreuse= { 127/255, 255/255, 0/255 },
    aquamarine= { 127/255, 255/255, 212/255 },
    maroon= { 128/255, 0/255, 0/255 },
    purple= { 128/255, 0/255, 128/255 },
    olive= { 128/255, 128/255, 0/255 },
    gray= { 128/255, 128/255, 128/255 },
    grey= { 128/255, 128/255, 128/255 },
    skyblue= { 135/255, 206/255, 235/255 },
    lightskyblue= { 135/255, 206/255, 250/255 },
    blueviolet= { 138/255, 43/255, 226/255 },
    darkred= { 139/255, 0/255, 0/255 },
    darkmagenta= { 139/255, 0/255, 139/255 },
    saddlebrown= { 139/255, 69/255, 19/255 },
    darkseagreen= { 143/255, 188/255, 143/255 },
    lightgreen= { 144/255, 238/255, 144/255 },
    mediumpurple= { 147/255, 112/255, 216/255 },
    darkviolet= { 148/255, 0/255, 211/255 },
    palegreen= { 152/255, 251/255, 152/255 },
    darkorchid= { 153/255, 50/255, 204/255 },
    yellowgreen= { 154/255, 205/255, 50/255 },
    sienna= { 160/255, 82/255, 45/255 },
    brown= { 165/255, 42/255, 42/255 },
    darkgray= { 169/255, 169/255, 169/255 },
    darkgrey= { 169/255, 169/255, 169/255 },
    lightblue= { 173/255, 216/255, 230/255 },
    greenyellow= { 173/255, 255/255, 47/255 },
    paleturquoise= { 175/255, 238/255, 238/255 },
    lightsteelblue= { 176/255, 196/255, 222/255 },
    powderblue= { 176/255, 224/255, 230/255 },
    firebrick= { 178/255, 34/255, 34/255 },
    darkgoldenrod= { 184/255, 134/255, 11/255 },
    mediumorchid= { 186/255, 85/255, 211/255 },
    rosybrown= { 188/255, 143/255, 143/255 },
    darkkhaki= { 189/255, 183/255, 107/255 },
    silver= { 192/255, 192/255, 192/255 },
    mediumvioletred= { 199/255, 21/255, 133/255 },
    indianred= { 205/255, 92/255, 92/255 },
    peru= { 205/255, 133/255, 63/255 },
    chocolate= { 210/255, 105/255, 30/255 },
    tan= { 210/255, 180/255, 140/255 },
    lightgray= { 211/255, 211/255, 211/255 },
    lightgrey= { 211/255, 211/255, 211/255 },
    palevioletred= { 216/255, 112/255, 147/255 },
    thistle= { 216/255, 191/255, 216/255 },
    orchid= { 218/255, 112/255, 214/255 },
    goldenrod= { 218/255, 165/255, 32/255 },
    crimson= { 220/255, 20/255, 60/255 },
    gainsboro= { 220/255, 220/255, 220/255 },
    plum= { 221/255, 160/255, 221/255 },
    burlywood= { 222/255, 184/255, 135/255 },
    lightcyan= { 224/255, 255/255, 255/255 },
    lavender= { 230/255, 230/255, 250/255 },
    darksalmon= { 233/255, 150/255, 122/255 },
    violet= { 238/255, 130/255, 238/255 },
    palegoldenrod= { 238/255, 232/255, 170/255 },
    lightcoral= { 240/255, 128/255, 128/255 },
    khaki= { 240/255, 230/255, 140/255 },
    aliceblue= { 240/255, 248/255, 255/255 },
    honeydew= { 240/255, 255/255, 240/255 },
    azure= { 240/255, 255/255, 255/255 },
    sandybrown= { 244/255, 164/255, 96/255 },
    wheat= { 245/255, 222/255, 179/255 },
    beige= { 245/255, 245/255, 220/255 },
    whitesmoke= { 245/255, 245/255, 245/255 },
    mintcream= { 245/255, 255/255, 250/255 },
    ghostwhite= { 248/255, 248/255, 255/255 },
    salmon= { 250/255, 128/255, 114/255 },
    antiquewhite= { 250/255, 235/255, 215/255 },
    linen= { 250/255, 240/255, 230/255 },
    lightgoldenrodyellow= { 250/255, 250/255, 210/255 },
    oldlace= { 253/255, 245/255, 230/255 },
    red= { 255/255, 0/255, 0/255 },
    fuchsia= { 255/255, 0/255, 255/255 },
    magenta= { 255/255, 0/255, 255/255 },
    deeppink= { 255/255, 20/255, 147/255 },
    orangered= { 255/255, 69/255, 0/255 },
    tomato= { 255/255, 99/255, 71/255 },
    hotpink= { 255/255, 105/255, 180/255 },
    coral= { 255/255, 127/255, 80/255 },
    darkorange= { 255/255, 140/255, 0/255 },
    lightsalmon= { 255/255, 160/255, 122/255 },
    orange= { 255/255, 165/255, 0/255 },
    lightpink= { 255/255, 182/255, 193/255 },
    pink= { 255/255, 192/255, 203/255 },
    gold= { 255/255, 215/255, 0/255 },
    peachpuff= { 255/255, 218/255, 185/255 },
    navajowhite= { 255/255, 222/255, 173/255 },
    moccasin= { 255/255, 228/255, 181/255 },
    bisque= { 255/255, 228/255, 196/255 },
    mistyrose= { 255/255, 228/255, 225/255 },
    blanchedalmond= { 255/255, 235/255, 205/255 },
    papayawhip= { 255/255, 239/255, 213/255 },
    lavenderblush= { 255/255, 240/255, 245/255 },
    seashell= { 255/255, 245/255, 238/255 },
    cornsilk= { 255/255, 248/255, 220/255 },
    lemonchiffon= { 255/255, 250/255, 205/255 },
    floralwhite= { 255/255, 250/255, 240/255 },
    snow= { 255/255, 250/255, 250/255 },
    yellow= { 255/255, 255/255, 0/255 },
    lightyellow= { 255/255, 255/255, 224/255 },
    ivory= { 255/255, 255/255, 240/255 },
    white= { 255/255, 255/255, 255/255 }
}

return Color

