local t = require "t"
local is = t.is
local iter = require "t.storage.mongo.iter"

return setmetatable({}, {
--  __add=function(self, o) if type(o)=='number' then return tonumber(self)+o end end,
  __call=function(self, coll, query)
    assert(is.storage.mongo.collection(coll))
    assert(query)
    if query=='*' then query={} end
    return setmetatable({__=coll.__, coll=coll, query=query}, getmetatable(self))
  end,
  __eq=function(self, to) return t.type(self)==t.type(to) and self.coll and tostring(self.coll)==tostring(to.coll) and is.eq(self.query, to.query) end,
  __index=function(self, k) return type(k)=='number' and table.map(iter(self))[k] or rawget(self, k) end,
  __iter=function(self, handler) return iter(self.__:find(self.query), handler) end,
  __len=function(self) return tonumber(self) end,
  __mod=table.filter,
  __mul=table.map,
  __pairs=function(self) local i, it = 1, iter(self)
    return function() local rv=it(); i=rv and i+1 or nil; return i,rv end end,
  __sub=function(self, o)
    if rawequal(self, o) or o=='*' or is.table.empty(o) then o=self.query end
    if type(o)=='number' then return self - self[o] end
    if o then return self.__:remove(o) end
  end,
  __toboolean=function(self) return tonumber(self)>0 end,
  __tonumber=function(self) return self.__:count(self.query) or 0 end,
  __unm=function(self) return self.__:remove(self.query) end,
})
