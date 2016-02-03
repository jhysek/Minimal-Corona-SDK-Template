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
  "sync_state",
  "sort_date"
})
db.db:exec("ALTER TABLE ratings ADD COLUMN age")
db.db:exec("ALTER TABLE ratings ADD COLUMN positive")
db.db:exec("ALTER TABLE ratings ADD COLUMN negative")
db.db:exec("ALTER TABLE ratings ADD COLUMN contact")
db.db:exec("ALTER TABLE ratings ADD COLUMN sync_state")
db.db:exec("ALTER TABLE ratings ADD COLUMN sort_date")

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
  "premium",
  "with_ads"
})
db.db:exec("ALTER TABLE settings ADD COLUMN with_ads")

Rating:all(function(rating)
  if not rating.sort_date then
    local date_parts = rating.date:split(".")
    local date = string.format("%04d", date_parts[3]) ..
                 string.format("%02d", date_parts[2]) ..
                 string.format("%02d", date_parts[1])

    Rating:update(rating.id, { sort_date = date })
  end
end)
