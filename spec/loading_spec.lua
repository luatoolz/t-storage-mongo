describe("loading", function()
  local t, storage, mongo, driver
  setup(function()
    t = require "t"
    storage = t.storage
    mongo = storage.mongo
    driver = require "mongo"
  end)
  it("ok", function()
    assert(driver)
    assert.loader(storage)
    assert.table(mongo)
  end)
  it("records", function()
    local coll = mongo.coll
--    assert.bulk(coll[{}])
  end)
end)
