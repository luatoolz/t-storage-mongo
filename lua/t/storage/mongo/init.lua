local t = require "t"
local meta = require 'meta'
local is = t.is
meta.no.track('mongo')

local driver = require 'mongo'

-- context/client var is named `__`
return t.object({
  __name='t/storage/mongo',
  __toboolean=function(self) return is.factory(self) and toboolean(self()) or toboolean(self.__) end,
  __div = function(self, k)
    if type(k)~='string' or k=='' then return nil end
    if is.factory(self) then return self() / k end
    _ = self.__ / k
    return self
  end,
  __call=function(self, conn)
    conn=self.connection(conn)
    local db = conn.db
    conn=driver.Client(tostring(conn))
    return setmetatable({__=self.context(conn)/db}, getmetatable(self))
  end,
}):postindex(function(self, k)
  if type(k)~='string' or k=='' then return nil end
  if is.factory(self) then return driver[k] or self()[k] end
  assert(self.collection, 'require self.collection')
  return self.collection(self.__, k)
end)
:loader(..., true):factory()
