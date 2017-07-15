ROT=require 'src.rot'
function love.load()
    f=ROT.Display()
    local s=''
    for i=1,80 do s=s..' ' end

    grey=ROT.Color.fromString('grey')

    c1=ROT.Color.fromString('rgb(10, 128, 230)')
    c2=ROT.Color.fromString('#faa')
    c3=ROT.Color.fromString('#83fcc4')
    c4=ROT.Color.fromString('goldenrod')
    c5={ 51, 102, 51, 255 }
    c6=ROT.Color.add({ 10, 128, 230, 255 }, { 200, 10, 15, 255 }, { 30, 30, 100, 255 })
    c7=ROT.Color.multiply(ROT.Color.fromString('goldenrod'),
                             ROT.Color.fromString('lightcyan'),
                              ROT.Color.fromString('lightcoral'))
    c8=ROT.Color.interpolate({ 200, 10, 15, 255 },{ 30, 30, 100, 255 })
    c9=ROT.Color.interpolateHSL({ 200, 10, 15, 255 },{ 30, 30, 100, 255 })

    c10=ROT.Color.randomize(ROT.Color.fromString('silver'), {30,10,20})
    c11=ROT.Color.randomize(ROT.Color.fromString('silver'), {30,10,20})
    c12=ROT.Color.randomize(ROT.Color.fromString('silver'), {30,10,20})
    c13=ROT.Color.randomize(ROT.Color.fromString('silver'), {30,10,20})

    c14=ROT.Color.fromString('silver')

    f:write(s, 1, 1, nil, c1)
    f:write(s, 1, 2, nil, c2)
    f:write(s, 1, 3, nil, c3)
    f:write(s, 1, 4, nil, c4)
    f:write(s, 1, 5, nil, c1)
    f:write(s, 1, 6, nil, c1)
    f:write(s, 1, 7, nil, c5)
    f:write(s, 1, 8, nil, c5)
    f:write(s, 1, 9, nil, c5)
    f:write(s, 1,10, nil, c5)
    f:write(s, 1,11, nil, c6)
    f:write(s, 1,12, nil, c6)
    f:write(s, 1,13, nil, c7)
    f:write(s, 1,14, nil, c7)
    f:write(s, 1,15, nil, c7)
    f:write(s, 1,16, nil, c8)
    f:write(s, 1,17, nil, c9)
    f:write(s, 1,18, nil, c10)
    f:write(s, 1,19, nil, c11)
    f:write(s, 1,20, nil, c12)
    f:write(s, 1,21, nil, c13)
    f:write(s, 1,22, nil, c14)
    f:write(s, 1,23, nil, c14)
    f:write(s, 1,24, nil, c14)

    -- generating a color object from a string
    f:writeCenter("ROT.Color.fromString('rgb(10, 128, 230)')", 1, nil, c1)
    f:writeCenter("ROT.Color.fromString('#faa')", 2, grey, c2)
    f:writeCenter("ROT.Color.fromString('#83fcc4')", 3, grey, c3)
    f:writeCenter("ROT.Color.fromString('goldenrod')", 4, grey, c4)

    -- Converting a color object to a string
    f:writeCenter("ROT.Color.toRGB({ 10, 128, 230, 255 })=="..ROT.Color.toRGB({ 10, 128, 230 }), 5, nil, c1)
    f:writeCenter("ROT.Color.toHex({ 10, 128, 230, 255 })=="..ROT.Color.toHex({ 10, 128, 230 }), 6, nil, c1)

    -- converting a color from rgb to hsl
    f:writeCenter("ROT.Color.rgb2hsl({ 51, 102, 51, 255 })", 7, nil, c5)
    local tbl=ROT.Color.rgb2hsl({ 51, 102, 51, 255 })
    local s="{"
    for k,_ in pairs(tbl) do
        s=s..k.."="..tbl[k]..", "
    end
    s=s:sub(1,#s-2).."}"
    f:writeCenter(s, 8, nil, c5)

    -- and back!
    f:writeCenter("ROT.Color.hsl2rgb({ .333, .333, .3 })", 9, nil, c5)
    local tbl=ROT.Color.hsl2rgb({ .333, .333, .3 })
    local s="{"
    for k,_ in pairs(tbl) do
        s=s..k.."="..tbl[k]..", "
    end
    s=s:sub(1,#s-2).."}"
    f:writeCenter(s, 10, nil, c5)

    -- Adding two or more colors
        -- arg1 is the base color
        -- arg2 is either a second color or a table of colors (This also applies to multiply)
    f:write("add({ 10, 128, 230, 255 }, { 200, 10, 15, 255 }, { 30, 30, 100, 255 })", 1, 11, nil, c6)
    local s=ROT.Color.toRGB(c6)
    f:writeCenter(s, 12, nil, c6)

    -- Multiplying two or more colors
    f:write("ROT.Color.multiply(ROT.Color.fromString('goldenrod'),", 1, 13, nil, c7)
    f:write("                     {ROT.Color.fromString('lightcyan'),", 1, 14, nil, c7)
    f:write("                      ROT.Color.fromString('lightcoral')})", 1, 15, nil, c7)

    -- Interpolate 2 colors
    f:write("ROT.Color.interpolate({ 200, 10, 15, 255 },{ 30, 30, 100, 255 })", 1, 16, nil, c8)

    -- Interpolate 2 colors in HSL mode
    f:write("ROT.Color.interpolateHSL({ 200, 10, 15, 255 },{ 30, 30, 100, 255 })", 1, 17, nil, c9)

    -- Randomize Color from a reference and standard deviation
    f:writeCenter("ROT.Color.randomize(ROT.Color.fromString('silver'), {30,10,20})", 18, nil, c10)
    f:writeCenter("ROT.Color.randomize(ROT.Color.fromString('silver'), {30,10,20})", 19, nil, c11)
    f:writeCenter("ROT.Color.randomize(ROT.Color.fromString('silver'), {30,10,20})", 20, nil, c12)
    f:writeCenter("ROT.Color.randomize(ROT.Color.fromString('silver'), {30,10,20})", 21, nil, c13)

    f:writeCenter("ROT.Color.fromString('silver')", 23, nil, c14)

end
function love.draw() f:draw() end
