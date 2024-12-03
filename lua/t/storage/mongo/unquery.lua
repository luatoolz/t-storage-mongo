local t=t or require "t"
local meta = require "meta"
local unpak = table.unpack or unpack
local ok = meta.checker({["nil"]=false}, type, true)
local function unquery(q, qb, qc)
  local a,b,c = q, qb or nil, qc or nil
  if type(q)=='table' then
    if ok[q.query] then
      a,b,c = q.query, q.options, q.as
    elseif #q>0 and ok[q[1]] then
      a,b,c = unpak(q)
    end
    if a then
      b=qb or (qb==nil and b or nil) or nil
      c=qc or (qc==nil and c or nil) or nil
    end
  end
  if rawequal(q, a) then return a,b,c end
  return unquery(a,b,c)
end
return unquery