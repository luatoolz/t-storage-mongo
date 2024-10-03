local t = t or require"t"

return function(object)
  if not object then return object end
  local mt = getmetatable(object)
  if (not mt) or mt.__iter then return object end

  if type(mt.__index)=='table' or type(mt.__index)=='nil' then
    mt.__index=function(self, key)
      if type(key)=='string' and #key>0 then
        return getmetatable(self)[key] end end end

  if type(mt.__iter)=='nil' then
    mt.__iter = function(cursor, handler)
      local it, cur = cursor:iterator(handler)
      return function()
        return it(cur)
      end
    end
  end
  if type(mt.__call)=='nil' then
    mt.__call = function(cursor, handler)
      local bson, _ = cursor:next()
      return bson and bson:value(handler)
    end
  end
  if type(mt.__export)=='nil' then
    mt.__export = function(cursor)
      local rv={}
      while cursor:more() do table.insert(rv, cursor()) end
      return rv
    end
  end
  assert(mt.__iter)
  assert(mt.__call)
  assert(mt.__export)
  assert(type(mt.__index)=='function')
  return object
end
