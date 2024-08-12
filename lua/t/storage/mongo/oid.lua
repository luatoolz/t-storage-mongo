local driver = require 'mongo'
local oid = driver.ObjectID
local t = require "t"
local is = t.is
local json = t.format.json

-- TODO normalize
return function(x)
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
      if is.stringer(x) then local tx=tostring(x); if is.oid(tx) then return end end
    end
  end
end
