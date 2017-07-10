--- A module used to roll and manipulate roguelike based dice
-- Based off the RL-Dice library at https://github.com/timothymtorres/RL-Dice
-- @module ROT.Dice

local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Dice = ROT.Class:extend("Dice", {minimum=1}) -- class default lowest possible roll is 1  (can set to nil to allow negative rolls)

--- Constructor that creates a new dice instance
-- @tparam ?int|string dice_notation Can be either a dice string, or int
-- @tparam[opt] int minimum Sets dice instance roll's minimum result boundaries
-- @treturn dice
function Dice:init(dice_notation, minimum)
  -- If dice_notation is a number, we must convert it into the proper dice string format
  if type(dice_notation) ==  'number' then dice_notation = '1d'..dice_notation end

  local dice_pattern = '[(]?%d+[d]%d+[+-]?[+-]?%d*[%^]?[+-]?[+-]?%d*[)]?[x]?%d*'
    assert(dice_notation == string.match(dice_notation, dice_pattern), "Dice string incorrectly formatted.")

    self.num = tonumber(string.match(dice_notation, '%d+'))
    self.faces = tonumber(string.match(dice_notation, '[d](%d+)'))

    local double_bonus = string.match(dice_notation, '[d]%d+([+-]?[+-])%d+')
    local bonus = string.match(dice_notation, '[d]%d+[+-]?([+-]%d+)')
    self.is_bonus_plural = double_bonus == '++' or double_bonus == '--'
    self.bonus = tonumber(bonus) or 0

    local double_reroll = string.match(dice_notation, '[%^]([+-]?[+-])%d+')
    local reroll = string.match(dice_notation, '[%^][+-]?([+-]%d+)')
    self.is_reroll_plural = double_reroll == '++' or double_reroll == '--'
    self.rerolls = tonumber(reroll) or 0

    self.sets = tonumber(string.match(dice_notation, '[x](%d+)')) or 1

    self.minimum = minimum
end

--- Sets dice minimum result boundaries (if nil, no minimum result)
function Dice:setMin(value) self.minimum = value end

--- Get number of total dice
function Dice:getNum() return self.num end

--- Get number of total faces on a dice
function Dice:getFaces() return self.faces end

--- Get bonus to be added to the dice total
function Dice:getBonus() return self.bonus end

--- Get rerolls to be added to the dice
function Dice:getRerolls() return self.rerolls end

--- Get number of total dice sets
function Dice:getSets() return self.sets end

--- Get bonus to be added to all dice (if double bonus enabled) otherwise regular bonus
function Dice:getTotalBonus() return (self.is_bonus_plural and self.bonus*self.num) or self.bonus end

--- Get rerolls to be added to all dice (if double reroll enabled) otherwise regular reroll
function Dice:getTotalRerolls() return (self.is_reroll_plural and self.rerolls*self.num) or self.rerolls end

--- Returns boolean that checks if all dice are to be rerolled together or individually
function Dice:isDoubleReroll() return self.is_reroll_plural end

--- Returns boolean that checks if all dice are to apply a bonus together or individually
function Dice:isDoubleBonus() return self.is_bonus_plural end

--- Modifies bonus
function Dice:__add(value) self.bonus = self.bonus + value return self end

--- Modifies bonus
function Dice:__sub(value) self.bonus = self.bonus - value return self end

--- Modifies number of dice
function Dice:__mul(value) self.num = self.num + value return self end

--- Modifies amount of dice faces
function Dice:__div(value) self.faces = self.faces + value return self end

--- Modifies rerolls
function Dice:__pow(value) self.rerolls = self.rerolls + value return self end

--- Modifies dice sets
function Dice:__mod(value) self.sets = self.sets + value return self end

