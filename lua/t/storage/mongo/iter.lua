local getmetatable = debug.getmetatable or getmetatable
return function(cursor, handler)
  if type(cursor)=='table' or type(cursor)=='userdata' then
    local _iter = (getmetatable(cursor or {}) or {}).__iter
    if type(_iter)=='function' then return _iter(cursor, handler) end
  end
  return function() return nil end
end
