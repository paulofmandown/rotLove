dice = require('dice')
math.randomseed(os.time())

-- Some special ways the user may choose to utilize the dice module
-- although there are endless creative possiblities

-- DUAL WIELDING --
    l_hand_weap, r_hand_weap = dice:new('1d6'), dice:new('2d4')
    attacks = {l_hand_weap:roll(), r_hand_weap:roll()}

    for _, attack in ipairs(attacks) do
      -- apply armor protection
      -- take damage
      -- ...
    end

-- STATUS EFFECTS --
    sleep_duration = dice.roll('1d100+50')
    confusion_duration = dice.roll('1d10')
    poison_damage = dice.roll('1d3')

-- CURSED/BLESSED ITEMS --
    basic_weapon = dice:new('1d4')

    if basic_weapon:isCursed() then       -- Add a reroll that removes the highest number
        basic_weapon = basic_weapon ^ -1
    elseif basic_weapon:isBlessed() then  -- Add a reroll that removes the lowest number
        basic_weapon = basic_weapon ^ 1
    end

-- SKILL MASTERY --
    if player:hasMasteredSkill() then
        -- apply a positive reroll when doing something
    end

-- AIMING AND TO-HIT --
    weapon_to_hit = dice:new('1d20')

    if weapon_to_hit:roll() > enemy_def then
        -- attack is successful
        -- apply damage
    end

-- BURSTFIRE --
    gattling_gun = dice:new('(1d5)x6')

    for _, damage in ipairs( {gattling_gun:roll()} ) do
        if to_hit:roll() > enemy_dodge then
            -- attack succeeds
            -- apply protections
            -- apply damage
        else
            -- missed
            -- skip damage calculations
            -- include miss message
        end
    end
