local t = t or require "t"
local getmetatable = debug and debug.getmetatable or getmetatable
local pkg = t.match.modbase(...)
local collection = require(pkg .. ".collection")

--[[
  [__gc] = function: 0x7efcca87f7c0
  [__metatable] = false
  [__name] = 'mongo.Database'
  [__tostring] = function: 0x7efcca8814a0
  [addUser] = function: 0x7efcca87fb70
  [createCollection] = function: 0x7efcca87fac0
  [drop] = function: 0x7efcca87fa60
  [getCollection] = function: 0x7efcca87fa00
  [getCollectionNames] = function: 0x7efcca87f9a0
  [getName] = function: 0x7efcca87f970
  [getReadPrefs] = function: 0x7efcca87f940
  [hasCollection] = function: 0x7efcca87f8e0
  [removeAllUsers] = function: 0x7efcca87f890
  [removeUser] = function: 0x7efcca87f830
  [setReadPrefs] = function: 0x7efcca87f7f0 }
--]]
return function(object)
  if not object then return object end
  local mt = getmetatable(object)
  if mt.__unm then return object end

  if type(mt.__index)=='table' then mt.__index=nil end
  if type(mt.__index)=='nil' then
    mt.__index=function(self, key) if type(key)~='string' or #key==0 then return nil end
      return getmetatable(self)[key] or collection(self:getCollection(key))
  end end
  mt.__unm = mt.__unm or function(self) return self:drop() end

  assert(type(mt.__unm)=='function')
  assert(type(mt.__index)=='function')
  return object
end