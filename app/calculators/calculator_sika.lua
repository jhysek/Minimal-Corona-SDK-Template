--------------------------------------------------------------------------------
local class             = require "lib.middleclass"
local GenericCalculator = require "app.calculators.generic_calculator"
--------------------------------------------------------------------------------

local Calculator = class("Calculator", GenericCalculator)

Calculator.required_inputs = {
  "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10",
  "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18", "f19", "f20",
  "f21"
}

--------------------------------------------------------------------------------
-- Vypocet (dle dodanych podkladu)
--------------------------------------------------------------------------------
-- Snahou je vypocet prevest tak, aby byl co nejpodobnejsi dodanym podkladum (az na drobna zjednoduseni, ktere snad zlepsi prehlednost)
--
-- Pole "body" a "vypoctene" odpovida dodanym podkladum (s tim rozdilem,
-- ze prvni prvek ma v Lua index 1, ne 0).
--
-- V promenne inp jsou ulozene zvalidovane a jiz na cisla prevedene vstupy (to se dela v generic_calculator.lua, ze ktereho tento kalkulator dedi)
--------------------------------------------------------------------------------
function Calculator:compute()
  local inp = self.inputs

  local body = {}
  local vypoctene = {}

  vypoctene[1] = inp.f1 + inp.f2
  body[1]      = math.abs(inp.f1 - inp.f2)

  local avg_1_2 = (inp.f1 + inp.f2) / 2

  if inp.f3 <= avg_1_2 then
    vypoctene[2] = inp.f3
  else
    vypoctene[2] = avg_1_2
    body[10]     = inp.f3 - avg_1_2
  end

  body[2]      = inp.f4 + inp.f5 + inp.f6 + inp.f7

  vypoctene[4] = inp.f8 + inp.f9
  body[3]      = math.abs(inp.f8 - inp.f9)

  vypoctene[5] = inp.f10 + inp.f11
  body[4]      = math.abs(inp.f10 - inp.f11)
--
  vypoctene[6] = inp.f12 + inp.f13
  body[5]      = math.abs(inp.f12 - inp.f13)

  vypoctene[7] = inp.f14 + inp.f15
  body[6]      = math.abs(inp.f14 - inp.f15)

  vypoctene[8] = inp.f16 + inp.f17
  body[7]      = math.abs(inp.f16 - inp.f17)

  vypoctene[9] = inp.f18 + inp.f19
  body[8]      = math.abs(inp.f18 - inp.f19)

  vypoctene[10] = inp.f20 + inp.f21
  body[9]      = math.abs(inp.f20 - inp.f21)

  -- todo: tady v cyklu by zrejme mela byt max hodnota 10 a ne 11,
  -- ale nema to vliv a v podkladech to je takhle
  self.kladne = 0
  for i = 1, 11 do
    self.kladne = self.kladne + (vypoctene[i] or 0)
  end

  self.zaporne = 0
  for i = 1, 11 do
    self.zaporne = self.zaporne + (body[i] or 0)
  end

  self.soucet  = self.kladne - self.zaporne

  if self.soucet < 300 then
    self.medal = "none"

  elseif self.soucet < 350 then
    self.medal = "bronze"

  elseif self.soucet < 400 then
    self.medal = "silver"

  else
    self.medal = "gold"
  end

  self.vypoctene = vypoctene
  self.body      = body
end

return Calculator
