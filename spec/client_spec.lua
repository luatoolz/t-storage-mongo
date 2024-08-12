describe("client", function()
  local t, mongo
  setup(function()
    t = require "t"
    t.env.MONGO_HOST='127.0.0.1'
    mongo = t.storage.mongo
  end)
  it("env", function()
    assert.equal('127.0.0.1', t.env.MONGO_HOST)
  end)
  it("connect", function()
    assert.is_true(toboolean(mongo))
    assert.is_true(toboolean(mongo()))
  end)
  it("create", function()
    assert.not_nil(mongo)
    assert.equal('t/storage/mongo', t.type(mongo))
    assert.equal('t/storage/mongo', t.type(mongo()))
    assert.factory(mongo)
  end)
end)
