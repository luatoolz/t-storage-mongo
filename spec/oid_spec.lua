describe("collection", function()
  local t, is, mongo, driver, oid, inspect, mongo_type
  setup(function()
    driver = require 'mongo'
    t = require "t"
    is = t.is
    mongo = require "t.storage.mongo"
    oid = mongo.oid
--    oid = t.fn.combined(tostring, string.null, mongo.ObjectID)
    inspect = require "inspect"
    mongo_type = require "t.storage.mongo.type"
  end)
  it("oid", function()
    local id = '66909d26cbade70b6b022b9a'
    assert.is_true(is.oid(id))
    assert.equal('function', type(driver.type))

    assert.equal('table', type(mongo_type))
    assert.equal('table', type(t.type))
    assert.equal(mongo_type, t.type)

--    assert.equal('', mongo.type)
--    _ = mongo - 'type'
    assert.equal('mongo.ObjectID', mongo.type(oid(id)) )
--    assert.is_true(mongo.type(oid(id)) == 'mongo.ObjectID')
    assert.same({_id = mongo.ObjectID(id)}, {_id = oid(id)})
  end)
  it("tojson", function()
    local oid = mongo.ObjectID()

    assert.equal('function', type(mongo.ObjectID))
    assert.equal('userdata', type(oid))

    local mt = debug.getmetatable(oid)
    mt.__tojson = function(self) return tostring(self) end
    mt.__toJSON = mt.__tojson

    assert.is_function(debug.getmetatable(oid).__toJSON)
    local moid = mongo.ObjectID('66909d26cbade70b6b022b9a')
    assert.equal('66909d26cbade70b6b022b9a', tostring(moid))
    assert.equal('66909d26cbade70b6b022b9a', debug.getmetatable(moid).__tojson(moid))
  end)
--[[
  it("tobson", function()
    local bson = mongo.BSON {}
    assert.equal('function', type(mongo.BSON))
    assert.equal('userdata', type(bson))

    local mt = debug.getmetatable(bson)
    assert.equal('', debug.getmetatable(bson))
--    mt.__tojson = function(self) return tostring(self) end
--    mt.__toJSON = mt.__tojson

--    assert.is_function(debug.getmetatable(oid).__toJSON)
--    local moid = mongo.ObjectID('66909d26cbade70b6b022b9a')
--    assert.equal('66909d26cbade70b6b022b9a', debug.getmetatable(moid).__tojson(moid))
  end)
--]]
  it("collection", function()
    local client = assert(driver.Client('mongodb://mongodb'))
    local coll = assert(client:getCollection('test', 'test'))
    assert.equal('userdata', type(coll))
--    assert.equal('', debug.getmetatable(coll))
  end)
  it("bulk", function()
    local client = assert(driver.Client('mongodb://mongodb'))
    local coll = assert(client:getCollection('test', 'test'))
    local bulk = assert(coll:createBulkOperation())
--    assert.equal('', debug.getmetatable(bulk))
  end)
  it("bson", function()
    local client = assert(driver.Client('mongodb://mongodb'))
    local coll = assert(client:getCollection('test', 'test'))
    local bson = driver.BSON {a='x', b=77}
--for k,v in pairs(bson) do print(k,v) end
--    assert.equal('', bson:find('*'))
--    assert.equal('', debug.getmetatable(bson))
  end)
  it("cursor", function()
    local client = assert(driver.Client('mongodb://mongodb'))
    local coll = assert(client:getCollection('test', 'test'))
    local cursor = assert(coll:find({}))
    assert.equal('userdata', type(cursor))
    assert.equal('mongo.Cursor', t.type(cursor))
--    assert.equal('', debug.getmetatable(cursor))
  end)
  it("int64", function()
    local int64 = driver.Int64
    local i = int64(77)

    assert.equal('function', type(int64))
    assert.equal('table', type(i))
--    assert.equal('77', tostring(i))
    assert.equal(77, i[1])
--    assert.equal('77', inspect(i))
--    assert.equal('', debug.getmetatable(i))
  end)
end)
