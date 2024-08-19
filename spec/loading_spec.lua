describe("loading", function()
  local t, storage, mongo, driver
  setup(function()
    t = require "t"
    t.env.MONGO_HOST='127.0.0.1'
    storage = t.storage
    mongo = storage.mongo
    driver = require "mongo"
  end)
  it("ok", function()
    assert(driver)
    assert.loader(storage)
    assert.table(mongo)
  end)
end)
