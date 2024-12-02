local t=t or require "t"
local is, ok = t.is, t.ok
local pkg=t.pkg(...)

local cursor, bulk = pkg.cursor, pkg.bulk
local export = t.exporter
local ex=function(x) return export(x, true) end

--[[
  [__gc] = function: 0x7f494660c8e0
  [__metatable] = false
  [__name] = 'mongo.Collection'
  [__tostring] = function: 0x7f494660f4a0
  [aggregate] = function: 0x7f494660d340
  [count] = function: 0x7f494660d280
  [createBulkOperation] = function: 0x7f494660d220
  [drop] = function: 0x7f494660d1c0
  [find] = function: 0x7f494660d140
  [findAndModify] = function: 0x7f494660d060
  [findOne] = function: 0x7f494660cf40
  [getName] = function: 0x7f494660cf10
  [getReadPrefs] = function: 0x7f494660cee0
  [insert] = function: 0x7f494660ce60
  [insertMany] = function: 0x7f494660d3d0
  [insertOne] = function: 0x7f494660cde0
  [remove] = function: 0x7f494660cd60
  [removeMany] = function: 0x7f494660cce0
  [removeOne] = function: 0x7f494660cc60
  [rename] = function: 0x7f494660cbb0
  [replaceOne] = function: 0x7f494660cb20
  [setReadPrefs] = function: 0x7f494660cae0
  [update] = function: 0x7f494660ca50
  [updateMany] = function: 0x7f494660c9c0
  [updateOne] = function: 0x7f494660c930 }
--]]
return function(object)
  if not object then return object end
  local mt = getmetatable(object)
  if (not mt) or mt.__add then return object end

  if type(mt.__index)=='table' then mt.__index=nil end
  if type(mt.__index)=='nil' then
    mt.__index=mt.__index or function(self, key) if not (type(key)=='table' or (type(key)=='string' and #key>0)) then return nil end
      if type(key)=='string' then return getmetatable(self)[key] end
      if type(key)=='table' and key._id then
        local rv=self:findOne(ex(key))
        if type(rv)=='userdata' then return rv:value() end
        return ok(rv)
      end
      if type(key)=='table' then return cursor(self:find(ex(key))) end
  end end

  mt.__div    = mt.__div or function(self, it) if type(it)~='boolean' then it=true end; return bulk(self:createBulkOperation{ordered=it}) end
  mt.__concat = mt.__concat or function(self, x) if type(x)=='nil' then return end
    local it=ex(x)
    if type(it)~='table' then return end

    if not is.bulk(it) then return ok(self:insert(it), {continueOnError=true}) end
    if #it>0 then return ((self/true)..it)() end
  end
  mt.__add    = mt.__add or function(self, x) if type(x)=='nil' then return end
    local it=ex(x)
    if type(it)~='table' then return end
    if not is.bulk(it) then return ok(self:insert(it), {continueOnError=true}) end
    if #it>0 then return ((self/true)..it)() end
  end
  mt.__sub    = mt.__sub or function(self, x) if type(x)=='nil' then return end
    local it=ex(x)
    if type(it)~='table' then return end
    if not is.bulk(it) then return ok(self:remove(it)) end
    if #it>0 then return ((self/true)-it)() end
  end
  mt.__mod    = mt.__mod or function(self, q) q=ex(q); q=is.table(q) and q or {}; return ok(self:count(q)) end
  mt.__mul    = mt.__mul or function(self, q) q=ex(q); if is.table(q) then return cursor(self:find(q)) end end

  mt.__unm    = mt.__unm or function(self) return ok(self:drop()) end
  mt.__len    = mt.__len or function(self) return ok(self:count({})) end
  mt.__tostring = mt.__tostring or function(self) return self:getName() end

  mt.__newindex = mt.__newindex or function(self, q, it)
    if type(q)=='nil' and type(it)~='nil' then return self + it end
    if type(it)=='nil' then return self:remove(ex(q)) end
    if type(it)=='table' then return self:update(ex(q), ex(it), {upsert=true}) end
    if is.bulk(q) or not q then return end
  end

  assert(mt.__add)
  assert(mt.__sub)
  assert(mt.__concat)
  assert(mt.__len)
  assert(mt.__mod)
  assert(mt.__unm)
  assert(mt.__newindex)
  assert(mt.__index)
  assert(mt.__tostring)
  return object
end