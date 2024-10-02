local t = t or require "t"
local is = t.is
local env = t.env
local pkg = t.match.modbase(...) or 't.storage.mongo'
local escape = assert(require(pkg .. ".escape"))
local getmetatable = debug and debug.getmetatable or getmetatable
local setmetatable = debug and debug.setmetatable or setmetatable

env({
  MONGO_PREFIX='mongodb://',
  MONGO_HOST='mongodb',
  MONGO_PORT='27017',
  MONGO_DB='db',
--MONGO_USER
--MONGO_PASS
--MONGO_DB
--MONGO_OPTIONS
--MONGO_CONNSTRING
})

local function join(sep, ...)
  sep=sep or ''
  local args={}
  for i=1,select('#', ...) do if select(i, ...)~=nil then args[#args+1]=select(i, ...) end end
  local rv = table.concat(args, sep)
  return rv~='' and rv or nil
end

-- mongodb://user:pass@othermongo:27017/db?x=y&a=b
local function parse_connstring(oconnstring)
  if type(oconnstring)~='string' or #oconnstring==0 then return nil end
  oconnstring=oconnstring:rstrip('&'):rstrip('?'):rstrip('/')
  local connstring=oconnstring
  local prefix = connstring:match('^[^:/]*://')
  if prefix then connstring=connstring:sub(#prefix+1) end
  if not prefix then prefix=env.MONGO_PREFIX; oconnstring=prefix .. oconnstring; end
  local options=connstring:nmatch('?.*$'):lstrip('?'):null()
  if options then connstring=connstring:sub(1, #connstring-#options-1) end
  local db = connstring:nmatch('/[^/]*$'):lstrip('/'):null()
  if db then connstring=connstring:sub(1, #connstring-#db-1) end
  connstring=connstring:rstrip('/')
  local host=connstring:match('[^@]*$')
  if host then connstring=connstring:sub(1, #connstring-#host) end
  local hosts, port
  if host:match('%,') then
    hosts=host:split(',')
    host=nil
  else
    host,port = table.unpack(host:split(':'))
  end
  connstring=connstring:rstrip('@')
  local user = connstring:nmatch('^[^:@]*'):null()
  if user then connstring=connstring:sub(#user+1) end
  local pass=escape(connstring:lstrip(':'))
  _ = oconnstring
  return {
    prefix=prefix,
    db=db,
    host=host,
    hosts=hosts,
    port=port,
    user=user,
    pass=pass,
    options=options,
  }
end

return t.object({
  __name='connection',
  __tostring=function(self) return (is.factory(self) and self() or self).connstring or '' end,
  __call=function(self, conn)
    if type(conn)=='string' then conn=parse_connstring(conn) end
    if type(conn)~='table' then conn={} end
    return getmetatable(conn)==getmetatable(self) and conn or setmetatable(conn, getmetatable(self))
  end,
}):computable({
  prefix  = function(self) return env.MONGO_PREFIX end,
  db      = function(self) if next(self)==nil then return env.MONGO_DB end end,
  hosts   = function(self) return env.MONGO_HOST:match('[,]') and env.MONGO_HOST:split(',') or nil end,
  host    = function(self) return (not self.hosts) and (env.MONGO_HOST or ''):nmatch('^[^:]*'):null() or nil end,
  port    = function(self) if next(self)==nil then return env.MONGO_PORT or (env.MONGO_HOST or ''):nmatch('%d*$'):null() end end,
  user    = function(self) if next(self)==nil then return env.MONGO_USER end end,
  pass    = function(self) if next(self)==nil then return escape(env.MONGO_PASS) end end,
  options = function(self) return (env.MONGO_OPTIONS or ''):lstrip('?'):null() end,
  connstring=function(self)
    local cred = join(':', self.user, self.pass)
    local host = self.hosts and table.concat(self.hosts, ','):null() or join(':', self.host, self.port)
    local credhost = join('@', cred, host)
    local db = self.db
    local hostdb = join('/', credhost, db)
    local options = self.options
    if options and not db then hostdb=hostdb..'/' end
    local hostopts = join('?', hostdb, options)
    return join('', self.prefix, hostopts)
  end,
}):factory()