require "meta"
-- $ : / ? # [ ] @
return function(self)
  if type(self)~='string' or self=='' then return nil end
  return self:gsub("(%%%x%x)", function(digits) return string.char(tonumber(digits:sub(2), 16)) end):null()
end
