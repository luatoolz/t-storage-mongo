local t = require "t"

return setmetatable({
  shell=t.string, --t.net.url,
  password=t.string,
  domain=t.string, --t.net.host,
  users=t.integer,
  ts=t.timestamp,
  usermailboxes=t.integer,
  errors=t.array.flatten,
  exchange_backend_servers=t.string, --t.net.hosts, -- gmatch hosts
  aspx=t.string,
  aspx_full=t.string,
  [true]={
    id=[[shell]],
    required=[[shell password]],
  }
}, {
  ping=function(self) end,
  load=function(self, payload) end,
  __computed={
    country=function(self) end,
    company=function(self) end,
  },
})