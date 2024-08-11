local t = require "t"
local is = t.is
local iter = require "t.storage.mongo.iter"

return setmetatable({}, {
  __call=function(self, coll, query)
    assert('t/storage/mongo/collection' == t.type(coll), string.format('records.__call: await %s, got %s (%s)', 't/storage/mongo/collection', t.type(coll), type(coll)))
    if query=='' or query=='*' then query={} end
    return setmetatable({__=coll.__, coll=coll, query=query or {}}, getmetatable(self))
  end,
  __toboolean=function(self) return tonumber(self)>0 end,
  __tonumber=function(self) return self.__:count(self.query) or 0 end,
  __len=function(self) return tonumber(self) end,
  __add=function(self, o) if type(o)=='number' then return tonumber(self)+o end end,
  __sub=function(self, o) if type(o)=='number' then return tonumber(self)-o end end,
  __unm=function(self) self.__:removeMany(self.query); return self end,
  __iter=function(self, handler) return iter(self.__:find(self.query), handler) end, -- or self.handler
  __pairs=function(self) local i, it = 1, iter(self)
    return function() local rv=it(); if rv then i=i+1; return i,rv end; return nil, nil; end
  end,
  __index=function(self, k) return type(k)=='number' and table.map(iter(self))[k] or rawget(self, k) end,
  __eq=function(self, to) return type(self)=='table' and type(to)=='table' and type(self.coll)~='nil' and type(self.coll)==type(to.coll) and tostring(self.coll)==tostring(to.coll) and is.eq(self.query, to.query) end,
})
