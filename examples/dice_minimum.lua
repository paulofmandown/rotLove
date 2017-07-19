dice = require('dice')
math.randomseed(os.time())

-- Due to the possiblity of negative rolls and whether the user wishes for this type of behavior, a dice
-- minimum is factored into rolls to enable or prevent this from happening.  By default the minimum is set to 1

-- Roll a die with a negative bonus
dice.roll('1d1-100')    -- RESULT = 1

-- Disable the minimum
dice:setMinimum(nil)

-- Try this again
dice.roll('1d1-100')    -- RESULT = -99

-- The second argument in dice.roll allows a shortcut to set the minimum
dice.roll('1d1-100', 0) -- RESULT = 0

-- Another handy feature allows us to place a minimum on each individual dice instance

test_dice = dice:new('1d1-100', 1)  -- Yet again a second argument in dice:new is a shortcut to set the minimum
test_dice:roll()        -- RESULT = 1
test_dice:setMinimum(nil)
test_dice:roll()        -- RESULT = 0  (dice class minimum used instead)

-- Notice how the dice instance minimum has precedence over dice class minimum although
-- if a dice instance minimum is not set, then by default the dice class minimum will be used
