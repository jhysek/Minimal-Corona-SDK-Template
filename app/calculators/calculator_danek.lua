--------------------------------------------------------------------------------
local class             = require "lib.middleclass"
local GenericCalculator = require "app.calculators.generic_calculator"
--------------------------------------------------------------------------------

local Calculator = class("Calculator", GenericCalculator)

Calculator.required_inputs = {
  "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10",
  "f11", "f12", "f13", "f14", "f15", "f16", "f18", "f19", "f20",
  "f21", "f22", "f23"
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

  local body = {}
  local vypoctene = {}

  vypoctene[1] = (inp.f1 + inp.f2) / 2
  body[1]      = vypoctene[1] * 0.5

  vypoctene[2] = (inp.f3 + inp.f4) / 2
  body[2]      = vypoctene[2] * 0.25

  vypoctene[3] = (inp.f5 + inp.f6) / 2
  body[3]      = vypoctene[3]

  vypoctene[4] = (inp.f7 + inp.f8) / 2
  body[4]      = vypoctene[4] * 1.5

  vypoctene[5] = (inp.f9 + inp.f10) / 2
  body[5]      = vypoctene[5]

  vypoctene[6] = inp.f11 + inp.f12
  body[6]      = vypoctene[6]

  vypoctene[7] = inp.f13 + inp.f14
  body[7]      = vypoctene[7]

  vypoctene[8] = inp.f15
  body[8]      = vypoctene[8] * 2

  vypoctene[9] = inp.f16
  body[9]      = vypoctene[9]

  vypoctene[10] = inp.f17
  body[10]      = vypoctene[10]

  vypoctene[11] = inp.f18
  body[11]      = vypoctene[11]

  vypoctene[12] = inp.f19 / vypoctene[1]
  if vypoctene[12] >= 0.85 then body[12] = 0 end
  if vypoctene[12] < 0.85 then body[12] = 1 end
  if vypoctene[12] < 0.80 then body[12] = 2 end
  if vypoctene[12] < 0.75 then body[12] = 3 end
  if vypoctene[12] < 0.70 then body[12] = 4 end
  if vypoctene[12] < 0.65 then body[12] = 5 end
  if vypoctene[12] < 0.60 then body[12] = 6 end

  vypoctene[13] = inp.f20
  body[13]      = vypoctene[13]

  vypoctene[14] = inp.f21
  body[14]      = vypoctene[14]

  vypoctene[15] = inp.f22
  body[15]      = vypoctene[15]

  self.kladne = 0
  for i = 1, 11 do
    self.kladne = self.kladne + body[i]
  end

  self.zaporne = 0
  for i = 12, 15 do
    self.zaporne = self.zaporne + body[i]
  end

  self.soucet = self.kladne - self.zaporne

  if self.soucet < 160 then
    self.medal = "none"

  elseif self.soucet < 170 then
    self.medal = "bronze"

  elseif self.soucet < 180 then
    self.medal = "silver"

  else
    self.medal = "gold"
  end

  self.vypoctene = vypoctene
  self.body      = body
end

return Calculator
