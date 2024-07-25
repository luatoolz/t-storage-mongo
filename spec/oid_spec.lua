describe("collection", function()
  local t, is, mongo, oid
  setup(function()
    t = require "t"
    is = t.is
    mongo = t.storage.mongo
    oid = t.fn.combined(tostring, string.null, mongo.ObjectID)
  end)
  it("oid", function()
    local id = '66909d26cbade70b6b022b9a'
    assert.is_true(is.oid(id))
    assert.is_true(mongo.type(oid(id)) == 'mongo.ObjectID')
    assert.same({_id = mongo.ObjectID(id)}, {_id = oid(id)})
  end)
end)
