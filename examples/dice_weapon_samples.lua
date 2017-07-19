-- Here is a list of weapons that I have made for some of my games and how they have been
-- used with the dice module


-- *Note that every weapon that is initalized has a condition variable between:
-- weapon.condition = {0=ruined, 1=worn, 2=average, 3=pristine}
-- This will effect the dice string or accuracy in a positive or negative way for each weapon group differently

weapon = {}
-- weapon.dice =        Damage upon a successful attack
-- weapon.accuracy =    To-hit chance
-- weapon.durability =  Chance for condition to degrade after use (higher number results in longer use)

--[[
--- BRUTE ---
-----  This weapon group uses large dice face numbers that excel against armored opponets
-----  High amount of durability since attacking with dull melee weapons
-----  Low accuracy since swinging bulky melee weapons is diffcult

-----  Condition Modifiers -----
-----  dice = dice / -4  (ruined)
-----  dice = dice / -2  (worn)
-----  dice = dice       (average)
-----  dice = dice /  2  (pristine)
--]]

weapon.bat = {}
weapon.bat.full_name = 'baseball bat'
weapon.bat.dice = '1d4'
weapon.bat.accuracy = 4
weapon.bat.durability = 12

weapon.crowbar = {}
weapon.crowbar.full_name = 'crowbar'
weapon.crowbar.dice = '1d5'
weapon.crowbar.accuracy = 4
weapon.crowbar.durability = 10

weapon.sledge = {}
weapon.sledge.full_name = 'sledgehammer'
weapon.sledge.dice = '1d8'
weapon.sledge.accuracy = 3
weapon.sledge.durability = 10

--[[
--- BLADE ---
-----  This weapon group uses dice bonuses that makes for high average damage output
-----  Low durability since bladed weapons dull quickly
-----  Medium accuracy since bladed weapons are light

-----  Condition Modifiers -----
-----  dice = dice - 2  (ruined)
-----  dice = dice - 1  (worn)
-----  dice = dice      (average)
-----  dice = dice + 1  (pristine)
--]]

weapon.knife = {}
weapon.knife.full_name = 'knife'
weapon.knife.dice = '1d2+1'
weapon.knife.accuracy = 4
weapon.knife.durability = 3

weapon.katanna = {}
weapon.katanna.full_name = 'katanna'
weapon.katanna.dice = '1d4+2'
weapon.katanna.accuracy = 5
weapon.katanna.durability = 4

--[[
--- PROJECTILE ---
-----  This weapon group uses high damage, but at the cost of ammo
-----  Medium durability
-----  High accuracy

-----  Condition Modifiers -----
-----  accuracy = accuracy - 2  (ruined)
-----  accuracy = accuracy - 1  (worn)
-----  accuracy = accuracy      (average)
-----  accuracy = accuracy + 1  (pristine)

-----  Notice this isn't affecting the damage, but merely the accuracy!
-----  Also we can conclude that whenever a ranged weapon is fired, it uses
-----  up durability regardless of hit or miss, whereas a melee weapon does
-----  not use durability on a miss
--]]

weapon.pistol = {}
weapon.pistol.full_name = 'pistol'
weapon.pistol.dice = '1d6+2'
weapon.pistol.accuracy = 6
weapon.pistol.durability = 7

weapon.magnum = {}
weapon.magnum.full_name = 'magnum'
weapon.magnum.dice = '1d9+4'
weapon.magnum.accuracy = 6
weapon.magnum.durability = 8

weapon.shotgun = {}
weapon.shotgun.full_name = 'shotgun'
weapon.shotgun.dice = '3d3++1'
weapon.shotgun.accuracy = 6
weapon.shotgun.durability = 8

weapon.rifle = {}
weapon.rifle.full_name = 'assualt rifle'
weapon.rifle.dice = '(3d2)x3'
weapon.rifle.accuracy = 7
weapon.rifle.durability = 8


--[[
--- BURN/EXPLOSIVES ---
-----  This weapon group uses large number of dice
-----  These weapons are single use
-----  Low accuracy
-----  Unpredictable damage, usually high

-----  Condition Modifiers -----
-----  dice = dice * -2  (ruined)
-----  dice = dice * -1  (worn)
-----  dice = dice       (average)
-----  dice = dice *  1  (pristine)
--]]

weapon.molotov = {}
weapon.molotov.full_name = 'molotov cocktail'
weapon.molotov.dice = '5d2'
weapon.molotov.accuracy = 3
weapon.molotov.durability = 'one_use'

weapon.flare = {}
weapon.flare.full_name = 'flare gun'
weapon.flare.dice = '5d3'
weapon.flare.accuracy = 3
weapon.flare.durability = 'one_use'

weapon.missile = {}
weapon.missile.full_name = 'missile launcher'
weapon.missile.dice = '5d8'
weapon.missile.accuracy = 3
weapon.missile.durability = 'one_use'

return weapon
