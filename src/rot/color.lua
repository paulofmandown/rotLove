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
    local r=color[1]/255
    local g=color[2]/255
    local b=color[3]/255
    local a=color[4] and color[4]/255
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

-- limit a number to 0..255
function Color._clamp(n)
    return n<0 and 0 or n>1.0 and 1.0 or n
end

function Color.__add(a, b) return add({}, a, b) end
function Color.__mul(a, b) return mul({}, a, b) end

--- Color cache
-- A table of predefined color tables
-- These keys can be passed to Color.fromString()
-- @field black { 0, 0, 0 }
-- @field navy { 0, 0, 128 }
-- @field darkblue { 0, 0, 139 }
-- @field mediumblue { 0, 0, 205 }
-- @field blue { 0, 0, 255 }
-- @field darkgreen { 0, 100, 0 }
-- @field green { 0, 128, 0 }
-- @field teal { 0, 128, 128 }
-- @field darkcyan { 0, 139, 139 }
-- @field deepskyblue { 0, 191, 255 }
-- @field darkturquoise { 0, 206, 209 }
-- @field mediumspringgreen { 0, 250, 154 }
-- @field lime { 0, 255, 0 }
-- @field springgreen { 0, 255, 127 }
-- @field aqua { 0, 255, 255 }
-- @field cyan { 0, 255, 255 }
-- @field midnightblue { 25, 25, 112 }
-- @field dodgerblue { 30, 144, 255 }
-- @field forestgreen { 34, 139, 34 }
-- @field seagreen { 46, 139, 87 }
-- @field darkslategray { 47, 79, 79 }
-- @field darkslategrey { 47, 79, 79 }
-- @field limegreen { 50, 205, 50 }
-- @field mediumseagreen { 60, 179, 113 }
-- @field turquoise { 64, 224, 208 }
-- @field royalblue { 65, 105, 225 }
-- @field steelblue { 70, 130, 180 }
-- @field darkslateblue { 72, 61, 139 }
-- @field mediumturquoise { 72, 209, 204 }
-- @field indigo { 75, 0, 130 }
-- @field darkolivegreen { 85, 107, 47 }
-- @field cadetblue { 95, 158, 160 }
-- @field cornflowerblue { 100, 149, 237 }
-- @field mediumaquamarine { 102, 205, 170 }
-- @field dimgray { 105, 105, 105 }
-- @field dimgrey { 105, 105, 105 }
-- @field slateblue { 106, 90, 205 }
-- @field olivedrab { 107, 142, 35 }
-- @field slategray { 112, 128, 144 }
-- @field slategrey { 112, 128, 144 }
-- @field lightslategray { 119, 136, 153 }
-- @field lightslategrey { 119, 136, 153 }
-- @field mediumslateblue { 123, 104, 238 }
-- @field lawngreen { 124, 252, 0 }
-- @field chartreuse { 127, 255, 0 }
-- @field aquamarine { 127, 255, 212 }
-- @field maroon { 128, 0, 0 }
-- @field purple { 128, 0, 128 }
-- @field olive { 128, 128, 0 }
-- @field gray { 128, 128, 128 }
-- @field grey { 128, 128, 128 }
-- @field skyblue { 135, 206, 235 }
-- @field lightskyblue { 135, 206, 250 }
-- @field blueviolet { 138, 43, 226 }
-- @field darkred { 139, 0, 0 }
-- @field darkmagenta { 139, 0, 139 }
-- @field saddlebrown { 139, 69, 19 }
-- @field darkseagreen { 143, 188, 143 }
-- @field lightgreen { 144, 238, 144 }
-- @field mediumpurple { 147, 112, 216 }
-- @field darkviolet { 148, 0, 211 }
-- @field palegreen { 152, 251, 152 }
-- @field darkorchid { 153, 50, 204 }
-- @field yellowgreen { 154, 205, 50 }
-- @field sienna { 160, 82, 45 }
-- @field brown { 165, 42, 42 }
-- @field darkgray { 169, 169, 169 }
-- @field darkgrey { 169, 169, 169 }
-- @field lightblue { 173, 216, 230 }
-- @field greenyellow { 173, 255, 47 }
-- @field paleturquoise { 175, 238, 238 }
-- @field lightsteelblue { 176, 196, 222 }
-- @field powderblue { 176, 224, 230 }
-- @field firebrick { 178, 34, 34 }
-- @field darkgoldenrod { 184, 134, 11 }
-- @field mediumorchid { 186, 85, 211 }
-- @field rosybrown { 188, 143, 143 }
-- @field darkkhaki { 189, 183, 107 }
-- @field silver { 192, 192, 192 }
-- @field mediumvioletred { 199, 21, 133 }
-- @field indianred { 205, 92, 92 }
-- @field peru { 205, 133, 63 }
-- @field chocolate { 210, 105, 30 }
-- @field tan { 210, 180, 140 }
-- @field lightgray { 211, 211, 211 }
-- @field lightgrey { 211, 211, 211 }
-- @field palevioletred { 216, 112, 147 }
-- @field thistle { 216, 191, 216 }
-- @field orchid { 218, 112, 214 }
-- @field goldenrod { 218, 165, 32 }
-- @field crimson { 220, 20, 60 }
-- @field gainsboro { 220, 220, 220 }
-- @field plum { 221, 160, 221 }
-- @field burlywood { 222, 184, 135 }
-- @field lightcyan { 224, 255, 255 }
-- @field lavender { 230, 230, 250 }
-- @field darksalmon { 233, 150, 122 }
-- @field violet { 238, 130, 238 }
-- @field palegoldenrod { 238, 232, 170 }
-- @field lightcoral { 240, 128, 128 }
-- @field khaki { 240, 230, 140 }
-- @field aliceblue { 240, 248, 255 }
-- @field honeydew { 240, 255, 240 }
-- @field azure { 240, 255, 255 }
-- @field sandybrown { 244, 164, 96 }
-- @field wheat { 245, 222, 179 }
-- @field beige { 245, 245, 220 }
-- @field whitesmoke { 245, 245, 245 }
-- @field mintcream { 245, 255, 250 }
-- @field ghostwhite { 248, 248, 255 }
-- @field salmon { 250, 128, 114 }
-- @field antiquewhite { 250, 235, 215 }
-- @field linen { 250, 240, 230 }
-- @field lightgoldenrodyellow { 250, 250, 210 }
-- @field oldlace { 253, 245, 230 }
-- @field red { 255, 0, 0 }
-- @field fuchsia { 255, 0, 255 }
-- @field magenta { 255, 0, 255 }
-- @field deeppink { 255, 20, 147 }
-- @field orangered { 255, 69, 0 }
-- @field tomato { 255, 99, 71 }
-- @field hotpink { 255, 105, 180 }
-- @field coral { 255, 127, 80 }
-- @field darkorange { 255, 140, 0 }
-- @field lightsalmon { 255, 160, 122 }
-- @field orange { 255, 165, 0 }
-- @field lightpink { 255, 182, 193 }
-- @field pink { 255, 192, 203 }
-- @field gold { 255, 215, 0 }
-- @field peachpuff { 255, 218, 185 }
-- @field navajowhite { 255, 222, 173 }
-- @field moccasin { 255, 228, 181 }
-- @field bisque { 255, 228, 196 }
-- @field mistyrose { 255, 228, 225 }
-- @field blanchedalmond { 255, 235, 205 }
-- @field papayawhip { 255, 239, 213 }
-- @field lavenderblush { 255, 240, 245 }
-- @field seashell { 255, 245, 238 }
-- @field cornsilk { 255, 248, 220 }
-- @field lemonchiffon { 255, 250, 205 }
-- @field floralwhite { 255, 250, 240 }
-- @field snow { 255, 250, 250 }
-- @field yellow { 255, 255, 0 }
-- @field lightyellow { 255, 255, 224 }
-- @field ivory { 255, 255, 240 }
-- @field white { 255, 255, 255 }
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

