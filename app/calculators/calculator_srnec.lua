--------------------------------------------------------------------------------
local class             = require "lib.middleclass"
local GenericCalculator = require "app.calculators.generic_calculator"
--------------------------------------------------------------------------------

local Calculator = class("Calculator", GenericCalculator)

Calculator.required_inputs = {
  "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12"
}

--------------------------------------------------------------------------------
-- Vypocet (dle dodanych podkladu)
--------------------------------------------------------------------------------
-- Snahou je vypocet prevest tak, aby byl co nejpodobnejsi dodanym podkladum
--
-- Pole "body" a "vypoctene" odpovida dodanym podkladum (s tim rozdilem,
-- ze prvni prvek ma v Lua index 1, ne 0).
--
-- V promenne inp jsou ulozene zvalidovane a jiz na cisla prevedene vstupy.
--------------------------------------------------------------------------------
function Calculator:compute()
  local inp = self.inputs

  local body      = {}
  local vypoctene = {}

  vypoctene[1] = (inp.f1 + inp.f2) / 2
  body[1]      = vypoctene[1] * 0.5

  vypoctene[2] = inp.f3
  body[2]      = vypoctene[2] * 0.1

  vypoctene[3] = inp.f4
  body[3]      = vypoctene[3] * 0.3

  vypoctene[4] = inp.f5 / vypoctene[1]
  if vypoctene[4] <= 0.3 or vypoctene[4] > 0.75 then
    body[4] = 0

  elseif vypoctene[4] > 0.3 and vypoctene[4] <= 0.35 then
    body[4] = 1

  elseif vypoctene[4] > 0.35 and vypoctene[4] <= 0.4 then
    body[4] = 2

  elseif vypoctene[4] > 0.4 and vypoctene[4] <= 0.45 then
    body[4] = 3

  elseif vypoctene[4] > 0.45 and vypoctene[4] <= 0.75 then
    body[4] = 4
  end

  vypoctene[5] = inp.f6
  body[5]      = vypoctene[5]

  vypoctene[6] = inp.f7
  body[6]      = vypoctene[6]

  vypoctene[7] = inp.f8
  body[7]      = vypoctene[7]

  vypoctene[8] = inp.f9
  body[8]      = vypoctene[8]

  vypoctene[9] = inp.f10
  body[9]      = vypoctene[9]

  vypoctene[10] = inp.f11
  body[10]      = vypoctene[10]

  vypoctene[11] = inp.f12
  body[11]      = vypoctene[11]

  self.kladne = 0
  for i = 1, 10 do
    self.kladne  = self.kladne + body[i]
  end
  self.zaporne = body[11]
  self.soucet  = self.kladne - self.zaporne

  if self.soucet < 105 then
    self.medal = "none"

  elseif self.soucet < 115 then
    self.medal = "bronze"

  elseif self.soucet < 130 then
    self.medal = "silver"

  else
    self.medal = "gold"
  end

  self.vypoctene = vypoctene
  self.body      = body
end

return Calculator
