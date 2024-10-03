describe("oid", function()
  local meta, t, is, oid
  setup(function()
    meta = require "meta"
    meta.log.report=true
    meta.errors(true)
    t = require "t"
    is = t.is
    oid = is.oid
  end)
  it("matcher", function()
    assert.equal(t.match.oid, oid)
  end)
  it("is", function()
    assert.oid('66909d26cbade70b6b022b9a')
    assert.not_oid('')
    assert.not_oid('a')
    assert.not_oid('66909d26cbade70b6b022b9aa')
    assert.not_oid('66909d26cbade70b6b022b9g')
    assert.not_oid(nil)
    assert.not_oid()
  end)
end)
