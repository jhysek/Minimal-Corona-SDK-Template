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

Purchase = db:newModel("purchases", {
  "product",
  "date"
})

Setting = db:newModel("settings", {
  "premium"
})

