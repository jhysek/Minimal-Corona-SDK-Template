--------------------------------------------------------------------------------
local _     = require "lib.underscore"
local class = require "lib.middleclass"
--------------------------------------------------------------------------------

local Model = class("Model")

function Model:initialize(db, tableName, attributes)
  self.db = db
  self.tableName = tableName
  self.attributes = attributes

  local tableSetup = "CREATE TABLE " .. tableName
  tableSetup = tableSetup .. " (id INTEGER PRIMARY KEY"
  _.each(attributes, function(a)
    if (a ~= "id") then
      tableSetup = tableSetup .. ", " .. a
    end
  end)
  tableSetup = tableSetup .. ");"

  db:exec(tableSetup)
end

local function tableToString(conditions, delimiter)
  local conds = {}
  conditions = conditions or {}

  for k,v in pairs(conditions) do
    if k == "SQL" then
      conds[#conds + 1] = "(" .. v .. ")"
    else
      conds[#conds + 1] = k .. " = \"" .. tostring(v) .. "\""
    end
  end
  return _.join(conds, delimiter)
end

local function conditionsToSQL(conditions, exclude_conditions)
  local conds    = tableToString(conditions, " AND ")
  local ex_conds = tableToString(exclude_conditions, " AND ")

  result = ""
  if string.len(conds) > 0 or string.len(ex_conds) > 0 then
    result = result .. " WHERE " .. conds

    if string.len(ex_conds) > 0 then
      if string.len(conds) > 0 then
        result = result .. " AND "
      end
      result = result .. " NOT (" .. ex_conds .. ")"
    end
  end

  return result
end

local function updateToSQL(attributes)
  attributes.id = nil
  return tableToString(attributes, ", ")
end

function Model:ordering()
  if self.orderBy then
    return " ORDER BY " .. self.orderBy .. " "
  else
    return ""
  end
end

function Model:aggregate(fun, conditions, exclude_conditions, attribute)
  local aggregation_functions = {avg = true, sum = true, count = true, min = true, max = true}
  attribute = attribute or "*"
  conditions = conditions or {}

  if aggregation_functions[fun] then
    local query = "SELECT " .. fun .. "(" .. attribute .. ") as r FROM " .. self.tableName .. conditionsToSQL(conditions, exclude_conditions)
    for row in self.db:nrows(query) do
      if row and row.r then
        return tonumber(row.r)
      end
    end
  end
  return 0
end

function Model:count(conditions, exclude_conditions)
  return self:aggregate("count", conditions, exclude_conditions)
end

function Model:sum(attribute, conditions, exclude_conditions)
  return self:aggregate("count", conditions, exclude_conditions, attribute)
end

function Model:avg(attribute, conditions, exclude_conditions)
  return self:aggregate("avg", conditions, exclude_conditions, attribute)
end

function Model:min(attribute, conditions, exclude_conditions)
  return self:aggregate("min", conditions, exclude_conditions, attribute)
end

function Model:max(attribute, conditions, exclude_conditions)
  return self:aggregate("max", conditions, exclude_conditions, attribute)
end

function Model:all(rowCallback, conditions, exclude_conditions)
  for row in self.db:nrows("SELECT * FROM " .. self.tableName .. conditionsToSQL(conditions, exclude_conditions) .. self:ordering()) do
    rowCallback(row)
  end
end

function Model:allArray(conditions, exclude_conditions)
  local result = {}
  self:all(function(r) result[#result + 1] = r end, conditions, exclude_conditions)
  return result
end

function Model:where(conditions, rowCallback)
  local query = "SELECT * FROM " .. self.tableName .. conditionsToSQL(conditions, exclude_conditions) .. self:ordering()
  for row in self.db:nrows(query) do
    rowCallback(row)
  end
end

function Model:get(id)
  for row in self.db:nrows("SELECT * FROM " .. self.tableName .. " WHERE id = " ..  id) do
    return row
  end
end

function Model:find(conditions, exclude_conditions)
  for row in self.db:nrows("SELECT * FROM " .. self.tableName .. conditionsToSQL(conditions, exclude_conditions)) do
    return row
  end
  return nil
end

function Model:join(joinSQL, conditions, rowCallback)
  local query = "SELECT * FROM " .. self.tableName .. " JOIN " .. joinSQL .. " " .. conditionsToSQL(conditions, {}) .. self:ordering()
  print("JOIN QUERY: " .. query)
  for row in self.db:nrows(query) do
    rowCallback(row)
  end
end

function Model:first(conditions)
  return self:find(conditions)
end

function Model:insert(attributes)
  local values = {}
  local columnNames = {}

  _.each(self.attributes, function(a)
    if attributes[a] then
      values[#values + 1] = "\"" .. attributes[a] .. "\""
      columnNames[#columnNames + 1] = a
    end
  end)

  local query = "INSERT INTO " .. self.tableName .. "(" .. _.join(columnNames, ",") ..  ") VALUES ( " .. _.join(values, ", ") .. ")"
  self.db:exec(query)

  local record_id = self.db:last_insert_rowid()

  if type(self.afterInsert) == "function" then
    self.afterInsert(record_id)
  end

  return record_id
end

function Model:create(attrs)
  return self:insert(attrs)
end


function Model:update(id, attributes)
  local existing_attributes = {}

  _.each(self.attributes, function(a)
    if attributes[a] then
      existing_attributes[a] = attributes[a]
    end
  end)

  local query = "UPDATE " .. self.tableName ..  " SET " .. updateToSQL(existing_attributes) .. " WHERE id = \"" .. id .. "\""
  print("[DB] " .. query)
  self.db:exec(query)
end

function Model:updateAll(conditions, attributes)
  local query = "UPDATE " .. self.tableName ..  " SET " .. updateToSQL(attributes) .. conditionsToSQL(conditions)
  self.db:exec(query)
end

function Model:delete(conditions, exclude_conditions)
  local query = "DELETE FROM " .. self.tableName .. conditionsToSQL(conditions, exclude_conditions)
  local errcode = self.db:exec(query)
end

return Model
