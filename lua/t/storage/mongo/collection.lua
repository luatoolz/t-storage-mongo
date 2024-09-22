local t = t or require "t"
local is = t.is
local getmetatable = debug and debug.getmetatable or getmetatable
local bson = require "t.format.bson"
local failed = t.failed

local pkg = t.match.modbase(...)
local cursor = require(pkg .. ".cursor")
local bulk = require(pkg .. ".bulk")

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
  if mt.__add then return object end

  if type(mt.__index)=='table' then mt.__index=nil end
  if type(mt.__index)=='nil' then
    mt.__index=mt.__index or function(self, key) if not (type(key)=='table' or (type(key)=='string' and #key>0)) then return nil end
      if type(key)=='string' then return getmetatable(self)[key] end
      if type(key)=='table' then
        return self:findOne(bson(key)) end
  end end

  mt.__div    = mt.__div or function(self, it) if type(it)=='nil' then it=true end; return self:createBulkOperation{ordered=it} end
  mt.__concat = mt.__concat or function(self, it)
    if is.bulk(it) then if #it>0 then return ((self/true):__concat(it)):execute() end; return end;
    return it and failed(self:insertOne(it))
  end
  mt.__add    = mt.__add or function(self, it) if is.bulk(it) then if #it>0 then return ((self/true)..it):execute() end; return end; return it and failed(self:insertOne(it)) end -- document
  mt.__sub    = mt.__sub or function(self, it) if is.bulk(it) then if #it>0 then return ((self/false)-it):execute() end; return end; return it and failed(self:remove(it)) end -- query
  mt.__mod    = mt.__mod or function(self, query) return failed(self:count(bson(query or {}))) end
  mt.__mul    = mt.__mul or function(self, query) return self:find(query) end
  mt.__unm    = mt.__unm or function(self) return failed(self:drop()) end
  mt.__tostring = mt.__tostring or function(self) return self:getName() end
  mt.__newindex = mt.__newindex or function(self, query, it)
    if type(query)=='nil' then return self + it end
    if is.bulk(query) then
      return
    end
    if it then self:updateOne(query, it) end
  end

  local __find=mt.find
  mt.find = function(self, it, options, prefs) return it and cursor(__find(self, bson(it), options, prefs)) end
  local __insert=mt.insert
  mt.insert   = function(self, it, options) return it and failed(__insert(self, bson(it or {}), options)) end
  local __insertOne=mt.insertOne
  mt.insertOne   = function(self, it, options) return it and failed(__insertOne(self, bson(it), options)) end
  local __removeOne=mt.removeOne
  mt.removeOne = function(self, it, options)
    if type(it)=='table' then
      return failed(__removeOne(self, bson(it), options))
    end
  end
  local __remove=mt.remove
  mt.remove = function(self, it, options)
    if type(it)=='table' then
      return failed(__remove(self, bson(it), options))
    end
  end
  local __replaceOne=mt.replaceOne
  mt.replaceOne= function(self, query, it, options) return failed(__replaceOne(self, query, bson(it), options)) end
  local __updateOne=mt.updateOne
  mt.updateOne= function(self, query, it, options) return failed(__updateOne(self, query, bson(it), options)) end
  local __createBulkOperation=mt.createBulkOperation
  mt.createBulkOperation = function(self, ...) return bulk(__createBulkOperation(self, ...)) end

  assert(mt.__add)
  assert(mt.__sub)
  assert(mt.__concat)
--  assert(mt.__tonumber)
--  assert(mt.__len)
  assert(mt.__mod)
  assert(mt.__unm)
  assert(mt.__newindex)
  assert(mt.__index)
  assert(mt.__tostring)
  return object
end
