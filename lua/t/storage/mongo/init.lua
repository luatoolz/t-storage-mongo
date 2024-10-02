local meta = require "meta"
local pkg = (...) or "t.storage.mongo"
local t = t or require "t"
local is = t.is ^ 'mongo'
local cache = meta.cache
local storage = cache('storage')
cache.objnormalize.storage = t.module.basename
local getmetatable = debug and debug.getmetatable or getmetatable
local setmetatable = debug and debug.setmetatable or setmetatable

require(pkg .. ".type")
require(pkg .. ".cursor")

local connection = assert(require(pkg .. ".connection"))
local client = assert(require(pkg .. ".client"))

return t.object({
  __name='t/storage/mongo',
  __call=function(self) return setmetatable({}, getmetatable(self)) end,
  __pow=function(self, to) -- tie storage to container [loader or any indexable]
    assert(type(to)=='table', ('t.storage.mongo:__pow await table, got %s'):format(type(to)))
    storage[to]=self
    return self
  end,
  __toboolean=function(self) return toboolean(client(connection)) end,
}):postindex(function(self, k)
  if is.factory(self) then return self()[k] end
  return (client(connection)/connection.db)[k]
end):loader(pkg):factory()
