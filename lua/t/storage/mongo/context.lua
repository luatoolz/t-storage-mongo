local t = require "t"

-- context object with client, db, coll
return t.object({
  __name='t/storage/mongo/context',
  __toboolean=function(self) return type(self.client:getDatabaseNames())~='nil' end,
  __tostring=function(self) return self.collname end,
  __div = function(self, k)
    assert(type(k)=='string' and k~='')
    return rawset(self, 'dbname', k)
  end,
  __pow = function(self, k)
    assert(type(k)=='string' and k~='')
    return rawset(self, 'collname', k)
  end,
  __call=function(self, client)
    assert(client)
    return setmetatable({client=client}, getmetatable(self))
  end,
}):computed({
  db=function(self) return self.dbname and self.client:getDatabase(self.dbname) or self.client:getDefaultDatabase() end,
  coll=function(self)
    assert(self.collname)
    assert(self.db)
    if not self.db:hasCollection(self.collname) then self.db:createCollection(self.collname) end
    return self.db:getCollection(self.collname)
  end,
}):factory()
