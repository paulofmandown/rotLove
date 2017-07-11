ROT=require 'src.rot'
local f, d_with_rng, rng
function love.load()
    f=ROT.Display:new(80,24)
    rng=ROT.RNG:new()
    d_with_rng=ROT.Dice:new('3d6', 1):setRNG(rng)
    d_without_rng=ROT.Dice:new('3d6', 1)
end
function love.draw() f:draw() end

local t=1.00000001
function love.update(dt)
    if t>1 then
        f:clear()
        f:writeCenter("ROLL instance with rng: "..d_with_rng:roll(), 1)
        f:writeCenter("ROLL instance with rng: "..d_with_rng:roll(), 2)
        f:writeCenter("ROLL instance with rng: "..d_with_rng:roll(), 3)
        f:writeCenter("ROLL instance with rng: "..d_with_rng:roll(), 4)

        f:writeCenter("ROLL instance without rng: "..d_without_rng:roll(), 6)
        f:writeCenter("ROLL instance without rng: "..d_without_rng:roll(), 7)
        f:writeCenter("ROLL instance without rng: "..d_without_rng:roll(), 8)
        f:writeCenter("ROLL instance without rng: "..d_without_rng:roll(), 9)

        f:writeCenter("ROLL ROT.Dice with rng: "..ROT.Dice.roll('3d6', 1, lcg), 11)
        f:writeCenter("ROLL ROT.Dice with rng: "..ROT.Dice.roll('3d6', 1, lcg), 12)
        f:writeCenter("ROLL ROT.Dice with rng: "..ROT.Dice.roll('3d6', 1, lcg), 13)
        f:writeCenter("ROLL ROT.Dice with rng: "..ROT.Dice.roll('3d6', 1, lcg), 14)

        f:writeCenter("ROLL ROT.Dice without rng: "..ROT.Dice.roll('3d6', 1), 16)
        f:writeCenter("ROLL ROT.Dice without rng: "..ROT.Dice.roll('3d6', 1), 17)
        f:writeCenter("ROLL ROT.Dice without rng: "..ROT.Dice.roll('3d6', 1), 18)
        f:writeCenter("ROLL ROT.Dice without rng: "..ROT.Dice.roll('3d6', 1), 19)

        f:writeCenter("Rolling 3d6's", 23)
        t=0
    end
    t=t+dt
end
