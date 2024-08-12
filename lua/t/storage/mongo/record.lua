require "t"
local driver = require "mongo"
local oid = require "t.storage.mongo.oid"

return setmetatable({}, {
  __call=function(self, o, ctx)
    if type(o)=='userdata' and driver.type(o)=='mongo.BSON' then o=o:value() or {} end
    if type(o)=='nil' then o={} end
    if type(o)=='table' then
      o.__=ctx
      return setmetatable(o, getmetatable(self))
    end
  end,
--  __pow=function(self, o) if o then self.__=o end; return self; end,
  __unm=function(self) if self._id then return self.__:remove({_id=oid(self._id)}) end end,
  __pairs=function(self) local k,v return function() repeat k,v=next(self, k); until k~='__'; return k,v; end end,
--  __toboolean=function(self) return type(next(clone(self))~=nil end,
})
