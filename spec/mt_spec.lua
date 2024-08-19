describe("collection", function()
  local t, is, mongo, driver, oid, mongo_type, json
  setup(function()
    t = require "t"
    t.env.MONGO_HOST='127.0.0.1'
    is = t.is
    driver = require 'mongo'
    mongo = require "t.storage.mongo"
    oid = mongo.oid
    mongo_type = require "t.storage.mongo.type"
    json = t.format.json
  end)
  it("oid", function()
    local id = '66909d26cbade70b6b022b9a'
    assert.is_true(is.oid(id))
    assert.equal('function', type(driver.type))

    assert.equal('table', type(mongo_type))
    assert.equal('table', type(t.type))
    assert.equal(mongo_type, t.type)

    assert.equal('mongo.ObjectID', mongo.type(oid(id)) )
    assert.is_true(mongo.type(oid(id)) == 'mongo.ObjectID')
    assert.same({_id = mongo.ObjectID(id)}, {_id = oid(id)})
  end)
  it("tojson", function()
    local moid = mongo.ObjectID()

    assert.equal('function', type(mongo.ObjectID))
    assert.equal('userdata', type(moid))

    local mt = debug.getmetatable(moid)
    assert.is_function(debug.getmetatable(moid).__tojson)
    moid = mongo.ObjectID('66909d26cbade70b6b022b9a')
    assert.equal('66909d26cbade70b6b022b9a', tostring(moid))
    assert.equal('66909d26cbade70b6b022b9a', debug.getmetatable(moid).__tojson(moid))
  end)
  it("tobson", function()
    local bson = mongo.BSON {}
    assert.equal('function', type(mongo.BSON))
    assert.equal('userdata', type(bson))
    assert.is_table(debug.getmetatable(bson))
  end)
  it("collection", function()
    local client = assert(driver.Client('mongodb://localhost'))
    local coll = assert(client:getCollection('test', 'test'))
    assert.equal('userdata', type(coll))
    assert.is_table(debug.getmetatable(coll))
  end)
  it("bulk", function()
    local client = assert(driver.Client('mongodb://localhost'))
    local coll = assert(client:getCollection('test', 'test'))
    local bulk = assert(coll:createBulkOperation())
    assert.is_table(debug.getmetatable(bulk))
  end)
  it("bson", function()
    local bson = driver.BSON {a='x', b=77}
    assert.is_table(debug.getmetatable(bson))
  end)
  it("cursor", function()
    local tocursor = require "t.storage.mongo.cursor"

    local client = assert(driver.Client('mongodb://localhost'))
    local coll = assert(client:getCollection('test', 'test'))
    local cursor = tocursor(assert(coll:find({})))

    assert.equal('userdata', type(cursor))
    assert.equal('mongo.Cursor', t.type(cursor))
    assert.equal('[]', tojson(cursor))
  end)
  it("int64", function()
    local int64 = driver.Int64
    local i = int64(77)

    assert.equal('function', type(int64))
    assert.equal('table', type(i))
    assert.equal(77, i[1])
    assert.equal('mongo.Int64(77)', tostring(i))
    assert.is_table(debug.getmetatable(i))
  end)
end)
