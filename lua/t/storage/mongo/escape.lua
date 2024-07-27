-- $ : / ? # [ ] @
return function(self)
  if type(self)~='string' or self=='' then return nil end
  return (self:gsub("([%$%:%/%?%#%[%]%@])", function(char) return ("%s%02X"):format('%', char:byte()) end)):null()
end
