local t = t or require"t"
local is = t.is
local failed = t.failed
local getmetatable = debug and debug.getmetatable or getmetatable
local setmetatable = debug and debug.setmetatable or setmetatable
local bson = require "t.format.bson"

local pkg = t.match.modbase(...)
local oid = require(pkg .. ".oid")
local _ = oid

local mtresult = {
  __toboolean = function(self) return #(self.writeErrors or {})==0 end
}
local function toresult(x)
  return type(x)=='table' and setmetatable(x, mtresult) or x
end

--[[
  [__gc] = function: 0x7fb44c29d000
  [__metatable] = false
  [__name] = 'mongo.BulkOperation'
  [__tostring] = function: 0x7fb44c2a04a0
  [execute] = function: 0x7fb44c29d360
  [insert] = function: 0x7fb44c29d2e0
  [removeMany] = function: 0x7fb44c29d260
  [removeOne] = function: 0x7fb44c29d1e0
  [replaceOne] = function: 0x7fb44c29d150
  [updateMany] = function: 0x7fb44c29d0c0
  [updateOne] = function: 0x7fb44c29d030 }
--]]
return function(object)
  if not object then return object end
  local mt = getmetatable(object)
  if mt.__add then return object end

  if type(mt.__index)=='table' or type(mt.__index)=='nil' then
    mt.__index=function(self, key)
      if type(key)=='string' and #key>0 then
        return getmetatable(self)[key] end end end

  mt.__concat = mt.__concat or function(self, it)
    if is.bulk(it) then for v in table.iter(it) do if v then _=self+v end end; return self else self:insert(it) end
  end
  mt.__add    = mt.__add or function(self, it)
    if is.bulk(it) then return self .. it end
    if it then self:insert(it) end
    return self
  end
  mt.__sub    = mt.__sub or function(self, it)
    if is.bulk(it) then for v in table.iter(it) do if v then _=self-v end end; return self else self:removeOne(it) end
    return self
  end

  local __insert      = mt.insert
  local __removeOne   = mt.removeOne
  local __replaceOne  = mt.replaceOne
  local __updateOne   = mt.updateOne
  local __execute     = mt.execute
  local __removeMany  = mt.removeMany

  mt.insert     = function(self, it, options)        return it and __insert     (self, bson(it), options) end
  mt.removeOne  = function(self, it, options)        return it and __removeOne  (self, bson(it), options) end
  mt.removeMany = function(self, it, options)        return it and __removeMany (self, bson(it), options) end
  mt.replaceOne = function(self, query, it, options) return it and __replaceOne (self, query, bson(it), options) end
  mt.updateOne  = function(self, query, it, options) return it and __updateOne  (self, query, bson(it), options) end

  mt.execute    = function(...) local rv=failed( toresult(__execute(...)) ); if rv then return rv() end end
  mt.__call     = mt.__call or mt.execute

  assert(type(mt.__call)   == 'function')
  assert(type(mt.__add)    == 'function')
  assert(type(mt.__sub)    == 'function')
  assert(type(mt.__concat) == 'function')
  assert(type(mt.__index)  == 'function')
  return object
end
