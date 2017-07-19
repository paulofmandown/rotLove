dice = require('dice')
math.randomseed(os.time())

weapon = dice:new('1d6')  -- 1d6

-- Subtraction or addition modifies the bonus of the rolls
weapon = weapon + 4       -- 1d6+4
weapon = weapon - 2       -- 1d6+2

-- Multiplcation modifies the number of dice
weapon = weapon * 2       -- 3d6+2

-- Division modifies the number of faces on the dice
weapon = weapon / -2      -- 3d4+2

-- Exponential modifies the rerolls (positive number removes low rolls, negative number removes high rolls)
weapon = weapon ^ 1       -- 3d4+2^+1

-- Modulo division modifies the dice sets (returns multiple results)
weapon = weapon % 2       --(3d4+1^+1)x3

-- To string operations returns a dice notation string
print(weapon)             --(3d4+2^+1)x3

-- Concat operations is a tricky concept to explain. Concating the dice with the following strings
-- '++', '--', '^^', '+', '-', '^' or a combination of both disables or enables plurality of bonus/rerolls
-- if a double operation sign is used, then the effect will be MULTIPLIED TO ALL dice
-- if a single operation sign is used, then the effect will apply as normal

-- Let us create a new weapon to demonstrate this with bonuses
weapon = dice:new('3d1+2')

-- Time to show how it is calculated
print(weapon:roll())       -- 1 + 1 + (1+2)  RESULT=5

-- Enable plurality for bonus
weapon = weapon .. '++'    -- 3d1++2

-- Calculation is much different now!
print(weapon:roll())       -- (1+2) + (1+2) + (1+2)  RESULT=9

-- Reset back to normal
weapon = weapon .. '+'     --Plurality is now disabled for bonus

-- Alternatively instead of '++' and '+' you may opt to use '--' and '-' instead.
-- Both signs enable/disable plurality for bonus

-- Another new weapon to demonstrate plurality for rerolls
weapon = dice:new('2d6^+1')

-- Rolls 2 dice and one extra
print(weapon:roll())        -- (5) (3) (1) -- Out of the 3 dice, remove the lowest roll -> (1)  RESULT=8

-- Enable plurality for rerolls
weapon = weapon .. '^^'

-- Now rolls 2 dice and two extra
print(weapon:roll())        -- (2) (6) (4) (2) -- Out of the 4 dice, remove the two lowest rolls -> (2) (2)  RESULT=10
