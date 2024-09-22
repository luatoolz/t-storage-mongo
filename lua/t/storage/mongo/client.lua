local t = t or require"t"
local getmetatable = debug and debug.getmetatable or getmetatable
local driver = require 'mongo'
local pkg = t.match.modbase(...)
local done

local connection = require(pkg .. ".connection")
local database   = require(pkg .. ".database")
local collection = require(pkg .. ".collection")

local Client = function(conn)
  return driver.Client(conn and tostring(conn) or conn) end

--[[
  [__gc] = function: 0x7feede3c2420
  [__metatable] = false
  [__name] = 'mongo.Client'
  [__tostring] = function: 0x7feede3c54a0
  [command] = function: 0x7feede3c2710
  [getCollection] = function: 0x7feede3c26a0
  [getDatabase] = function: 0x7feede3c2640
  [getDatabaseNames] = function: 0x7feede3c25e0
  [getDefaultDatabase] = function: 0x7feede3c2570
  [getGridFS] = function: 0x7feede3c24c0
  [getReadPrefs] = function: 0x7feede3c2490
  [setReadPrefs] = function: 0x7feede3c2450 }
--]]
local function fix_client_meta(object)
  if not object then return object end
  local mt = getmetatable(object)
  if mt.__div then return object end

  if type(mt.__index)=='table' then mt.__index=nil end
  if type(mt.__index)=='nil' then
    mt.__index=function(self, key) if type(key)~='string' or #key==0 then return nil end
      return getmetatable(self)[key] or collection(database(self:getDefaultDatabase()):getCollection(key))
  end end

  mt.__toboolean = mt.__toboolean or function(self) return toboolean(self:getDatabaseNames()) end
  mt.__div  = mt.__div or function(self, key) return database(self:getDatabase(key)) end
  mt.__call = mt.__call or function(self, dbname, collname) return collection(self:getCollection(dbname, collname)) end

  assert(type(mt.__call)=='function')
  assert(type(mt.__div)=='function')
  assert(type(mt.__index)=='function')
  assert(type(mt.__toboolean)=='function')
  done=true
  return object
end

return function(conn)
  conn=conn or connection
  if not done then return fix_client_meta(Client(conn)) end
  return Client(conn)
end
