return setmetatable({},{
__index=function(self, k) if type(k)~='string' or #k==0 then return end
  local rv = '$'..k
  rawset(self, k, rv)
  return rv
end
})