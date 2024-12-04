local t=t or require "t"
local pkg = t.pkg(...)
local oid, storage = pkg.oid, pkg.cache
--local join = string.joiner(':')

local __export=function(self) return setmetatable(self, nil) end

return setmetatable({},{
__call=function(self, ref, id, db)
  if type(next(self))~='nil' then
    local d=storage[self['$ref']]
    return d and d[self['$id']]
  end
  if type(ref)=='string' and id then
    return setmetatable({['$ref']=ref, ['$id']=oid(id), ['$db']=db}, getmetatable(self))
  end
end,
--__tostring=function(self) return is.defitem(self) and '$ref:%s/%s:%s'%{self['$db'], self['$id'], self['$ref']} end,
--  local db = self['$db'] and ('%s/'%self['$db'])
--  return is.defitem(self) and join('$ref', db, self['$id'], self['$ref']},':')
--end,
__export=__export,
__toBSON=__export,
})