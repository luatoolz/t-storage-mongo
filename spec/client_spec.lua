describe("client", function()
  local t, is, mongo
  setup(function()
    t = require "t"
    t.env.MONGO_CONNSTRING=nil
    require "t.storage.mongo.connection"
    t.env.MONGO_HOST='127.0.0.1'
    is = t.is
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
    assert.is_true(is.factory(mongo))
  end)
end)
