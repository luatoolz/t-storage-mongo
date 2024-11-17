describe("connection", function()
  local t, is, is2, mongo, mongo2, mongo3, connection1, connection2
  setup(function()
    t = require "t"
    t.env.MONGO_HOST='mongodb'
    t.env.MONGO_PORT=27017
    is = t.is
    is2 = require "t/is"
    meta = require "meta"
    mt = meta.mt
    cache = meta.cache
    mongo = t.storage.mongo
    mongo2 = require "t.storage.mongo"
    mongo3 = require "t/storage/mongo"
    connection1 = mongo.connection
    connection2 = require "t.storage.mongo.connection"
  end)
  after_each(function()
    t.env.MONGO_CONNSTRING=nil
  end)
  it("connstring", function()
    assert.not_nil(mongo)
    assert.equal(is, is2)

    assert.is_true(is.factory(mongo))
    assert.truthy(is.factory(t.storage.mongo))

    assert.equal(mongo2, mongo)
    assert.equal(mongo2, mongo3)
    assert.equal(mongo3, mongo)

    assert.equal('storage/mongo', t.type(mongo))
    assert.equal('storage/mongo', t.type(mongo2))
    assert.equal('storage/mongo', t.type(mongo3))

    assert.equal('storage/mongo', cache.type[mongo])
    assert.equal('storage/mongo', cache.type[mongo2])
    assert.equal('storage/mongo', cache.type[mt(mongo2)])
    assert.equal('storage/mongo', cache.type[cache.instance[mongo3]])

    assert.equal('storage/mongo/connection', t.type(connection1))
    assert.equal('storage/mongo/connection', t.type(connection2))
    assert.equal(getmetatable(connection2), getmetatable(connection1))
    assert.equal(connection2, connection1)
    assert.is_nil(mongo.connection.noneexistent)
  end)
  it("has loader", function()
    assert.is_table(cache.loader[mongo])
    assert.is_table(cache.loader[getmetatable(mongo)])
  end)
  it("connstring", function()
    assert.equal('mongodb://mongodb:27017/db', tostring(mongo.connection))
    assert.equal(tostring(mongo.connection), tostring(mongo.connection()))
  end)
  it("connstring +MONGO_HOST", function()
    t.env.MONGO_HOST='othermongo'
    assert.equal('mongodb://othermongo:27017/db', tostring(mongo.connection))
    assert.equal(tostring(mongo.connection), tostring(mongo.connection()))
  end)
  it("connstring +MONGO_USER", function()
    t.env.MONGO_USER='user'
    assert.equal('mongodb://user@othermongo:27017/db', tostring(mongo.connection))
    assert.equal(tostring(mongo.connection), tostring(mongo.connection()))
  end)
  it("connstring +MONGO_PASS", function()
    t.env.MONGO_PASS='pass'
    assert.equal('mongodb://user:pass@othermongo:27017/db', tostring(mongo.connection))
    assert.equal(tostring(mongo.connection), tostring(mongo.connection()))
  end)
  it("connstring +MONGO_DB", function()
    t.env.MONGO_DB='db'
    assert.equal('mongodb://user:pass@othermongo:27017/db', tostring(mongo.connection))
    assert.equal(tostring(mongo.connection), tostring(mongo.connection()))
  end)
  describe("rev connstring", function()
    it("full", function()
      assert.same({
        connstring = "mongodb+srv://root:SECURE@srvdb:27018/data?var=value&second=another",
        db = "data",
        host = "srvdb",
        pass = "SECURE",
        port = "27018",
        prefix = "mongodb+srv://",
        user = "root",
        options='var=value&second=another',
      }, mongo.connection('mongodb+srv://root:SECURE@srvdb:27018/data?var=value&second=another'))
    end)
    it("no options", function()
      assert.same({
        connstring = "mongodb+srv://root:SECURE@srvdb:27018/data",
        db = "data",
        host = "srvdb",
        pass = "SECURE",
        port = "27018",
        prefix = "mongodb+srv://",
        user = "root",
      }, mongo.connection('mongodb+srv://root:SECURE@srvdb:27018/data?'))
    end)
    it("no db", function()
      assert.same({
        connstring = "mongodb://root:SE%40CURE@srvdb:27018",
        host = "srvdb",
        pass = "SE%40CURE",
        port = "27018",
        prefix = "mongodb://",
        user = "root",
      }, mongo.connection('mongodb://root:SE@CURE@srvdb:27018/'))
    end)
    it("no auth", function()
      assert.same({
        connstring = "mongodb://srvdb:27018",
        host = "srvdb",
        port = "27018",
        prefix = "mongodb://",
      }, mongo.connection('mongodb://srvdb:27018/'))
    end)
    it("no port", function()
      assert.same({
        connstring = "mongodb://srvdb",
        host = "srvdb",
        prefix = "mongodb://",
      }, mongo.connection('mongodb://srvdb/'))
    end)
    it("no prefix", function()
      assert.same({
        connstring = "mongodb://srvdb",
        host = "srvdb",
        prefix = "mongodb://",
      }, mongo.connection('srvdb/'))
    end)
  end)
  it("full multihost", function()
    assert.same({
      connstring = "mongodb://myDatabaseUser:D1fficultP%40ssw0rd@db0.example.com:27017,db1.example.com:27017,db2.example.com:27017/?replicaSet=myRepl",
      hosts = {'db0.example.com:27017', 'db1.example.com:27017', 'db2.example.com:27017'},
      pass = "D1fficultP%40ssw0rd",
      prefix = "mongodb://",
      user = "myDatabaseUser",
      options='replicaSet=myRepl',
    }, mongo.connection('mongodb://myDatabaseUser:D1fficultP%40ssw0rd@db0.example.com:27017,db1.example.com:27017,db2.example.com:27017/?replicaSet=myRepl'))
  end)
  it("single host", function()
    assert.same({
      connstring = "mongodb+srv://myDatabaseUser:D1fficultP%40ssw0rd@server.example.com",
      host = 'server.example.com',
      pass = "D1fficultP%40ssw0rd",
      prefix = "mongodb+srv://",
      user = "myDatabaseUser",
    }, mongo.connection('mongodb+srv://myDatabaseUser:D1fficultP%40ssw0rd@server.example.com/'))
  end)
end)