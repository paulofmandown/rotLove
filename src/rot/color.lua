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
-- @tparam string str Accepted formats 'rgb(0..1, 0..1, 0..1)', '#5fe', '#5FE', '#254eff', 'goldenrod'
function Color.fromString(str)
    local cached = Color._cached[str]
    if cached then return cached end
    local values = { 0, 0, 0 }
    if str:sub(1,1) == '#' then
        local j=1
        for s in str:gmatch('[%da-fA-F]') do
            values[j]=tonumber(s, 16)
            j=j+1
        end
        if #values==3 then
            for i=1,3 do values[i]=values[i]*17 / 255 end
        else
            for i=1, 3 do
                values[i+1]=values[i+1]+(16*values[i]) / 255
                table.remove(values, i)
            end
        end
    elseif str:gmatch('rgb') then
        local i=1
        for s in str:gmatch('(%d*%.?%d+)') do
            values[i]=tonumber(s)
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
        t[i] = ((t[i] or 1.0) * color[i])
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
        result[i] = (b + factor*(a-b) + 0.005)
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
        local r = rng:random(0, diff * 100) / 100
        for i = 1, #color do
            result[i] = color[i] + r
        end
    else
        for i = 1, #color do
            result[i] = color[i] + rng:random(0, diff[i] * 100) / 100
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

    return { math.floor(h+0.005), math.floor(s+0.005), math.floor(l+0.005), math.floor(a+0.005) }
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
    result[4] = (color[4])
    if s == 0 then
        local value = (l + 0.005)
        for i = 1, 3 do
            result[i] = value
        end
    else
        local q=l<.5 and l*(1+s) or l+s-l*s
        local p=2*l-q
        result[1] = math.floor(hue2rgb(p,q,h+1/3)*255 + 0.5) / 256
        result[2] = math.floor(hue2rgb(p,q,h)*255 + 0.5) / 256
        result[3] = math.floor(hue2rgb(p,q,h-1/3)*255 + 0.5) / 256
    end
    return result
end

--- Convert color to RGB string.
-- Get a string that can be fed to Color.fromString()
-- @tparam table color A color table
function Color.toRGB(color)
    return ('rgb(%f,%f,%f)'):format(
        Color._clamp(color[1]), Color._clamp(color[2]), Color._clamp(color[3]))
end

--- Convert color to Hex string
-- Get a string that can be fed to Color.fromString()
-- @tparam table color A color table
function Color.toHex(color)
    return ('#%02x%02x%02x'):format(
        Color._clamp(color[1]) * 255, Color._clamp(color[2]) * 255, Color._clamp(color[3]) * 255)
end

