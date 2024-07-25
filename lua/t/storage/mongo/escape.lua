-- $ : / ? # [ ] @
return function(self)
  if type(self)~='string' or self=='' then return nil end
  return (self:gsub("([%$%:%/%?%#%[%]%@])", function(char) return string.format("%s%02X",'%', char:byte()) end)):null()
end
