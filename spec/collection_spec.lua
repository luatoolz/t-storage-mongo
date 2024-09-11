describe("collection", function()
  local t, is, mongo, iter, coll, json
  setup(function()
    t = require "t"
    t.env.MONGO_HOST='127.0.0.1'
    is = t.is
    mongo = t.storage.mongo
    iter = mongo.iter
    coll = mongo.coll
    json = t.format.json
  end)
  before_each(function()
    t.env.MONGO_CONNSTRING=nil
    coll = mongo.coll
    _ = -mongo.coll[{}]
  end)
  it("type", function()
    assert.is_table(t)
    assert.not_nil(mongo)
    assert.equal('t/storage/mongo', t.type(mongo))
    assert.equal('t/storage/mongo', t.type(mongo()))
    assert.factory(mongo)
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

    local a,b = mongo.coll, mongo.coll
    assert.same(a, b)
    assert.not_equal(a, b)
  end)
  it("findOne", function()
    assert.truthy(-coll)
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

    assert.equal('t/storage/mongo/records', t.type(coll[{}]))

    assert.truthy(-coll)
  end)
  it("insert", function()
    assert.equal(0, tonumber(coll))
    local id = mongo.ObjectID('66909d26cbade70b6b022b9b')

    assert.equal(1, tonumber(coll + {_id=id, name='some', try=5}))
    assert.truthy(coll-id)

    local _id=mongo.ObjectID()
    _ = coll + {_id=_id, name='some', try=1}

    assert.equal(true, toboolean(coll[{_id=_id}]))
    assert.equal(true, toboolean(coll[_id]))

    assert.equal(2, coll .. {{name='some', try=2}, {name='some', try=3}})
    assert.equal(3, tonumber(coll))

    assert.equal(2, coll .. {{name='some', try=4}, {name='some', try=5}})
    assert.equal(5, tonumber(coll))

    assert.is_true(coll - {try=5})

    assert.is_table(coll[_id])
    assert.oid(tostring(_id))
    assert.is_table(coll[tostring(_id)])
    assert.same(coll[_id], coll[tostring(_id)])

    local it = iter(coll[{}])
    assert.is_function(it)
    assert.same({{try=1},{try=2},{try=3},{try=4},}, table.map(it, function(x) x._id=nil; x.name=nil; return x end))

    assert.equal(4, tonumber(coll[{}]))
    assert.equal(4, tonumber(coll['*']))

    assert.equal(coll['*'], coll[{}])

    local aa=coll[{}]
    local bb=coll['*']

    local a=table.map(aa)
    local b=table.map(bb)

    assert.same(a, b)

    assert.same(table.map(coll['*']), table.map(coll[{}]))
    assert.equal(coll['*'], coll[{}])

    assert.equal(4, tonumber(coll[{}]))
    assert.truthy(-coll[{}])
    assert.equal(0, tonumber(coll[{}]))
    assert.equal(3, coll + ('[{"_id":"66ba9cdee46231517f065198","token":"95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7","role":"root"},' ..
      '{"_id":"66ba9cdee46231517f065199","token":"46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a","role":"traffer"},' ..
      '{"_id":"66ba9cdee46231517f06519a","token":"60879afb54028243bb82726a5485819a8bbcacd1df738439bfdf06bc3ea628d0","role":"panel"}]'))

--    assert.equal(3, tonumber(table.map(iter(coll[{}]))))
    assert.equal(3, tonumber(coll))

    local z = {
      ['{"_id":"66ba9cdee46231517f065198","role":"root","token":"95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7"}']=true,
      ['{"_id":"66ba9cdee46231517f065199","role":"traffer","token":"46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a"}']=true,
      ['{"_id":"66ba9cdee46231517f06519a","role":"panel","token":"60879afb54028243bb82726a5485819a8bbcacd1df738439bfdf06bc3ea628d0"}']=true,
    }
    local found = json(coll[{}]):lstrip('['):rstrip(']'):gsub('%}%,%{', '}|{'):split('|')
    assert.same(z, table.tohash(found))

    assert.equal(3, tonumber(coll[{}]))
    assert.oid('66ba9cdee46231517f065199')
    local o = mongo.ObjectID('66ba9cdee46231517f065199')

    assert.is_table(coll[o])
    assert.is_table(coll[{_id='66ba9cdee46231517f065199'}])
    assert.is_table(coll[{_id='66ba9cdee46231517f065199'}])
    assert.is_table(coll['66ba9cdee46231517f065199'])

    local dat = '[{"token":"95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7","role":"root"},' ..
                '{"token":"46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a","role":"traffer"},' ..
                '{"token":"60879afb54028243bb82726a5485819a8bbcacd1df738439bfdf06bc3ea628d0","role":"panel"}]'

    local jdat = json.decode(dat)
    assert.equal('95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7', jdat[1].token)

  end)
  it("empty", function()
    assert.equal('t/storage/mongo/collection', t.type(coll))

    assert.equal(0, tonumber(coll))
    assert.equal(0, coll % {})
    assert.equal(0, coll % nil)
    assert.equal(0, coll % '')
    assert.equal(0, coll % '*')
    assert.is_nil(coll.any)

    assert.equal(1, coll + {name='some'})
    assert.truthy(-coll)
    assert.equal(1, tonumber(coll + {name='some'}))

--    assert.is_true(is.oid(table.map(iter(coll[{}]))[1]._id))
--    assert.is_true(is.oid(coll[{}][1]._id))
--    assert.oid(coll[1]._id)
--    assert.oid(coll[{}][1]._id)
    assert.truthy(-coll)
  end)
  it("empty2", function()
    assert.equal('t/storage/mongo/collection', t.type(mongo.none))
    assert.is_nil(mongo.none2.any)
  end)
  it("empty3", function()
    local m = t.storage.mongo()
    assert.equal('t/storage/mongo/collection', t.type(m.none))
    assert.is_nil(m.none2.any)
  end)
  it("update", function()
    assert.equal('t/storage/mongo/collection', t.type(coll))
    assert.truthy(-coll)

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

    assert.is_true(coll-id)
  end)
  it("records", function()
    assert.equal('t/storage/mongo/collection', t.type(coll))
    assert.truthy(-coll)

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

    local c=0
    for i,v in pairs(coll[{}]) do c=c+1 end
    assert.equal(2, c)

    c=0
    for v in iter(coll[{}]) do c=c+1 end

    assert.equal(2, c)
    assert.truthy(coll-{})
    assert.equal(0, tonumber(coll))

    assert.equal('[]', json(coll[{}]))
  end)
end)
