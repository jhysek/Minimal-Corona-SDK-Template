--------------------------------------------------------------------------------
local class             = require "lib.middleclass"
local GenericCalculator = require "app.calculators.generic_calculator"
--------------------------------------------------------------------------------

local Calculator = class("Calculator", GenericCalculator)

Calculator.required_inputs = {
  "f01", "f02", "f03", "f04", "f05", "f06", "f07", "f08", "f09", "f10",
  "f11", "f12", "f13", "f14"
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

  vypoctene[1] = (inp.f01 + inp.f02) / 2
  body[1]      = vypoctene[1]

  vypoctene[2] = (inp.f03 + inp.f04) / 2
  body[2]      = vypoctene[2]

  vypoctene[3] = (inp.f05 + inp.f06) / 2
  body[3]      = vypoctene[3]

  vypoctene[4] = (inp.f07 + inp.f08) / 2
  body[4]      = vypoctene[4]

  vypoctene[5] = inp.f09
  body[5]      = vypoctene[5]
--
  vypoctene[6] = inp.f10
  body[6]      = vypoctene[6]

  vypoctene[7] = inp.f11
  body[7]      = vypoctene[7]

  vypoctene[8] = inp.f12
  body[8]      = vypoctene[8]

  vypoctene[9] = inp.f13
  body[9]      = vypoctene[9]

  vypoctene[9] = inp.f09 / inp.f14
  if vypoctene[1] < 2.5 then
    body[10] = 0
  elseif vypoctene[1] < 2.7 then
    body[10] = 1
  elseif vypoctene[1] < 2.9 then
    body[10] = 2
  else
    body[10] = 3
  end

  self.kladne = 0
  for i = 1, 9 do
    self.kladne = self.kladne + body[i]
  end

  self.zaporne = body[10] -- + body[11]   TODO: v podkladech je to takto i kdyz se body[11] (v podkladech body[10]) neprirazuju a jsou vzdy 0
  self.soucet  = self.kladne - self.zaporne

  if self.soucet < 185 then
    self.medal = "none"

  elseif self.soucet < 195 then
    self.medal = "bronze"

  elseif self.soucet < 205 then
    self.medal = "silver"

  else
    self.medal = "gold"
  end

  self.vypoctene = vypoctene
  self.body      = body
end

return Calculator
