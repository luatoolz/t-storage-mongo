describe("client", function()
  local t, is, mongo, meta
  setup(function()
    t = require "t"
    is = t.is
    meta = require "meta"
    mongo = t.storage.mongo
  end)
  before_each(function()
    t.env.MONGO_CONNSTRING=nil
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

--    local mongo = require "mongo"
--    assert.equal('', mongo.ObjectID():hash())
--    local oid = debug.getmetatable(mongo.ObjectID())
--    assert.equal('', oid)
--local inspect = require "inspect"
--print(inspect(debug.getmetatable(oid)))
  end)
end)
