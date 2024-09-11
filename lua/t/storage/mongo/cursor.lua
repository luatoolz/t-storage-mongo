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
      local ok=true
      return function()
        if not ok then return nil end
        if not cursor:more() then ok=false end
        return cursor:value(handler)
      end
    end
  end

  if type(mt.__call)=='nil' then
    mt.__call = function(cursor, handler)
      local ok=true
      local it = function()
        if not ok then return nil end
        if not cursor:more() then ok=false end
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

  if type(mt.__export)=='nil' then
    mt.__export = function(cursor)
      if cursor:more() then
        return table.map(cursor())
      end
      return {}
    end
  end

  assert(mt.__iter)
  assert(mt.__call)
  assert(mt.__tojson)
  assert(mt.__export)
  return cur
end
