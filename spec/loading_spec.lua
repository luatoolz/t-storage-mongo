describe("loading", function()
  local t, is, storage, mongo, driver
  setup(function()
    t = require "t"
    is = t.is
    t.env.MONGO_HOST='127.0.0.1'
    t.env.MONGO_PORT=27016
    storage = t.storage
    mongo = storage.mongo
    driver = require "mongo"
  end)
  it("ok", function()
    assert(driver)
    assert.loader(storage)
    assert.table(mongo)

    local bb = {
      nInserted  = 1,
      nMatched   = 2,
      nModified  = 4,
      nRemoved   = 8,
      nUpserted  = 16,
      writeErrors={}}

    assert.falsy(is.bulkresult({}))
    assert.bulkresult(mongo.bulkresult(bb))
    assert.truthy(is.bulkresult(mongo.bulkresult(bb)))
  end)
end)