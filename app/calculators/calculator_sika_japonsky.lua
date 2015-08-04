--------------------------------------------------------------------------------
-- totozny kalkulator jako v calculator_sika => kompletne jej zdedim.
-- Jde jen o nazev souboru - je nacten vzdy kalkulator ze souboru
-- calculators/calculator_{kod zvere}.lua.
--
-- V podkladech je zvlast syka dybowskeho a sika japonsky, ale vypocty jsou uplne stejne.
--------------------------------------------------------------------------------
local CalculatorSika = require "app.calculators.calculator_sika"

return class("Calculator", CalculatorSika)
