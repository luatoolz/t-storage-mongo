local t = require "t"
local meta = require "meta"
local is = t.is
meta.no.track("mongo")
local driver = require "mongo"

-- __  = t.storage.mongo.connection
-- ___ = db name

return t.object({
  __name='t/storage/mongo',
  __toboolean=function(self) return is.factory(self) and toboolean(self()) or toboolean(driver.Client(tostring(self.__)):getDatabaseNames()) end,
  __div = function(self, k)
    if type(k)~='string' or k=='' then return nil end
    if is.factory(self) then return self()/k end
    self.___ = k
    return self
  end,
  __call=function(self, conn, db)
    conn=self.connection(conn)
    return setmetatable({__=conn, ___=db}, getmetatable(self))
  end,
}):postindex(function(self, k)
  if type(k)~='string' or k=='' or k=='__' or k=='___' then return nil end
  if is.factory(self) then return driver[k] or self()[k] end
  assert(self.collection, 'require self.collection')
  return self.collection({conn=self.__, db=self.___, k=k})
end)
:loader(..., true):factory()
