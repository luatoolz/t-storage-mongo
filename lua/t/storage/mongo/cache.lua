local t=t or require "t"
local mcache=t.mcache
local match=t.match
local tpkgname=t.pkg.name

-- storage[t.def]=t.storage.mongo
return mcache.storage/{
put=function(self, k, v) self[tpkgname(k)]=v end,
get=function(self, o)
  if type(o)=='string' then return self[o] end
  if type(o)~='table' or not getmetatable(o) then return end
  local n = getmetatable(o).__name
  if type(n)=='string' and #n>0 and n:match('%s') then
    local base, name = match.virtual(n)
    return (self[base] or {})[name]
  end
  local rv=self[tpkgname(o)]
  return rv
end,
}