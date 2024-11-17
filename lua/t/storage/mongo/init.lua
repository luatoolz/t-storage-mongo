local t=t or require "t"
require "t.format.bson"
local is = t.is ^ 'mongo'
local to = t.to
local pkg = t.pkg(...)
local storage = pkg.cache
local connection = pkg.connection
local client = pkg.client

return t.object({
  __name=tostring(pkg),
  __call=function(self, connstr) return setmetatable({connstr=connstr}, getmetatable(self)) end,
  __pow=function(self, x) -- tie storage to container [loader or any indexable]
    assert(type(x)=='table', ('t.storage.mongo:__pow await table, got %s'):format(type(x)))
    storage[x]=self
    return self
  end,
  __toboolean=function(self) return to.boolean((is.factory(self) and self() or self)._client) end,
}):computable({
  _conn=function(self) return connection(rawget(self, 'connstr')) end,
  _client=function(self) return client(self._conn) end,
  _dbname=function(self) return self._conn.db end,
  _db=function(self) return assert(self._client/self._dbname) end,
}):postindex(function(self, k)
  if is.factory(self) then return self()[k] end
  return (self._db or {})[k]
end):loader(tostring(pkg)):factory()