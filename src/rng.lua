--- The RNG Prototype.
-- The base class that is extended by all rng classes
-- @module ROT.RNG.
local ROT = require((...):gsub('[^./\\]*$', '') .. 'rot')
local RNG = ROT.Class:extend("RNG")

function RNG:normalize(n) --keep numbers at (positive) 32 bits
    return n % 0x80000000
end

function RNG:bit_and(a, b)
    local r = 0
    for m = 0, 31 do
        if (a % 2 == 1) and (b % 2 == 1) then r = r + 2^m end
        if a % 2 ~= 0 then a = a - 1 end
        if b % 2 ~= 0 then b = b - 1 end
        a = a / 2 b = b / 2
    end
    return self:normalize(r)
end

function RNG:bit_or(a, b)
    local r = 0
    for m = 0, 31 do
        if (a % 2 == 1) or (b % 2 == 1) then r = r + 2^m end
        if a % 2 ~= 0 then a = a - 1 end
        if b % 2 ~= 0 then b = b - 1 end
        a = a / 2 b = b / 2
    end
    return self:normalize(r)
end

function RNG:bit_xor(a, b)
    local r = 0
    for m = 0, 31 do
        if a % 2 ~= b % 2 then r = r + 2^m end
        if a % 2 ~= 0 then a = a - 1 end
        if b % 2 ~= 0 then b = b - 1 end
        a = a / 2 b = b / 2
    end
    return self:normalize(r)
end

function RNG:random(a,b)
    return math.random(a,b)
end

function RNG:getWeightedValue(tbl)
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
-- get the host system's time in milliseconds* as a positive 32 bit number
-- * fake milliseconds with os.clock
-- @return number
function RNG:seed()
    --return self:normalize(tonumber(tostring(os.time()):reverse()))
    return self:normalize(os.time() * 1000 + (os.clock() * 1000))
end

return RNG
