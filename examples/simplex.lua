--[[ Simplex Noise ]]--
ROT=require 'src.rot'
function generateNoise()
    sim=ROT.Noise.Simplex()
    for j=1,f:getHeight() do
        for i=1,f:getWidth() do
            local val=sim:get(i/20, j/20)
            red  =(val>0 and val or 0)
            green=(val<0 and -val or 0)

            f:write(' ', i, j, nil, { red, green, 0, 1.0 })
        end
    end
end
function love.load()
    f  =ROT.Display(120, 50)
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
