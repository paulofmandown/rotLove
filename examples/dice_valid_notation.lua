-- The dice must follow a certain string format when creating a new dice object or it will raise an error.

dice_str = '1d5'                    -- valid
dice_str = '3d5'                    -- valid
dice_str = '(1d3)x1'                -- valid
dice_str = '1d2+1'                  -- valid
dice_str = '1d10^+1'                -- valid
dice_str = '1d5+1^-2'               -- valid
dice_str = '(1d3+8^+3)x3'           -- valid
dice_str = ' 1d5'                   -- not valid (space in front of string)
dice_str = '+10d5'                  -- not valid (cannot have a + or - sign in front of dice number)
dice_str = '5d+5'                   -- not valid (cannot have a + or - sign in front of dice faces either)
dice_str = '3d4+^1'                 -- not valid (there is no number for the bonus?!)
dice_str = '(1d3)x1+5'              -- not valid (bonuses and rerolls have to be inside the sets parenthesis!)
dice_str = '3d4^3'                  -- not valid (reroll needs a + or - sign in front of it)
