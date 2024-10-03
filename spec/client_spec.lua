describe("client", function()
  local meta, t, mongo
  setup(function()
    meta = require "meta"
    meta.log.report=true
    meta.errors(true)
    t = assert(require "t", "require: t")
    t.env.MONGO_HOST='127.0.0.1'
    t.env.MONGO_PORT=27016
    mongo = t.storage.mongo
  end)
  it("env", function()
    t.env.MONGO_CONNSTRING=nil
    assert.equal('127.0.0.1', t.env.MONGO_HOST)
    assert.equal('27016', t.env.MONGO_PORT)
  end)
  it("connect", function()
    assert.is_true(toboolean(mongo))
    assert.is_true(toboolean(mongo()))
  end)
  it("create", function()
    assert.not_nil(mongo)
    assert.equal('t/storage/mongo', t.type(mongo))
    assert.equal('t/storage/mongo', t.type(mongo()))
  end)
  it("connect", function()
    assert.truthy(mongo())
    assert.truthy(mongo.auth)
  end)
end)