-- limit a number to 0..1
function Color._clamp(n)
    return n<0 and 0 or n>1.0 and 1.0 or n
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
    black= { 0.000, 0.000, 0.000 },
    navy= { 0.000, 0.000, 0.502 },
    darkblue= { 0.000, 0.000, 0.545 },
    mediumblue= { 0.000, 0.000, 0.804 },
    blue= { 0.000, 0.000, 1.000 },
    darkgreen= { 0.000, 0.392, 0.000 },
    green= { 0.000, 0.502, 0.000 },
    teal= { 0.000, 0.502, 0.502 },
    darkcyan= { 0.000, 0.545, 0.545 },
    deepskyblue= { 0.000, 0.749, 1.000 },
    darkturquoise= { 0.000, 0.808, 0.820 },
    mediumspringgreen= { 0.000, 0.980, 0.604 },
    lime= { 0.000, 1.000, 0.000 },
    springgreen= { 0.000, 1.000, 0.498 },
    aqua= { 0.000, 1.000, 1.000 },
    cyan= { 0.000, 1.000, 1.000 },
    midnightblue= { 0.098, 0.098, 0.439 },
    dodgerblue= { 0.118, 0.565, 1.000 },
    forestgreen= { 0.133, 0.545, 0.133 },
    seagreen= { 0.180, 0.545, 0.341 },
    darkslategray= { 0.184, 0.310, 0.310 },
    darkslategrey= { 0.184, 0.310, 0.310 },
    limegreen= { 0.196, 0.804, 0.196 },
    mediumseagreen= { 0.235, 0.702, 0.443 },
    turquoise= { 0.251, 0.878, 0.816 },
    royalblue= { 0.255, 0.412, 0.882 },
    steelblue= { 0.275, 0.510, 0.706 },
    darkslateblue= { 0.282, 0.239, 0.545 },
    mediumturquoise= { 0.282, 0.820, 0.800 },
    indigo= { 0.294, 0.000, 0.510 },
    darkolivegreen= { 0.333, 0.420, 0.184 },
    cadetblue= { 0.373, 0.620, 0.627 },
    cornflowerblue= { 0.392, 0.584, 0.929 },
    mediumaquamarine= { 0.400, 0.804, 0.667 },
    dimgray= { 0.412, 0.412, 0.412 },
    dimgrey= { 0.412, 0.412, 0.412 },
    slateblue= { 0.416, 0.353, 0.804 },
    olivedrab= { 0.420, 0.557, 0.137 },
    slategray= { 0.439, 0.502, 0.565 },
    slategrey= { 0.439, 0.502, 0.565 },
    lightslategray= { 0.467, 0.533, 0.600 },
    lightslategrey= { 0.467, 0.533, 0.600 },
    mediumslateblue= { 0.482, 0.408, 0.933 },
    lawngreen= { 0.486, 0.988, 0.000 },
    chartreuse= { 0.498, 1.000, 0.000 },
    aquamarine= { 0.498, 1.000, 0.831 },
    maroon= { 0.502, 0.000, 0.000 },
    purple= { 0.502, 0.000, 0.502 },
    olive= { 0.502, 0.502, 0.000 },
    gray= { 0.502, 0.502, 0.502 },
    grey= { 0.502, 0.502, 0.502 },
    skyblue= { 0.529, 0.808, 0.922 },
    lightskyblue= { 0.529, 0.808, 0.980 },
    blueviolet= { 0.541, 0.169, 0.886 },
    darkred= { 0.545, 0.000, 0.000 },
    darkmagenta= { 0.545, 0.000, 0.545 },
    saddlebrown= { 0.545, 0.271, 0.075 },
    darkseagreen= { 0.561, 0.737, 0.561 },
    lightgreen= { 0.565, 0.933, 0.565 },
    mediumpurple= { 0.576, 0.439, 0.847 },
    darkviolet= { 0.580, 0.000, 0.827 },
    palegreen= { 0.596, 0.984, 0.596 },
    darkorchid= { 0.600, 0.196, 0.800 },
    yellowgreen= { 0.604, 0.804, 0.196 },
    sienna= { 0.627, 0.322, 0.176 },
    brown= { 0.647, 0.165, 0.165 },
    darkgray= { 0.663, 0.663, 0.663 },
    darkgrey= { 0.663, 0.663, 0.663 },
    lightblue= { 0.678, 0.847, 0.902 },
    greenyellow= { 0.678, 1.000, 0.184 },
    paleturquoise= { 0.686, 0.933, 0.933 },
    lightsteelblue= { 0.690, 0.769, 0.871 },
    powderblue= { 0.690, 0.878, 0.902 },
    firebrick= { 0.698, 0.133, 0.133 },
    darkgoldenrod= { 0.722, 0.525, 0.043 },
    mediumorchid= { 0.729, 0.333, 0.827 },
    rosybrown= { 0.737, 0.561, 0.561 },
    darkkhaki= { 0.741, 0.718, 0.420 },
    silver= { 0.753, 0.753, 0.753 },
    mediumvioletred= { 0.780, 0.082, 0.522 },
    indianred= { 0.804, 0.361, 0.361 },
    peru= { 0.804, 0.522, 0.247 },
    chocolate= { 0.824, 0.412, 0.118 },
    tan= { 0.824, 0.706, 0.549 },
    lightgray= { 0.827, 0.827, 0.827 },
    lightgrey= { 0.827, 0.827, 0.827 },
    palevioletred= { 0.847, 0.439, 0.576 },
    thistle= { 0.847, 0.749, 0.847 },
    orchid= { 0.855, 0.439, 0.839 },
    goldenrod= { 0.855, 0.647, 0.125 },
    crimson= { 0.863, 0.078, 0.235 },
    gainsboro= { 0.863, 0.863, 0.863 },
    plum= { 0.867, 0.627, 0.867 },
    burlywood= { 0.871, 0.722, 0.529 },
    lightcyan= { 0.878, 1.000, 1.000 },
    lavender= { 0.902, 0.902, 0.980 },
    darksalmon= { 0.914, 0.588, 0.478 },
    violet= { 0.933, 0.510, 0.933 },
    palegoldenrod= { 0.933, 0.910, 0.667 },
    lightcoral= { 0.941, 0.502, 0.502 },
    khaki= { 0.941, 0.902, 0.549 },
    aliceblue= { 0.941, 0.973, 1.000 },
    honeydew= { 0.941, 1.000, 0.941 },
    azure= { 0.941, 1.000, 1.000 },
    sandybrown= { 0.957, 0.643, 0.376 },
    wheat= { 0.961, 0.871, 0.702 },
    beige= { 0.961, 0.961, 0.863 },
    whitesmoke= { 0.961, 0.961, 0.961 },
    mintcream= { 0.961, 1.000, 0.980 },
    ghostwhite= { 0.973, 0.973, 1.000 },
    salmon= { 0.980, 0.502, 0.447 },
    antiquewhite= { 0.980, 0.922, 0.843 },
    linen= { 0.980, 0.941, 0.902 },
    lightgoldenrodyellow= { 0.980, 0.980, 0.824 },
    oldlace= { 0.992, 0.961, 0.902 },
    red= { 1.000, 0.000, 0.000 },
    fuchsia= { 1.000, 0.000, 1.000 },
    magenta= { 1.000, 0.000, 1.000 },
    deeppink= { 1.000, 0.078, 0.576 },
    orangered= { 1.000, 0.271, 0.000 },
    tomato= { 1.000, 0.388, 0.278 },
    hotpink= { 1.000, 0.412, 0.706 },
    coral= { 1.000, 0.498, 0.314 },
    darkorange= { 1.000, 0.549, 0.000 },
    lightsalmon= { 1.000, 0.627, 0.478 },
    orange= { 1.000, 0.647, 0.000 },
    lightpink= { 1.000, 0.714, 0.757 },
    pink= { 1.000, 0.753, 0.796 },
    gold= { 1.000, 0.843, 0.000 },
    peachpuff= { 1.000, 0.855, 0.725 },
    navajowhite= { 1.000, 0.871, 0.678 },
    moccasin= { 1.000, 0.894, 0.710 },
    bisque= { 1.000, 0.894, 0.769 },
    mistyrose= { 1.000, 0.894, 0.882 },
    blanchedalmond= { 1.000, 0.922, 0.804 },
    papayawhip= { 1.000, 0.937, 0.835 },
    lavenderblush= { 1.000, 0.941, 0.961 },
    seashell= { 1.000, 0.961, 0.933 },
    cornsilk= { 1.000, 0.973, 0.863 },
    lemonchiffon= { 1.000, 0.980, 0.804 },
    floralwhite= { 1.000, 0.980, 0.941 },
    snow= { 1.000, 0.980, 0.980 },
    yellow= { 1.000, 1.000, 0.000 },
    lightyellow= { 1.000, 1.000, 0.878 },
    ivory= { 1.000, 1.000, 0.941 },
    white= { 1.000, 1.000, 1.000 }
}

return Color

