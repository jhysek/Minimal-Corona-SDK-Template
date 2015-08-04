local DB = require "lib.database"
local db = DB:create()

Rating = db:newModel("ratings", {
  "id",
  "date",
  "hunter",
  "animal",
  "rating",
  "medal"
})

Setting = db:newModel("settings", {
  "premium"
})

