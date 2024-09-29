local getmetatable=debug and debug.getmetatable or getmetatable
describe("collection", function()
  local t, mongo, driver, oid, mongo_type, json
  setup(function()
    t = require "t"
    t.env.MONGO_HOST='127.0.0.1'
    driver = require 'mongo'
    mongo = assert(require "t.storage.mongo")
    oid = mongo.oid
    mongo_type = assert(require "t.storage.mongo.type")
    json = assert(t.format.json)
  end)
  it("oid", function()
    local id = '66909d26cbade70b6b022b9a'
    assert.oid(id)
    assert.equal('function', type(driver.type))

    assert.equal('table', type(mongo_type))
    assert.equal('table', type(t.type))
    assert.equal(mongo_type, t.type)

    assert.equal('mongo.ObjectID', mongo_type(oid(id)) )
    assert.is_true(mongo.type(oid(id)) == 'mongo.ObjectID')
    assert.same({_id = driver.ObjectID(id)}, {_id = oid(id)})
  end)
  it("collection", function()
    local client = assert(driver.Client('mongodb://localhost'))
    local coll = assert(client:getCollection('test', 'test'))
    assert.equal('userdata', type(coll))
    assert.is_table(getmetatable(coll))
  end)
  it("database", function()
    local client = assert(driver.Client('mongodb://localhost'))
    local db = client:getDatabase('test')
    assert.is_table(getmetatable(db))
  end)
  it("bulk", function()
    local client = assert(driver.Client('mongodb://localhost'))
    local coll = assert(client:getCollection('test', 'test'))
    local bulk = assert(coll:createBulkOperation())
    assert.is_table(getmetatable(bulk))
  end)
  it("bson", function()
    local bson = driver.BSON {a='x', b=77}
    assert.is_table(getmetatable(bson))
  end)
  it("cursor", function()
    local tocursor = require "t.storage.mongo.cursor"

    local client = assert(driver.Client('mongodb://localhost'))
    local coll = assert(client:getCollection('test', 'test'))
    local cursor = tocursor(coll:find({}))

    assert.equal('userdata', type(cursor))
    assert.equal('mongo.Cursor', t.type(cursor))
    assert.equal('[]', json(cursor))
  end)
  it("int64", function()
    local int64 = driver.Int64
    local i = int64(77)

    assert.equal('function', type(int64))
    assert.equal('table', type(i))
    assert.equal(77, i[1])
    assert.equal('mongo.Int64(77)', tostring(i))
    assert.is_table(getmetatable(i))
  end)
end)
