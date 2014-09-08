--[[ Simplex Noise ]]--
ROT=require 'vendor/rotLove/rotLove'
function generateNoise()
    sim=ROT.Noise.Simplex()
    for j=1,f:getHeight() do
        for i=1,f:getWidth() do
            local val=sim:get(i/20, j/20)*255
            red  =math.floor(val>0 and val or 0)
            green=math.floor(val<0 and -val or 0)

            f:write(' ', i, j, nil, {r=red, g=green, b=0, a=255})
        end
    end
end
function love.load()
    f  =ROT.Display(256, 100, .275)
    generateNoise()
end
update=false
function love.update()
    if update then
        update=false
        generateNoise()
    end
end
function love.keypressed(key) update=true end
function love.draw()
    f:draw()
end
