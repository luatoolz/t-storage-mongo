describe("collection", function()
  local t, mongo, coll, to, iter, map, array
  setup(function()
    t = require "t"
    t.env.MONGO_HOST='127.0.0.1'
    t.env.MONGO_PORT=27016
    to = t.to
    iter = table.iter
    map = table.map
    array = t.array
    _ = iter
    _ = map
    mongo = t.storage.mongo
    coll = mongo.coll
    oid=mongo.oid
  end)
  before_each(function()
    t.env.MONGO_CONNSTRING=nil
    coll = mongo.coll
    _ = -mongo.coll
  end)
  it("count/insert/find/delete one", function()
    assert.truthy(coll-{})
    assert.equal(0, to.number(coll))
    _ = coll + {test=true}
    assert.equal(1, to.number(coll))
    assert.is_true(to.boolean(coll))

    local id = mongo.oid('6690c3c574d428e23e0493c7')
    assert.is_true(coll + {_id=id, name='some', try=5})
    assert.equal(1, coll % {_id=id})

    assert.truthy(coll[{_id=id}])

    assert.is_true(coll - {_id=id})
    assert.equal(0, coll % {_id=id})
    assert.equal(1, to.number(coll))
    assert.is_true(coll - {})
    assert.equal(0, to.number(coll))
    assert.is_true(coll + {name='some2', try=6})
    assert.equal(1, to.number(coll))
    assert.is_true(coll + {name='some3', try=7})
    assert.equal(2, to.number(coll))
    assert.is_true(coll + {name='some4', try=8})
    assert.equal(3, to.number(coll))
    assert.is_true(coll + {name='some5', try=9})
    assert.equal(4, to.number(coll))

    assert.equal(4, #(map(coll*{})))
    assert.equal(4, #(map(coll[{}])))

    assert.is_true(-coll)
    assert.equal(0, to.number(coll))
  end)
  it("insert/find/update", function()
    assert.equal(0, to.number(coll))
    local id = mongo.oid('66909d26cbade70b6b022b9b')

    assert.is_true(coll + {_id=id, name='some', try=5})

    local _id=mongo.oid()
    assert.is_true(coll .. {_id=_id, name='some', try=1})
    assert.truthy(coll[{_id=_id}])
    assert.is_true(coll-{})
    assert.falsy(coll[{_id=_id}])
    assert.equal(0, to.number(coll))

    id={oid(),oid()}
    assert.equal(2, (coll .. {{_id=id[1],name='some', try=2}, {_id=id[2],name='some', try=3}}).nInserted)
    assert.equal(2, to.number(coll))

    assert.equal('some', coll[{_id=id[1]}].name)
    coll[{_id=id[1]}]={name='other'}
    assert.equal('other', coll[{_id=id[1]}].name)

    assert.equal(2, (coll - {{_id=id[1]},{_id=id[2]}}).nRemoved)
    assert.equal(0, to.number(coll))
  end)
  it("json", function()
    local json = t.format.json
    if json then
    local jj = '[{"token":"95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7","role":"root"},' ..
               '{"token":"46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a","role":"traffer"},' ..
               '{"token":"60879afb54028243bb82726a5485819a8bbcacd1df738439bfdf06bc3ea628d0","role":"panel"}]'
    assert.is_table(coll + json.decode(jj))
    end
  end)
  it("array of objects", function()
    assert.equal(2, (coll .. array({{role='root', token='95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7'},
      {role='traffer', token='46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a'}})).nInserted)
    assert.equal(2, (coll .. {{role='root', token='95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7'},
      {role='traffer', token='46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a'}}).nInserted)
  end)
--[[
  it("update", function()
    assert.truthy(-coll)

    local ida = '66909d26cbade70b6b022b9a'
    local idb = '66909d26cbade70b6b022b9b'

    local id = mongo.oid(idb)
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
--]]
end)
