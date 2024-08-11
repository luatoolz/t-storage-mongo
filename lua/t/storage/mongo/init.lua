local driver = require "mongo"
assert(driver, 'failed to load mongo driver')
local pkg = (...) or 't.storage.mongo'
local t = require "t"
require "t.storage.mongo.type"

-- __  = t.storage.mongo.connection
-- ___ = db name
return t.object({
  __name='t/storage/mongo',
  __toboolean=function(self) return type(next(self))=='nil' and toboolean(self()) or toboolean(driver.Client(tostring(self.__)):getDatabaseNames()) end,
  __div = function(self, k)
    if type(k)~='string' or k=='' then return nil end
    if type(next(self))=='nil' then return self()/k end
    self.___ = k
    return self
  end,
  __call=function(self, conn, db)
    conn=self.connection(conn)
    return setmetatable({__=conn, ___=db}, getmetatable(self))
  end,
}):postindex(function(self, k)
  if type(k)~='string' or k=='' or k=='__' or k=='___' then return nil end
  if type(next(self))=='nil' then return driver[k] or self()[k] end
  assert(self.collection, 'require self.collection')
  return self.collection({conn=self.__, db=self.___, k=k})
end)
:loader(pkg):factory()
