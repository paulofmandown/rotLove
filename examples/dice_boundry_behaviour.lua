dice = require('dice')
math.randomseed(os.time())

-- Demonstration of the what-ifs of this dice module when the user attempts unusual behavior

test_dice = dice:new('3d6')  -- initializes our dice instance

-- Let's try to do something crazy!
test_dice = test_dice / -100 -- Attempt to make the dice faces a negative number
test_dice = test_dice * -10  -- Annnnd negative number of dice
test_dice = test_dice % -1   -- Annnnnnnnd 0 dice sets

-- Instead of the dice module crashing, these three fields have a boundry of math.max(value, 1)
-- So that even if the numbers go into negative, the dice will still roll properly

print(test_dice)              -- 1d1
test_dice:roll()              -- RESULT = 1

-- If we check the dice variables we get...

test_dice:getFaces()          --    -94
test_dice:getNum()            --     -7
test_dice:getSets()           --      0

-- The variables are still being tracked properly.  Good to know!
