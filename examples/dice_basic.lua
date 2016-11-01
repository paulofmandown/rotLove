dice = require('dice')
math.randomseed(os.time())

-- some basic dice you see in boardgames

single_die = dice:new(6)  -- is the same as dice:new('1d6')
die_result = single_die:roll()

monopoly_dice = dice:new('2d6')
monopoly_turn = monopoly_dice:roll()

D&D_dice = dice:new('1d20')  -- we could also use dice:new(20)
roll_to_hit = D&D_dice:roll()

risk_attackers_dice = dice:new('(1d6)x3')
risk_defenders_dice = dice:new('(1d6)x2')

attack_1, attack_2, attack_3 = risk_attackers_dice:roll()
defend_1, defend_2 = risk_defenders_dice:roll()

--alternatively we could just put the risk roll results in a table
attackers_result =  { risk_attackers_dice:roll() }
defenders_result =  { risk_defenders_dice:roll() }


-- Another method to roll dice is instead of using the roguelike dice notation, we can just feed the roll function a direct number

die_result = dice.roll(6)
monopoly_turn = dice.roll(6) + dice.roll(6)
roll_to_hit = dice.roll(20)
attack_1, attack_2, attack_3 = dice.roll(6), dice.roll(6), dice.roll(6)
defend_1, defend_2 = dice.roll(6), dice.roll(6)

-- Or we can roll the dice just using the notation alone without having to use dice:new()

die_result = dice.roll('1d6')
monopoly_turn = dice.roll('2d6')
roll_to_hit = dice.roll('1d20')
attack_1, attack_2, attack_3 = dice.roll('(1d6)x3')
defend_1, defend_2 = dice.roll('(1d6)x2')

-- notice we omitted the colon from the dice roll function because a dice instance is not neccessary although
-- every roll will initialize the dice table, return the result, and then discard the dice table
-- which means if you will be using dice continously it will be more efficent to use dice:new()
