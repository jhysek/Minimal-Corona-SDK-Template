--------------------------------------------------------------------------------
local class             = require "lib.middleclass"
local GenericCalculator = require "app.calculators.generic_calculator"
--------------------------------------------------------------------------------

local Calculator = class("Calculator", GenericCalculator)

Calculator.required_inputs = {
  "atyp", "f01", "f02", "f03", "f04", "f05", "f06", "f07", "f08", "f09", "f10",
  "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18", "f19", "f20",
  "f21", "f22", "f23", "f24", "f25", "f26"
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

  vypoctene[1] = math.min(inp.f01, math.max(inp.f03, inp.f04))

  if inp.atyp == 1 then
    vypoctene[2] = inp.f02
  else
    body[2] = inp.f02
  end

  vypoctene[3] = inp.f03
  vypoctene[4] = inp.f04
  body[3]      = math.abs(inp.f03 - inp.f04)

  vypoctene[5] = inp.f05
  vypoctene[6] = inp.f06
  body[4]      = math.abs(inp.f05 - inp.f06)

  vypoctene[7] = inp.f07
  vypoctene[8] = inp.f08
  body[5]      = math.abs(inp.f07 - inp.f08)

  vypoctene[9] = inp.f09
  vypoctene[10] = inp.f10
  body[6]      = math.abs(inp.f09 - inp.f10)

  vypoctene[11] = inp.f11
  vypoctene[12] = inp.f12
  body[7]      = math.abs(inp.f11 - inp.f12)

  vypoctene[13] = inp.f13
  vypoctene[14] = inp.f14
  body[8]      = math.abs(inp.f13 - inp.f14)

  vypoctene[15] = inp.f15
  vypoctene[16] = inp.f16
  body[9]      = math.abs(inp.f15 - inp.f16)

  vypoctene[17] = inp.f17
  vypoctene[18] = inp.f18
  body[10]      = math.abs(inp.f17 - inp.f18)

  vypoctene[19] = inp.f19
  vypoctene[20] = inp.f20
  body[11]      = math.abs(inp.f19 - inp.f20)

  vypoctene[21] = inp.f21
  vypoctene[22] = inp.f22
  body[12]      = math.abs(inp.f21 - inp.f22)

  vypoctene[23] = inp.f23
  vypoctene[24] = inp.f24
  body[13]      = math.abs(inp.f23 - inp.f24)

  vypoctene[25] = inp.f25
  vypoctene[26] = inp.f26
  body[14]      = math.abs(inp.f25 - inp.f26)

  self.kladne = 0
  for i = 1, 26 do
    self.kladne = self.kladne + (vypoctene[i] or 0)
  end

  self.zaporne = 0
  for i = 1, 14 do
    self.zaporne = self.zaporne + (body[i] or 0)
  end

  self.soucet  = self.kladne - self.zaporne

  if inp.atyp == 1 then
    if self.soucet < 330 then
      self.medal = "none"

    elseif self.soucet < 350 then
      self.medal = "bronze"

    elseif self.soucet < 370 then
      self.medal = "silver"

    else
      self.medal = "gold"
    end
  else

    if self.soucet < 260 then
      self.medal = "none"

    elseif self.soucet < 280 then
      self.medal = "bronze"

    elseif self.soucet < 300 then
      self.medal = "silver"

    else
      self.medal = "gold"
    end
  end

  self.vypoctene = vypoctene
  self.body      = body
end

return Calculator
