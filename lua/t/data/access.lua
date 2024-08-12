local t = require "t"

return setmetatable({
  type=t.string,
  id=t.string,
  host=t.string, --t.net.host,
  users=t.integer,
  usermailboxes=t.integer,
  [true]={
    id=[[id]],
    required=[[id host]],
  }
}, {
  ping=function(self) end,
  load=function(self, payload) end,
  __computed={
    country=function(self) end,
    company=function(self) end,
  },
})