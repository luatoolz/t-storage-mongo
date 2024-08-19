describe("data", function()
  local t, mongo, test_coll, coll, testdata
  setup(function()
    t = require "t"
    t.env.MONGO_HOST='localhost'
    t.env.MONGO_USER=nil
    t.env.MONGO_PASS=nil
    testdata = require "testdata"
    assert(testdata.data)
    assert(testdata.data.test_coll)
    mongo = t.storage.mongo ^ testdata.data
  end)
  before_each(function()
    coll = mongo.test_coll
    _ = -coll
  end)
  it("connect", function()
    assert.is_true(toboolean(mongo))
    assert.is_true(toboolean(mongo()))
  end)
  it("create", function()
    local coll = mongo.test_coll
    assert.is_table(coll.___.item)

    _ = coll + ('[{"token":"95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7","role":"root"},' ..
      '{"token":"46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a","role":"traffer"},' ..
      '{"token":"60879afb54028243bb82726a5485819a8bbcacd1df738439bfdf06bc3ea628d0","role":"panel"}]')
    assert.equal(3, tonumber(coll[{}]))
    assert.equal(3, tonumber(coll))

    local id='95687c9a1a88dd2d552438573dd018748dfff0222c76f085515be2dc1db2afa7'
    assert.is_table(coll[id])
    assert.equal('root', coll[id].role)

    id='46db395df332f18b437d572837d314e421804aaed0f229872ce7d8825d11ff9a'
    assert.is_table(coll[id])
    assert.equal('traffer', coll[id].role)

    id='60879afb54028243bb82726a5485819a8bbcacd1df738439bfdf06bc3ea628d0'
    assert.is_table(coll[id])
    assert.equal('panel', coll[id].role)
  end)
end)
