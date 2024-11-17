local t=t or require "t"
local is, to = t.is, t.to

-- {'nInserted','nMatched','nModified','nRemoved','nUpserted'} --,'writeErrors'}
return setmetatable({},{
  __name='t/storage/mongo/bulkresult',
  __call = function(self, x)
    if type(x)=='nil' then return end
    if type(x)=='userdata' and is.callable(x) then x=x() end
    if is.failed(x) then return x end
    local rv = type(x)=='table' and setmetatable(x, getmetatable(self)) or nil
    if rv then
      if type(next(rv.writeErrors or {}))=='nil' then rv.writeErrors=nil end
      for k,v in pairs(rv) do
        rv[k]=to.number(v) or 0
      end
    end
    return rv or x
  end,
  __toboolean = function(self) return self.writeErrors and true or false end,
})