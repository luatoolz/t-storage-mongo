local meta = require "meta"
local t = t or require "t"
local is = t.is ^ 'mongo'
local pkg = t.pkg((...) or 't.storage.mongo')
local bson = t.format.bson
local cache = meta.cache
local storage = cache('storage')
cache.objnormalize.storage = t.pkgname

assert(bson)
assert(pkg.type)
assert(pkg.cursor)

local connection = assert(pkg.connection)
local client = assert(pkg.client)

return t.object({
  __name=tostring(pkg),
  __call=function(self, connstr) return setmetatable({connstr=connstr}, getmetatable(self)) end,
  __pow=function(self, to) -- tie storage to container [loader or any indexable]
    assert(type(to)=='table', ('t.storage.mongo:__pow await table, got %s'):format(type(to)))
    storage[to]=self
    return self
  end,
  __toboolean=function(self) return toboolean((is.factory() and self() or self).client) end,
}):computable({
  conn=function(self) return assert(connection(rawget(self, 'connstr'))) end,
  client=function(self) return assert(client(self.conn)) end,
  dbname=function(self) return assert(self.conn.db) end,
  db=function(self) return assert(self.client/self.dbname) end,
}):postindex(function(self, k)
  if is.factory(self) then return self()[k] end
  return self.db[k]
end):loader(tostring(pkg)):factory()