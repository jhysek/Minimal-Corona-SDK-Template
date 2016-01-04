--------------------------------------------------------------------------------
local class             = require "lib.middleclass"
local GenericCalculator = require "app.calculators.generic_calculator"
--------------------------------------------------------------------------------

local Calculator = class("Calculator", GenericCalculator)

Calculator.required_inputs = {
  "f01", "f02", "f03", "f04", "f05", "f06", "f07", "f08", "f09", "f10",
  "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18", "f19", "f20",
  "f21", "f22"
}

--------------------------------------------------------------------------------
-- Vypocet (dle dodanych podkladu)
--------------------------------------------------------------------------------
-- Snahou je vypocet prevest tak, aby byl co nejpodobnejsi dodanym podkladum
--
-- Pole "body" a "vypoctene" odpovida dodanym podkladum
--
-- POZOR! V Lua prvni prvek pole index 1, ne 0 - proto jsou indexy oproti
-- podkladum o jedno vyssi.
--
-- V promenne inp jsou ulozene zvalidovane a jiz na cisla prevedene vstupy.
--------------------------------------------------------------------------------
function Calculator:compute()
  local inp = self.inputs

  local body = {}
  local vypoctene = {}

  vypoctene[1] = (inp.f01 + inp.f02) / 2
  body[1]      = vypoctene[1] * 0.5

  vypoctene[2] = (inp.f03 + inp.f04) / 2
  body[2]      = vypoctene[2] * 0.25

  vypoctene[3] = (inp.f05 + inp.f06) / 2
  body[3]      = vypoctene[3] * 0.25

  vypoctene[4] = (inp.f07 + inp.f08) / 2
  body[4]      = vypoctene[4]

  vypoctene[5] = inp.f09 + inp.f10
  body[5]      = vypoctene[5]

  vypoctene[6] = inp.f11 + inp.f12
  body[6]      = vypoctene[6]

  vypoctene[7] = inp.f13 + inp.f14
  body[7]      = vypoctene[7]

  vypoctene[8] = inp.f15
  body[8]      = vypoctene[8] * 2

  vypoctene[9] = inp.f16 / vypoctene[1]
  if vypoctene[9] < 0.6 then body[9] = 0 end
  if vypoctene[9] >= 0.6 and vypoctene[9] < 0.7 then body[9] = 1 end
  if vypoctene[9] >= 0.7 and vypoctene[9] < 0.8 then body[9] = 2 end
  if vypoctene[9] >= 0.8 then body[9] = 3 end

  vypoctene[10] = inp.f17
  body[10]      = vypoctene[10]

  vypoctene[11] = inp.f18
  body[11]      = vypoctene[11]

  vypoctene[12] = inp.f19
  body[12]      = vypoctene[12]

  vypoctene[13] = inp.f20
  body[13]      = vypoctene[13]

  vypoctene[14] = inp.f21
  body[14]      = vypoctene[14]

  vypoctene[15] = inp.f22
  body[15]      = vypoctene[15]

  self.kladne = 0
  for i = 1, 14 do
    self.kladne = self.kladne + body[i]
  end

  self.zaporne = body[15]
  self.soucet  = self.kladne - self.zaporne

  if self.soucet < 170 then
    self.medal = "none"

  elseif self.soucet < 190 then
    self.medal = "bronze"

  elseif self.soucet < 210 then
    self.medal = "silver"

  else
    self.medal = "gold"
  end

  self.vypoctene = vypoctene
  self.body      = body
end

return Calculator
