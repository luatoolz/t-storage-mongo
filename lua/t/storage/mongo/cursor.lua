-- this file is loaded in init.d, so use global "t"
local t = t or require"t"
local iter = assert(require "t.storage.mongo.iter")
local json = assert(require "t.format.json")
local getmetatable = debug.getmetatable or getmetatable

return function(cur)
  if not cur then return cur end

  local mt = getmetatable(cur)
  if type(mt.__iter)=='nil' then
    mt.__iter = function(cursor, handler)
      return function()
        return cursor:value(handler)
      end
    end
  end

  if type(mt.__call)=='nil' then
    mt.__call = function(cursor, handler)
      local it = function()
        return cursor:value(handler)
      end
      return it()
    end
  end

  if type(mt.__tojson)=='nil' then
    mt.__tojson = function(cursor)
      local jsoner = function(x) return json(x, true) end
      return table.map(iter(cursor, jsoner) or {})
    end
    mt.__toJSON = mt.__tojson
  end

  assert(mt.__iter)
  assert(mt.__call)
  assert(mt.__tojson)
  return cur
end
