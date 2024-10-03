local t = t or require "t"
local is = t.is
local driver = require 'mongo'
local oid = driver.ObjectID
local pkg = t.pkg(...)
local ii = pkg.ii
local json = t.format.json

local ObjectID = function(x)
  if type(x)=='nil' then return oid() end
  if type(x)=='userdata' and t.type(x)=='mongo.ObjectID' then return x end
  if type(x)=='string' then
    if is.oid(x) then return oid(x) end
    if is.json_object(x) then x=json.decode(x) end
  end
  if type(x)=='table' then
    if type(getmetatable(x))=='nil' then
      if is.oid(x._id) then return oid(x._id) end
      if type(x._id)=='table' then x=x._id end
      if is.oid(x['$oid']) then return oid(x['$oid']) end
    else
      if is.stringer(x) then local tx=tostring(x); if is.oid(tx) then return oid(tx) end end
    end
  end
end

local mt = getmetatable(oid())
if mt and type(mt.__export)=='nil' then
  mt.__export = function(self, full) return full==false and tostring(self) or {[ii.oid]=tostring(self)} end
  driver.ObjectID = ObjectID
end

return ObjectID