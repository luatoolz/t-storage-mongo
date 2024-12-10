local t=t or require "t"
require "t.format.bson"
local _ = t.is ^ 'mongo'
local to = t.to
local mt = t.mt
local iter = table.iter
local pkg = t.pkg(...)
local storage = pkg.cache
local connection = pkg.connection
local client = pkg.client

local mongo={}
local factory = function(x) return rawequal(mongo, x) and true or nil end
return setmetatable(mongo,{
  __name=tostring(pkg),
  __call=function(self, connstr) return setmetatable({connstr=connstr}, getmetatable(self)) end,
  __pow=function(self, x) -- tie storage to container [loader or any indexable]
    assert(type(x)=='table', ('t.storage.mongo:__pow await table, got %s'):format(type(x)))
    storage[x]=self
    return self
  end,
  __toboolean=function(self) return to.boolean((factory(self) and self() or self)._client) end,
  __div=function(self, dbname) return assert(self._client/dbname or self._dbname) end,
  __iter=function(self) return iter(self._client) end,
  __index=mt.factory,
  __pairs=function(self) return pairs(self._db)  end,
  __computable={
    _conn=function(self) return connection(rawget(self, 'connstr')) end,
    _client=function(self) return client(self._conn) end,
    _dbname=function(self) return self._conn.db end,
    _db=function(self) return assert(self._client/self._dbname) end,
  },
  __postindex=function(self, k)
    if factory(self) then return self()[k] end
    return (self._db or {})[k]
  end,
})