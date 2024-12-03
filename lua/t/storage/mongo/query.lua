local t=t or require "t"
local meta = require "meta"
local pkg = t.pkg(...)
local unquery=pkg.unquery
local ok = meta.checker({["nil"]=false}, type, true)
return function(k, qoptions, qas)
  local key, options, as = unquery(k, qoptions, qas)
  return (ok[options] or ok[as]) and {query=key, options=options, as=as} or key
end