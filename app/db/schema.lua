local DB = require "lib.database"
local db = DB:create()

Rating = db:newModel("ratings", {
  "id",
  "date",
  "hunter",
  "animal",
  "rating",
  "medal",
  "created_at",
  "place",
  "country",
  "picture1",
  "picture2",
  "picture3"
})

Purchase = db:newModel("purchases", {
  "product",
  "date"
})

Setting = db:newModel("settings", {
  "premium"
})

