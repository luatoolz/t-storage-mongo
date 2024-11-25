describe("client", function()
  local t, mongo, to
  setup(function()
    t = require "t"
    t.env.MONGO_HOST='127.0.0.1'
    t.env.MONGO_PORT=27016
    mongo = t.storage.mongo
    to = t.to
  end)
  it("env", function()
    t.env.MONGO_CONNSTRING=nil
    assert.equal('127.0.0.1', t.env.MONGO_HOST)
    assert.equal('27016', t.env.MONGO_PORT)
  end)
  it("connect", function()
    assert.is_true(to.boolean(mongo))
    assert.is_true(to.boolean(mongo()))
  end)
  it("create", function()
    assert.not_nil(mongo)
    assert.equal('storage/mongo', t.type(mongo))
    assert.equal('storage/mongo', t.type(mongo()))
  end)
  it("connect", function()
    assert.truthy(mongo())
    assert.truthy(mongo.auth)
  end)
  it("command", function()
    local data = mongo.data
    _ = -data
    _ = data + {x='x'}
    local client = mongo()._client
    local r,e = assert(client:command('db', {createIndexes='data'},
      {indexes={
        __array=true,
        {key={x=1}, name='idx', unique=true}
      }
    }))
    assert.equal('{ "numIndexesBefore" : 1, "numIndexesAfter" : 2, "createdCollectionAutomatically" : false, "ok" : 1.0 }', tostring(r))
    assert.is_nil(e)
    _ = -data
-- https://www.mongodb.com/docs/manual/core/indexes/create-index/specify-index-name/
-- https://www.mongodb.com/docs/manual/reference/command/createIndexes/#mongodb-dbcommand-dbcmd.createIndexes
  end)
end)