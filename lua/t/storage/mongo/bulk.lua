local t=t or require "t"
local is=t.is
local iter=table.iter
local pkg=t.pkg(...)
local export = t.exporter
local ex=function(x) return export(x, true) end
local bulkresult = pkg.bulkresult
local ok = t.ok

return function(object)
  if not object then return object end
  local mt = getmetatable(object)
  if (not mt) or mt.__add then return object end

  if type(mt.__index)=='table' or type(mt.__index)=='nil' then
    mt.__index=function(self, key)
      if type(key)=='string' and #key>0 then
        return getmetatable(self)[key] end end end

  mt.__concat = mt.__concat or function(self, it)
    if not is.bulk(it) then it={it} end
    for v in iter(it) do self:insert(ex(v)) end
    return self
  end
  mt.__add    = mt.__add or mt.__concat
  mt.__sub    = mt.__sub or function(self, it)
    if not is.bulk(it) then it={it} end
    for v in iter(it) do self:removeOne(ex(v)) end
    return self
  end
  mt.__call     = mt.__call or function(self, ...) return bulkresult(ok(self:execute(...))) end

  assert(type(mt.__call)   == 'function')
  assert(type(mt.__add)    == 'function')
  assert(type(mt.__sub)    == 'function')
  assert(type(mt.__concat) == 'function')
  assert(type(mt.__index)  == 'function')
  return object
end