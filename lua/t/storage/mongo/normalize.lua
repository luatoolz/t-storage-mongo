local t = require "t"
local function normalize(x)
  if type(x)=='table' then
    setmetatable(x, nil)
    if type(x[1])~='nil' then x.__array=true end
    for k,v in pairs(x) do
      if type(v)=='table' then
        normalize(v)
      end
    end
  end
  return x
end
return normalize
