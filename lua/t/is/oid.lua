local t=t or require "t"
return t.match.oid
--return function(it) return ((type(tostring(it))=='string' and #tostring(it)==24) and tostring(it):match("^[0-9a-xA-X]+$") or nil) and true or false end