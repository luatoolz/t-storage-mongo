local t = require "t"

return function(cursor, handler)
  if type(cursor)=='table' then
    local _iter = (getmetatable(cursor or {}) or {}).__iter
    if type(_iter)=='function' then return _iter(cursor, handler) end
  end
  local it, cur = cursor:iterator(handler)
  return function()
    return it(cur)
  end
end