--- Returns a formatted dice string in roguelike notation
function Dice:__tostring()
    local num_dice, dice_faces, bonus, is_bonus_plural, rerolls, is_reroll_plural, sets = self.num, self.faces, self.bonus, self.is_bonus_plural, self.rerolls, self.is_reroll_plural, self.sets

    -- num_dice & dice_faces default to 1 if negative or 0!
    sets, num_dice, dice_faces = math.max(sets, 1), math.max(num_dice, 1), math.max(dice_faces, 1)

    local double_bonus = is_bonus_plural and (bonus >= 0 and '+' or '-') or ''
    bonus = (bonus ~= 0 and double_bonus..string.format('%+d', bonus)) or ''

    local double_reroll = is_reroll_plural and (rerolls >= 0 and '+' or '-') or ''
    rerolls = (rerolls ~= 0 and '^'..double_reroll..string.format('%+d', rerolls)) or ''

  if sets > 1 then return '('..num_dice..'d'..dice_faces..bonus..rerolls..')x'..sets
  else return num_dice..'d'..dice_faces..bonus..rerolls
  end
end

--- Modifies whether reroll or bonus applies to individual dice or all of them (pluralism_notation string must be one of the following operators `- + ^` The operator may be double signed to indicate pluralism)
function Dice:__concat(pluralism_notation)
    local str_b = string.match(pluralism_notation, '[+-][+-]?') or ''
    local bonus = ((str_b == '++' or str_b == '--') and 'double') or ((str_b == '+' or str_b == '-') and 'single') or nil

    local str_r = string.match(pluralism_notation, '[%^][%^]?') or ''
    local reroll = (str_r == '^^' and 'double') or (str_r == '^' and 'single') or nil

    if bonus == 'double' then self.is_bonus_plural = true
    elseif bonus == 'single' then self.is_bonus_plural = false end

    if reroll == 'double' then self.is_reroll_plural = true
    elseif reroll == 'single' then self.is_reroll_plural = false end
    return self
end

--- Rolls the dice
-- @tparam ?int|dice|str self
-- @tparam[opt] int minimum
-- @tparam[opt] ROT.RNG rng When called directly as ROT.Dice.roll, is used
--     in call to ROT.Dice.new. Not used when called on an instance of ROT.Dice.
--
--     i.e.: `ROT.Dice.roll('3d6', 1, rng) -- rng arg used`
--
--           `d = ROT.Dice:new('3d6', 1); d:roll(nil, rng) -- rng arg not used`
--
--
function Dice.roll(self, minimum, rng)
  if type(self) ~= 'table' then self = ROT.Dice:new(self, minimum):setRNG(rng) end
  local num_dice, dice_faces = self.num, self.faces
  local bonus, rerolls = self.bonus, self.rerolls
  local is_bonus_plural, is_reroll_plural = self.is_bonus_plural, self.is_reroll_plural
  local sets, minimum = self.sets, self.minimum

  sets = math.max(sets, 1)  -- Minimum of 1 needed
  local set_rolls = {}

  local bonus_all = is_bonus_plural and bonus or 0
  rerolls = is_reroll_plural and rerolls*num_dice or rerolls

  -- num_dice & dice_faces CANNOT be negative!
  num_dice, dice_faces = math.max(num_dice, 1), math.max(dice_faces, 1)

  for i=1, sets do
    local rolls = {}
    for ii=1, num_dice + math.abs(rerolls) do
      rolls[ii] = self._rng:random(1, dice_faces) + bonus_all  -- if is_bonus_plural then bonus_all gets added to every roll, otherwise bonus_all = 0
    end

    if rerolls ~= 0 then
      -- sort and if reroll is + then remove lowest rolls, if reroll is - then remove highest rolls
      if rerolls > 0 then table.sort(rolls, function(a,b) return a>b end) else table.sort(rolls) end
      for index=num_dice + 1, #rolls do rolls[index] = nil end
    end

    -- bonus gets added to the last roll if it is not plural
    if not is_bonus_plural then rolls[#rolls] = rolls[#rolls] + bonus end

    local total = 0
    for _, number in ipairs(rolls) do total = total + number end
    set_rolls[i] = total
  end

  -- if minimum is empty then use dice class default min
  if minimum == nil then minimum = Dice.minimum end

  if minimum then
    for i=1, sets do
      set_rolls[i] = math.max(set_rolls[i], minimum)
    end
  end

  return unpack(set_rolls)
end

return Dice
