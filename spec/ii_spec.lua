describe("ii", function()
  local t, export, oid, ii
  setup(function()
    t = require "t"
    export = t.exporter
    oid = t.storage.mongo.oid
    ii = t.storage.mongo.ii
  end)
  it("oid", function()
    assert.equal('$id', ii.id)
    assert.equal('$ref', ii.ref)
    assert.equal('$db', ii.db)
  end)
  it("oid", function()
    local id = '66909d26cbade70b6b022b9a'
    assert.equal(id, t.match.oid(id))
    assert.oid(id)
    local moid = oid(id)
    assert.oid(tostring(moid))
    assert.equal(moid, oid(export(moid)))
    assert.same({[ii.oid]=id}, export(moid))
    assert.equal(moid, oid({[ii.oid]=id}))
    assert.same(id, export(moid, false))
  end)
end)