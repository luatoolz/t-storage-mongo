local t=t or require "t"
local to=t.to
-- $ : / ? # [ ] @
return function(self)
  if type(self)~='string' or self=='' then return nil end
  return self:gsub("(%%%x%x)", function(digits) return string.char(to.number(digits:sub(2), 16)) end):gsub('^%s+',''):gsub('%s+$','')
end