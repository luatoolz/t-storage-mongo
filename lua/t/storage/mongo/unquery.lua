local t=t or require "t"
local meta = require "meta"
local ok = meta.checker({["nil"]=false}, type, true)
--local null = meta.checker({["nil"]=true}, type)
local function unquery(q, qb, qc)
  if type(q)=='table' and ok[q.query] then
    return unquery(q.query, qb or (qb==nil and q.options or nil) or nil, qc or (qc==nil and q.as or nil) or nil)
  end
  return q, qb or nil, qc or nil
end
return unquery