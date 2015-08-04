--------------------------------------------------------------------------------
local class = require "lib.middleclass"
local _     = require "lib.underscore"
--------------------------------------------------------------------------------

local GenericCalculator = class("GenericCalculator")

function GenericCalculator:initialize(inputs)
  self.outputs = {}
  self.inputs = {}
  for key, value in pairs(inputs) do
    self.inputs[key] = tonumber(string.gsub(value, ",", "."), 10)
  end
end

function GenericCalculator:compute()
  -- tato funkce bude doplnena ve zdedene tride...
end

function GenericCalculator:run()
  if self:validate() then
    self.medal = "none"
    self:compute()
  else
    if self.onValidationFailed then
      self.onValidationFailed()
    end
  end
end

function GenericCalculator:validate()
  if self.required_inputs then
    for i = 1, #self.required_inputs do
      -- TODO: validace
    end
  end
  return true
end

return GenericCalculator
