--------------------------------------------------------------------------------
local class             = require "lib.middleclass"
local GenericCalculator = require "app.calculators.generic_calculator"
--------------------------------------------------------------------------------

local Calculator = class("Calculator", GenericCalculator)

Calculator.required_inputs = {
  "f01", "f02", "f03", "f04", "f05", "f06", "f07", "f08"
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
  body[2]      = vypoctene[2] * 3

  vypoctene[3] = (inp.f05 + inp.f06)
  body[3]      = vypoctene[3]

  vypoctene[4] = inp.f07
  body[4]      = vypoctene[4]

  vypoctene[5] = inp.f08
  body[5]      = vypoctene[5]

  self.kladne  = body[1] + body[2] + body[3] + body[4]
  self.zaporne = body[5]
  self.soucet  = self.kladne - self.zaporne

  if self.soucet < 110 then
    self.medal = "none"

  elseif self.soucet < 115 then
    self.medal = "bronze"

  elseif self.soucet < 120 then
    self.medal = "silver"

  else
    self.medal = "gold"
  end

  self.vypoctene = vypoctene
  self.body      = body
end

return Calculator
