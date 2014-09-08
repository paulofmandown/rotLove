ROT=require 'vendor/rotLove/rotLove'

function love.load()
    colorHandler=ROT.Color:new()
    f=ROT.Display()
    local s=''
    for i=1,80 do s=s..' ' end

    grey=colorHandler:fromString('grey')

    c1=colorHandler:fromString('rgb(10, 128, 230)')
    c2=colorHandler:fromString('#faa')
    c3=colorHandler:fromString('#83fcc4')
    c4=colorHandler:fromString('goldenrod')
    c5={r=51,g=102,b=51,a=255}
    c6=colorHandler:add({r=10,g=128,b=230,a=255}, {{r=200,g=10,b=15,a=255},{r=30,g=30,b=100,a=255}})
    c7=colorHandler:multiply(colorHandler:fromString('goldenrod'),
                             {colorHandler:fromString('lightcyan'),
                              colorHandler:fromString('lightcoral')})
    c8=colorHandler:interpolate({r=200,g=10,b=15,a=255},{r=30,g=30,b=100,a=255})
    c9=colorHandler:interpolateHSL({r=200,g=10,b=15,a=255},{r=30,g=30,b=100,a=255})

    c10=colorHandler:randomize(colorHandler:fromString('silver'), {30,10,20})
    c11=colorHandler:randomize(colorHandler:fromString('silver'), {30,10,20})
    c12=colorHandler:randomize(colorHandler:fromString('silver'), {30,10,20})
    c13=colorHandler:randomize(colorHandler:fromString('silver'), {30,10,20})

    c14=colorHandler:fromString('silver')

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
    f:writeCenter("colorHandler:fromString('rgb(10, 128, 230)')", 1, nil, c1)
    f:writeCenter("colorHandler:fromString('#faa')", 2, grey, c2)
    f:writeCenter("colorHandler:fromString('#83fcc4')", 3, grey, c3)
    f:writeCenter("colorHandler:fromString('goldenrod')", 4, grey, c4)

    -- Converting a color object to a string
    f:writeCenter("colorHandler:toRGB({r=10, g=128, b=230, a=255})=="..colorHandler:toRGB({r=10, g=128, b=230}), 5, nil, c1)
    f:writeCenter("colorHandler:toHex({r=10, g=128, b=230, a=255})=="..colorHandler:toHex({r=10, g=128, b=230}), 6, nil, c1)

    -- converting a color from rgb to hsl
    f:writeCenter("colorHandler:rgb2hsl({r=51, g=102, b=51, a=255})", 7, nil, c5)
    local tbl=colorHandler:rgb2hsl({r=51, g=102, b=51, a=255})
    local s="{"
    for k,_ in pairs(tbl) do
        s=s..k.."="..tbl[k]..", "
    end
    s=s:sub(1,#s-2).."}"
    f:writeCenter(s, 8, nil, c5)

    -- and back!
    f:writeCenter("colorHandler:hsl2rgb({h=.333, s=.333, l=.3})", 9, nil, c5)
    local tbl=colorHandler:hsl2rgb({h=.333, s=.333, l=.3})
    local s="{"
    for k,_ in pairs(tbl) do
        s=s..k.."="..tbl[k]..", "
    end
    s=s:sub(1,#s-2).."}"
    f:writeCenter(s, 10, nil, c5)

    -- Adding two or more colors
        -- arg1 is the base color
        -- arg2 is either a second color or a table of colors (This also applies to multiply)
    f:write("add({r=10,g=128,b=230,a=255}, {{r=200,g=10,b=15,a=255},{r=30,g=30,b=100,a=255}})", 1, 11, nil, c6)
    local s=colorHandler:toRGB(c6)
    f:writeCenter(s, 12, nil, c6)

    -- Multiplying two or more colors
    f:write("colorHandler:multiply(colorHandler:fromString('goldenrod'),", 1, 13, nil, c7)
    f:write("                     {colorHandler:fromString('lightcyan'),", 1, 14, nil, c7)
    f:write("                      colorHandler:fromString('lightcoral')})", 1, 15, nil, c7)

    -- Interpolate 2 colors
    f:write("colorHandler:interpolate({r=200,g=10,b=15,a=255},{r=30,g=30,b=100,a=255})", 1, 16, nil, c8)

    -- Interpolate 2 colors in HSL mode
    f:write("colorHandler:interpolateHSL({r=200,g=10,b=15,a=255},{r=30,g=30,b=100,a=255})", 1, 17, nil, c9)

    -- Randomize Color from a reference and standard deviation
    f:writeCenter("colorHandler:randomize(colorHandler:fromString('silver'), {30,10,20})", 18, nil, c10)
    f:writeCenter("colorHandler:randomize(colorHandler:fromString('silver'), {30,10,20})", 19, nil, c11)
    f:writeCenter("colorHandler:randomize(colorHandler:fromString('silver'), {30,10,20})", 20, nil, c12)
    f:writeCenter("colorHandler:randomize(colorHandler:fromString('silver'), {30,10,20})", 21, nil, c13)

    f:writeCenter("colorHandler:fromString('silver')", 23, nil, c14)

end
function love.draw() f:draw() end
