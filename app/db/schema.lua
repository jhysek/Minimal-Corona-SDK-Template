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
  "picture3",
  "age",
  "positive",
  "negative",
  "contact",
  "synchronized_at"
})
db.db:exec("ALTER TABLE ratings ADD COLUMN age")
db.db:exec("ALTER TABLE ratings ADD COLUMN positive")
db.db:exec("ALTER TABLE ratings ADD COLUMN negative")
db.db:exec("ALTER TABLE ratings ADD COLUMN contact")
db.db:exec("ALTER TABLE ratings ADD COLUMN synchronized_at")

InputValue = db:newModel("input_values", {
  "rating_id",
  "key",
  "value"
})

Purchase = db:newModel("purchases", {
  "product",
  "date"
})

Setting = db:newModel("settings", {
  "premium"
})

