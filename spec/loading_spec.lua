describe("loading", function()
  local t, is, storage, mongo, driver
  setup(function()
    t = require "t"
    is = t.is
    storage = t.storage
    mongo = storage.mongo
    driver = require "mongo"
  end)
  it("ok", function()
    assert(driver)
    assert.loader(storage)
  end)
end)
