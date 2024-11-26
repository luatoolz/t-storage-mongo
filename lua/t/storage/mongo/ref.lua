local t=t or require "t"
local pkg = t.pkg(...)
local oid, storage = pkg.oid, pkg.cache

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
__tostring=function(self) return type(next(self))=='nil' and 'mongo.ref' or
  string.format('{$ref:%s, $id:%s%s}', self['$ref'], self['$id'],
    self['$db'] and string.format(', $db:%s', self['$db']) or '')
end,
__export=__export,
__toBSON=__export,
})