describe("ref", function()
  local t, is, ref
  setup(function()
    t = require "t"
    is = t.is
    ref = t.storage.mongo.ref
  end)
  it("matcher", function()
    local o = ref('any', '66909d26cbade70b6b022b9a')
    assert.truthy(is.ref(o))
--    assert.equal('{$ref:any, $id:66909d26cbade70b6b022b9a}', tostring(o))

    o = ref('any', '66909d26cbade70b6b022b9a', 'db')
    assert.truthy(is.ref(o))
--    assert.equal('{$ref:any, $id:66909d26cbade70b6b022b9a, $db:db}', tostring(o))

    assert.is_nil(ref(''))
    assert.is_nil(ref('a'))
    assert.is_nil(ref('66909d26cbade70b6b022b9aa'))
    assert.is_nil(ref('66909d26cbade70b6b022b9g'))
    assert.is_nil(ref())
    assert.is_nil(ref(nil))
  end)
end)