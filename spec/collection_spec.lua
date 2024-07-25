describe("collection", function()
  local t, is, mongo, iter, coll
  setup(function()
    t = require "t"
    t.env.MONGO_CONNSTRING=nil
    require "t.storage.mongo.connection"
    t.env.MONGO_HOST='127.0.0.1'
    is = t.is
    mongo = t.storage.mongo
    iter = mongo.iter
    coll = mongo.coll
  end)
  before_each(function()
    t.env.MONGO_CONNSTRING=nil
    _ = -mongo.coll
  end)
  it("type", function()
    assert.not_nil(mongo)
    assert.equal('t/storage/mongo', t.type(mongo))
    assert.equal('t/storage/mongo', t.type(mongo()))
    assert.is_true(is.factory(mongo))
    assert.equal('t/storage/mongo/collection', t.type(mongo.collection))
    assert.equal('t/storage/mongo/collection', t.type(mongo.coll))
  end)
  it("mt", function()
    local o = mongo.ObjectID()
    assert.not_nil(getmetatable(o))
    if debug and debug.getmetatable then
      assert.is_table(debug.getmetatable(mongo.ObjectID()))
    end
    assert.equal('t/storage/mongo/collection', t.type(coll))
    assert.is_true(toboolean(mongo))
    assert.is_true(toboolean(mongo()))
  end)
  it("findOne", function()
    assert.equal(0, tonumber(-coll))
    assert.is_false(toboolean(coll))
    _ = coll + {test=true}
    assert.equal(1, tonumber(coll))
    assert.equal(1, tonumber(coll[{}]))
    assert.is_true(toboolean(coll))

    local id = mongo.ObjectID('6690c3c574d428e23e0493c7')
    local a,b
    coll[id] = {name='some', try=5}
    a=coll[id]

    coll[id]=nil
    coll[id] = {_id=id, name='some', try=5}
    b=coll[id]

    assert.equal(2, tonumber(coll))
    coll[id]=nil
    assert.equal(1, tonumber(coll))

    assert.same(a, b)

    assert.equal(1, tonumber(coll))
    assert.equal(false, toboolean(coll[id]))
    coll[id]=nil

    assert.is_nil(coll[nil])

    assert.equal(0, tonumber(-coll))
  end)
  it("insert", function()
    assert.equal(0, tonumber(coll))
    local id = mongo.ObjectID('66909d26cbade70b6b022b9b')

    assert.equal(1, tonumber(coll + {_id=id, name='some', try=5}))
    assert.equal(0, tonumber(coll-id))

    local _id=mongo.ObjectID()
    _ = coll + {_id=_id, name='some', try=1}
    assert.equal(1, coll-0)
    assert.equal(true, toboolean(coll[{_id=_id}]))

    _ = coll + {name='some', try=2} + {name='some', try=3}
    assert.equal(3, tonumber(coll))

    _ = coll .. {{name='some', try=4}, {name='some', try=5}}
    assert.equal(5, tonumber(coll))

    assert.equal(4, tonumber(coll - {try=5}))

    assert.is_table(coll[_id])
    assert.is_table(coll[tostring(_id)])
    assert.same(coll[_id], coll[tostring(_id)])

    local it = iter(coll[{}])
    assert.is_function(it)
    assert.same({{try=1},{try=2},{try=3},{try=4},}, table.map(it, function(x) x._id=nil; x.name=nil; return x end))

    assert.equal(4, tonumber(coll[{}]))
    assert.equal(4, tonumber(coll['']))
    assert.equal(4, tonumber(coll['*']))

    assert.equal(coll[''], coll[{}])
    assert.equal(coll['*'], coll[{}])

    assert.equal('', {table.map(coll['*']), table.map(coll['']), table.map(coll[{}]) })

    assert.same(table.map(coll['']), table.map(coll[{}]))
    assert.same(table.map(coll['*']), table.map(coll[{}]))
  end)
  it("empty", function()
    assert.equal('t/storage/mongo/collection', t.type(coll))

    assert.equal(0, tonumber(coll))
    assert.equal(1, tonumber(coll + {name='some'}))
    assert.equal(0, tonumber(-coll))
    assert.equal(1, tonumber(coll + {name='some'}))
    assert.is_true(is.oid(table.map(iter(coll[{}]))[1]._id))
    assert.is_true(is.oid(coll[{}][1]._id))
    assert.oid(coll[1]._id)
    assert.oid(coll[{}][1]._id)

    assert.equal(1, coll+0)
    assert.equal(1, coll-0)

    assert.equal(0, tonumber(-coll))
  end)
  it("update", function()
    assert.equal('t/storage/mongo/collection', t.type(coll))
    assert.equal(0, tonumber(-coll))

    local ida = '66909d26cbade70b6b022b9a'
    local idb = '66909d26cbade70b6b022b9b'

    local id = mongo.ObjectID(idb)
    assert.equal(1, tonumber(coll + {_id=id, name='some'}))

    assert.equal('some', coll[id].name)
    assert.equal(0, coll % {_id=ida})
    assert.is_nil((coll[ida] or {}).name)
    coll[id]={name='first'}

    assert.is_true(is.oid(id))
    assert.is_table(coll[idb])

    assert.equal('first', coll[idb].name)
    assert.equal('first', coll[id].name)
    coll[id]={name='other'}
    assert.equal('other', coll[id].name)

    coll[id]='{"name":"other1"}'
    assert.equal('other1', coll[id].name)
    assert.equal(id, coll[id]._id)
    coll[id]=nil
    assert.is_nil(coll[id])

    coll[id]='{"name":"other1", "arr":[1,2,3,4,5,6,7]}'
    assert.equal(id, coll[id]._id)
    assert.equal(7, #coll[id].arr)
    coll[id]=nil
    assert.is_nil(coll[id])

    coll[id]='{"name":"other1", "arr":["a","b","c","d","e","f","g"]}'
    assert.equal(id, coll[id]._id)
    assert.equal(7, #coll[id].arr)
    coll[id]=nil
    assert.is_nil(coll[id])

    coll[id]={name='other1', arr={__array=true, "a","b","c","d","e","f","g"}}
    assert.equal(id, coll[id]._id)
    assert.equal(7, #coll[id].arr)
    coll[id]=nil
    assert.is_nil(coll[id])

    coll[id]={name='other1', arr={"a","b","c","d","e","f","g"}}
    assert.equal(id, coll[id]._id)
    assert.equal(7, #coll[id].arr)
    coll[id]=nil
    assert.is_nil(coll[id])

    assert.equal(0, tonumber(coll-id))
  end)
  it("records", function()
    assert.equal('t/storage/mongo/collection', t.type(coll))
    assert.equal(0, tonumber(-coll))

    assert.equal('t/storage/mongo/records', t.type(coll[{}]))
    assert.is_false(toboolean(coll[{}]))
    assert.equal(0, tonumber(coll[{}]))
    assert.is_false(tonumber(coll[{}]) > 0)

    _ = coll + {name='some'}
    assert.equal(1, tonumber(coll[{}]))
    assert.equal(1, tonumber(coll))

    _ = coll + {xname='some2'}
    assert.equal(2, tonumber(coll))
    assert.equal(2, tonumber(coll[{}]))
    assert.equal(2, tonumber(coll))
    assert.equal(2, coll[{}]+0)
    assert.equal(2, coll[{}]-0)

    local c=0
    for i,v in pairs(coll[{}]) do c=c+1 end
    assert.equal(2, c)

    c=0
    for v in iter(coll[{}]) do c=c+1 end
    assert.equal(2, c)

    assert.equal(0, tonumber(-coll[{}]))
    assert.equal(0, tonumber(coll))
    assert.equal(0, coll[{}]+0)
    assert.equal(0, coll[{}]-0)
  end)
end)
